import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../models/booking.dart';
import '../config/database.dart';
import '../middleware/auth_middleware.dart';
import '../utils/response.dart';
import '../utils/validators.dart';

class UserRoutes {
  final _uuid = const Uuid();

  Router get router {
    final router = Router();

    // User self routes (middleware applied in handler)
    router.get('/me', _withAuth(_getMe));
    router.put('/me', _withAuth(_updateMe));
    router.get('/me/bookings', _withAuth(_getMyBookings));
    router.get('/me/complaints', _withAuth(_getMyComplaints));

    // Stats (must be before /:id)
    router.get('/stats/overview', _withAdminAuth(_getStats));

    // Admin routes
    router.get('/', _withAdminAuth(_getAll));
    router.post('/', _withAdminAuth(_create));

    // Param routes
    router.get('/<id>', _withAuthParam(_getById));
    router.put('/<id>', _withAuthParam(_updateById));
    router.delete('/<id>', _withAdminAuthParam(_deleteById));

    return router;
  }

  // Helper to apply token auth to simple handlers
  Handler _withAuth(Future<Response> Function(Request) handler) {
    return Pipeline().addMiddleware(authenticateToken()).addHandler(handler);
  }

  // Helper to apply admin auth
  Handler _withAdminAuth(Future<Response> Function(Request) handler) {
    return Pipeline()
        .addMiddleware(authenticateAdmin())
        .addMiddleware(requireRole(['superadmin', 'admin']))
        .addHandler(handler);
  }

  // Helper for parameterized routes with token auth
  Function _withAuthParam(
      Future<Response> Function(Request, String) handler) {
    return (Request request, String id) async {
      final authHandler = authenticateToken();
      final innerHandler = (Request req) async => handler(req, id);
      return authHandler(innerHandler)(request);
    };
  }

  // Helper for parameterized routes with admin auth
  Function _withAdminAuthParam(
      Future<Response> Function(Request, String) handler) {
    return (Request request, String id) async {
      final pipeline = Pipeline()
          .addMiddleware(authenticateAdmin())
          .addMiddleware(requireRole(['superadmin', 'admin']));
      final innerHandler = (Request req) async => handler(req, id);
      return pipeline.addHandler(innerHandler)(request);
    };
  }

  Future<Response> _getMe(Request request) async {
    try {
      final userId = request.context['userId'] as String;
      final user = await User.findById(userId);
      if (user == null) return ApiResponse.notFound('User not found');

      return ApiResponse.success('User profile retrieved successfully', data: {
        'user': user.toJson(),
      });
    } catch (e) {
      print('Get current user error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _updateMe(Request request) async {
    try {
      final userId = request.context['userId'] as String;
      final body = await parseJsonBody(request);

      final user = await User.findById(userId);
      if (user == null) return ApiResponse.notFound('User not found');

      final updates = <String, dynamic>{};
      for (final key in [
        'firstName', 'lastName', 'email', 'phone', 'emergencyContact',
        'address', 'city', 'state', 'pincode', 'bio'
      ]) {
        if (body.containsKey(key) && body[key] != null) updates[key] = body[key];
      }
      if (body.containsKey('avatar') && body['avatar'] != null) {
        updates['profileImage'] = body['avatar'];
      }

      final updatedUser = await user.update(updates);

      return ApiResponse.success('Profile updated successfully!', data: {
        'user': updatedUser.toJson(),
      });
    } catch (e) {
      print('Update user error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  Future<Response> _getMyBookings(Request request) async {
    try {
      final userId = request.context['userId'] as String;
      final bookings = await Booking.findByUserId(userId);

      return ApiResponse.success('User bookings retrieved successfully', data: {
        'bookings': bookings.map((b) => b.toJson()).toList(),
      });
    } catch (e) {
      print('Get user bookings error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _getMyComplaints(Request request) async {
    try {
      final userId = request.context['userId'] as String;
      final result = await Database.query(
        'SELECT * FROM complaints WHERE user_id = @userId ORDER BY created_at DESC',
        parameters: {'userId': userId},
      );
      final complaints = result.map((r) => r.toColumnMap()).toList();

      return ApiResponse.success('User complaints retrieved successfully', data: {
        'complaints': complaints,
      });
    } catch (e) {
      print('Get user complaints error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _getAll(Request request) async {
    try {
      final params = request.requestedUri.queryParameters;
      final page = int.tryParse(params['page'] ?? '') ?? 1;
      final limit = int.tryParse(params['limit'] ?? '') ?? 10;

      final users = await User.findAll(
        page: page,
        limit: limit,
        role: params['role'],
        isActive: params['isActive'] != null ? params['isActive'] == 'true' : null,
        isVerified: params['isVerified'] != null ? params['isVerified'] == 'true' : null,
      );

      return ApiResponse.success('Users retrieved successfully', data: {
        'users': users.map((u) => u.toJson()).toList(),
        'pagination': {'page': page, 'limit': limit, 'total': users.length},
      });
    } catch (e) {
      print('Get users error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _getById(Request request, String id) async {
    try {
      final role = (request.context['userRole'] ?? '') as String;
      final userId = request.context['userId'] as String;

      if (role != 'admin' && role != 'superadmin' && userId != id) {
        return ApiResponse.forbidden('Access denied');
      }

      final user = await User.findById(id);
      if (user == null) return ApiResponse.notFound('User not found');

      return ApiResponse.success('User retrieved successfully', data: {
        'user': user.toJson(),
      });
    } catch (e) {
      print('Get user error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _create(Request request) async {
    try {
      final body = await parseJsonBody(request);
      final missing = Validators.validateRequired(
          body, ['email', 'firstName', 'lastName', 'phone']);
      if (missing != null) return ApiResponse.badRequest(missing);

      final existing = await User.findByEmail(body['email'] as String);
      if (existing != null) {
        return ApiResponse.conflict('User with this email already exists');
      }

      final user = await User.create({
        'id': _uuid.v4(),
        ...body,
      });

      return ApiResponse.created('User created successfully', data: {
        'user': user.toJson(),
      });
    } catch (e) {
      print('Create user error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _updateById(Request request, String id) async {
    try {
      final role = (request.context['userRole'] ?? '') as String;
      final userId = request.context['userId'] as String;

      if (role != 'admin' && role != 'superadmin' && userId != id) {
        return ApiResponse.forbidden('Access denied');
      }

      final user = await User.findById(id);
      if (user == null) return ApiResponse.notFound('User not found');

      final body = await parseJsonBody(request);
      if (role != 'admin' && role != 'superadmin') {
        body.remove('role');
        body.remove('isActive');
      }

      final updatedUser = await user.update(body);

      return ApiResponse.success('User updated successfully', data: {
        'user': updatedUser.toJson(),
      });
    } catch (e) {
      print('Update user error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _deleteById(Request request, String id) async {
    try {
      final user = await User.findById(id);
      if (user == null) return ApiResponse.notFound('User not found');

      await user.delete();
      return ApiResponse.success('User deleted successfully');
    } catch (e) {
      print('Delete user error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _getStats(Request request) async {
    try {
      final stats = await User.getStats();
      return ApiResponse.success('User statistics retrieved successfully',
          data: {'stats': stats});
    } catch (e) {
      print('Get user stats error: $e');
      return ApiResponse.error('Internal server error');
    }
  }
}
