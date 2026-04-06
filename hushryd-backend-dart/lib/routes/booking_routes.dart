import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';
import '../models/booking.dart';
import '../middleware/auth_middleware.dart';
import '../utils/response.dart';

class BookingRoutes {
  final _uuid = const Uuid();

  Router get router {
    final router = Router();

    router.get('/stats/overview', _withAdminAuth(_getStats));
    router.get('/', _withAdminAuth(_getAll));
    router.post('/', _withAuth(_create));

    router.get('/user/<userId>', _paramWithAuth(_getByUserId));
    router.get('/<id>', _paramWithAuth(_getById));
    router.put('/<id>', _paramWithAuth(_updateById));
    router.post('/<id>/cancel', _paramWithAuth(_cancel));
    router.delete('/<id>', _paramWithAdminAuth(_deleteById));

    return router;
  }

  Handler _withAuth(Future<Response> Function(Request) h) =>
      Pipeline().addMiddleware(authenticateToken()).addHandler(h);

  Handler _withAdminAuth(Future<Response> Function(Request) h) =>
      Pipeline()
          .addMiddleware(authenticateAdmin())
          .addMiddleware(requireRole(['superadmin', 'admin']))
          .addHandler(h);

  Function _paramWithAuth(Future<Response> Function(Request, String) h) {
    return (Request request, String id) async {
      return Pipeline()
          .addMiddleware(authenticateToken())
          .addHandler((req) => h(req, id))(request);
    };
  }

  Function _paramWithAdminAuth(Future<Response> Function(Request, String) h) {
    return (Request request, String id) async {
      return Pipeline()
          .addMiddleware(authenticateAdmin())
          .addMiddleware(requireRole(['superadmin', 'admin']))
          .addHandler((req) => h(req, id))(request);
    };
  }

  Future<Response> _getAll(Request request) async {
    try {
      final params = request.requestedUri.queryParameters;
      final page = int.tryParse(params['page'] ?? '') ?? 1;
      final limit = int.tryParse(params['limit'] ?? '') ?? 10;

      final bookings = await Booking.findAllWithDetails(
        page: page, limit: limit,
        userId: params['userId'],
        rideId: params['rideId'],
        status: params['status'],
        paymentStatus: params['paymentStatus'],
      );

      return ApiResponse.success('Bookings retrieved successfully', data: {
        'bookings': bookings,
        'pagination': {'page': page, 'limit': limit, 'total': bookings.length},
      });
    } catch (e) {
      print('Get bookings error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _getByUserId(Request request, String userId) async {
    try {
      final role = (request.context['userRole'] ?? '') as String;
      final currentUserId = request.context['userId'] as String;

      if (role != 'admin' && role != 'superadmin' && currentUserId != userId) {
        return ApiResponse.forbidden('Access denied');
      }

      final bookings = await Booking.findByUserId(userId);
      return ApiResponse.success('User bookings retrieved successfully', data: {
        'bookings': bookings.map((b) => b.toJson()).toList(),
        'pagination': {'page': 1, 'limit': 100, 'total': bookings.length},
      });
    } catch (e) {
      print('Get user bookings error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _getById(Request request, String id) async {
    try {
      final booking = await Booking.findById(id);
      if (booking == null) return ApiResponse.notFound('Booking not found');

      final role = (request.context['userRole'] ?? '') as String;
      final userId = request.context['userId'] as String;
      if (role != 'admin' && role != 'superadmin' && userId != booking.userId) {
        return ApiResponse.forbidden('Access denied');
      }

      return ApiResponse.success('Booking retrieved successfully',
          data: {'booking': booking.toJson()});
    } catch (e) {
      print('Get booking error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _create(Request request) async {
    try {
      final body = await parseJsonBody(request);
      final userId = request.context['userId'] as String;

      if (body['rideId'] == null || body['passengerCount'] == null || body['totalPrice'] == null) {
        return ApiResponse.badRequest('Ride ID, passenger count, and total price are required');
      }

      final newBooking = await Booking.create({
        'id': _uuid.v4(),
        'userId': userId,
        'rideId': body['rideId'],
        'passengerCount': body['passengerCount'] is int ? body['passengerCount'] : int.tryParse(body['passengerCount'].toString()),
        'totalPrice': body['totalPrice'] is num ? (body['totalPrice'] as num).toDouble() : double.tryParse(body['totalPrice'].toString()),
        'currency': body['currency'] ?? 'INR',
        'status': body['status'] ?? 'pending',
        'paymentStatus': body['paymentStatus'] ?? 'pending',
        'paymentMethod': body['paymentMethod'],
        'specialRequests': body['specialRequests'],
      });

      return ApiResponse.created('Booking created successfully',
          data: {'booking': newBooking.toJson()});
    } catch (e) {
      print('Create booking error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  Future<Response> _updateById(Request request, String id) async {
    try {
      final booking = await Booking.findById(id);
      if (booking == null) return ApiResponse.notFound('Booking not found');

      final role = (request.context['userRole'] ?? '') as String;
      final userId = request.context['userId'] as String;
      if (role != 'admin' && role != 'superadmin' && userId != booking.userId) {
        return ApiResponse.forbidden('Access denied');
      }

      final body = await parseJsonBody(request);
      final updatedBooking = await booking.update(body);
      return ApiResponse.success('Booking updated successfully',
          data: {'booking': updatedBooking.toJson()});
    } catch (e) {
      print('Update booking error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _cancel(Request request, String id) async {
    try {
      final booking = await Booking.findById(id);
      if (booking == null) return ApiResponse.notFound('Booking not found');

      final role = (request.context['userRole'] ?? '') as String;
      final userId = request.context['userId'] as String;
      if (role != 'admin' && role != 'superadmin' && userId != booking.userId) {
        return ApiResponse.forbidden('Access denied');
      }

      if (booking.status == 'cancelled') {
        return ApiResponse.badRequest('Booking is already cancelled');
      }

      final cancelledBooking = await booking.cancel();
      return ApiResponse.success('Booking cancelled successfully',
          data: {'booking': cancelledBooking.toJson()});
    } catch (e) {
      print('Cancel booking error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _deleteById(Request request, String id) async {
    try {
      final booking = await Booking.findById(id);
      if (booking == null) return ApiResponse.notFound('Booking not found');
      await booking.delete();
      return ApiResponse.success('Booking deleted successfully');
    } catch (e) {
      print('Delete booking error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _getStats(Request request) async {
    try {
      final stats = await Booking.getStats();
      return ApiResponse.success('Booking statistics retrieved successfully',
          data: {'stats': stats});
    } catch (e) {
      print('Get booking stats error: $e');
      return ApiResponse.error('Internal server error');
    }
  }
}
