import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:uuid/uuid.dart';
import '../models/admin.dart';
import '../middleware/auth_middleware.dart';
import '../utils/response.dart';

class AdminRoutes {
  final _uuid = const Uuid();

  Router get router {
    final router = Router();

    router.get('/stats/overview', _withSuperadminAuth(_getStats));

    router.get('/', _withAdminAuth(_getAll));
    router.post('/', _withSuperadminAuth(_create));

    router.get('/<id>', _paramWithAdminAuth(_getById));
    router.put('/<id>', _paramWithAdminAuth(_updateById));
    router.delete('/<id>', _paramWithSuperadminAuth(_deleteById));

    return router;
  }

  Handler _withAdminAuth(Future<Response> Function(Request) h) =>
      Pipeline()
          .addMiddleware(authenticateAdmin())
          .addMiddleware(requireRole(['superadmin', 'admin']))
          .addHandler(h);

  Handler _withSuperadminAuth(Future<Response> Function(Request) h) =>
      Pipeline()
          .addMiddleware(authenticateAdmin())
          .addMiddleware(requireRole(['superadmin']))
          .addHandler(h);

  Function _paramWithAdminAuth(Future<Response> Function(Request, String) h) {
    return (Request request, String id) async {
      final pipeline = Pipeline()
          .addMiddleware(authenticateAdmin())
          .addMiddleware(requireRole(['superadmin', 'admin']));
      return pipeline.addHandler((req) => h(req, id))(request);
    };
  }

  Function _paramWithSuperadminAuth(Future<Response> Function(Request, String) h) {
    return (Request request, String id) async {
      final pipeline = Pipeline()
          .addMiddleware(authenticateAdmin())
          .addMiddleware(requireRole(['superadmin']));
      return pipeline.addHandler((req) => h(req, id))(request);
    };
  }

  Future<Response> _getAll(Request request) async {
    try {
      final params = request.requestedUri.queryParameters;
      final page = int.tryParse(params['page'] ?? '') ?? 1;
      final limit = int.tryParse(params['limit'] ?? '') ?? 10;

      final admins = await Admin.findAll(
        page: page, limit: limit,
        role: params['role'],
        isActive: params['isActive'] != null ? params['isActive'] == 'true' : null,
      );

      return ApiResponse.success('Admins retrieved successfully', data: {
        'admins': admins.map((a) => a.toJson()).toList(),
        'pagination': {'page': page, 'limit': limit, 'total': admins.length},
      });
    } catch (e) {
      print('Get admins error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _getById(Request request, String id) async {
    try {
      final admin = await Admin.findById(id);
      if (admin == null) return ApiResponse.notFound('Admin not found');
      return ApiResponse.success('Admin retrieved successfully',
          data: {'admin': admin.toJson()});
    } catch (e) {
      print('Get admin error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _create(Request request) async {
    try {
      final body = await parseJsonBody(request);
      for (final f in ['email', 'firstName', 'lastName', 'role']) {
        if (body[f] == null || (body[f] is String && body[f].isEmpty)) {
          return ApiResponse.badRequest('$f is required');
        }
      }

      final existing = await Admin.findByEmail(body['email'] as String);
      if (existing != null) {
        return ApiResponse.conflict('Admin with this email already exists');
      }

      final hashedPassword = BCrypt.hashpw('Password123!', BCrypt.gensalt());

      final admin = await Admin.create({
        'id': _uuid.v4(),
        'email': body['email'],
        'password': hashedPassword,
        'firstName': body['firstName'],
        'lastName': body['lastName'],
        'role': body['role'],
        'permissions': body['permissions'] ?? [],
        'isActive': body['isActive'] ?? true,
      });

      return ApiResponse.created('Admin created successfully',
          data: {'admin': admin.toJson()});
    } catch (e) {
      print('Create admin error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _updateById(Request request, String id) async {
    try {
      final adminRole = request.context['adminRole'] as String;
      final adminId = request.context['adminId'] as String;

      if (adminRole != 'superadmin' && adminId != id) {
        return ApiResponse.forbidden('Access denied');
      }

      final admin = await Admin.findById(id);
      if (admin == null) return ApiResponse.notFound('Admin not found');

      final body = await parseJsonBody(request);
      if (adminRole != 'superadmin') {
        body.remove('role');
        body.remove('permissions');
      }

      final updatedAdmin = await admin.update(body);
      return ApiResponse.success('Admin updated successfully',
          data: {'admin': updatedAdmin.toJson()});
    } catch (e) {
      print('Update admin error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _deleteById(Request request, String id) async {
    try {
      final adminId = request.context['adminId'] as String;
      if (adminId == id) {
        return ApiResponse.badRequest('Cannot delete your own account');
      }

      final admin = await Admin.findById(id);
      if (admin == null) return ApiResponse.notFound('Admin not found');

      await admin.delete();
      return ApiResponse.success('Admin deleted successfully');
    } catch (e) {
      print('Delete admin error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _getStats(Request request) async {
    try {
      final stats = await Admin.getStats();
      return ApiResponse.success('Admin statistics retrieved successfully',
          data: {'stats': stats});
    } catch (e) {
      print('Get admin stats error: $e');
      return ApiResponse.error('Internal server error');
    }
  }
}
