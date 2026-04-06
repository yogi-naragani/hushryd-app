import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';
import '../models/ride.dart';
import '../middleware/auth_middleware.dart';
import '../utils/response.dart';

class RideRoutes {
  final _uuid = const Uuid();

  Router get router {
    final router = Router();

    router.get('/stats/overview', _withAdminAuth(_getStats));
    router.get('/', _withAdminAuth(_getAll));
    router.post('/', _withAuth(_create));

    router.get('/<id>', _paramWithAuth(_getById));
    router.put('/<id>', _paramWithAuth(_updateById));
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

      final rides = await Ride.findAll(
        page: page, limit: limit,
        status: params['status'],
        userId: params['userId'],
        driverId: params['driverId'],
        pickupDate: params['pickupDate'],
      );

      return ApiResponse.success('Rides retrieved successfully', data: {
        'rides': rides.map((r) => r.toJson()).toList(),
        'pagination': {'page': page, 'limit': limit, 'total': rides.length},
      });
    } catch (e) {
      print('Get rides error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _getById(Request request, String id) async {
    try {
      final ride = await Ride.findById(id);
      if (ride == null) return ApiResponse.notFound('Ride not found');

      final role = (request.context['userRole'] ?? '') as String;
      final userId = request.context['userId'] as String;
      if (role != 'admin' && role != 'superadmin' && userId != ride.userId) {
        return ApiResponse.forbidden('Access denied');
      }

      return ApiResponse.success('Ride retrieved successfully',
          data: {'ride': ride.toJson()});
    } catch (e) {
      print('Get ride error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _create(Request request) async {
    try {
      final body = await parseJsonBody(request);
      for (final f in ['fromLocation', 'toLocation', 'pickupDate', 'pickupTime', 'timeslot', 'fare']) {
        if (body[f] == null) return ApiResponse.badRequest('$f is required');
      }

      final userId = request.context['userId'] as String;
      String fromLoc = body['fromLocation'] is String
          ? body['fromLocation'] : jsonEncode(body['fromLocation']);
      String toLoc = body['toLocation'] is String
          ? body['toLocation'] : jsonEncode(body['toLocation']);

      final newRide = await Ride.create({
        'id': _uuid.v4(),
        'userId': userId,
        'driverId': null,
        'fromLocation': fromLoc,
        'toLocation': toLoc,
        'pickupDate': body['pickupDate'],
        'pickupTime': body['pickupTime'],
        'timeslot': body['timeslot'],
        'fare': (body['fare'] is num) ? (body['fare'] as num).toDouble() : double.tryParse(body['fare'].toString()),
        'distance': body['distance'] != null ? (body['distance'] is num ? (body['distance'] as num).toDouble() : double.tryParse(body['distance'].toString())) : null,
        'duration': body['duration'] != null ? (body['duration'] is int ? body['duration'] : int.tryParse(body['duration'].toString())) : null,
        'notes': body['notes'],
        'status': 'pending',
        'paymentStatus': 'pending',
        'paymentMethod': null,
      });

      return ApiResponse.created('Ride created successfully',
          data: {'ride': newRide.toJson()});
    } catch (e) {
      print('Create ride error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _updateById(Request request, String id) async {
    try {
      final ride = await Ride.findById(id);
      if (ride == null) return ApiResponse.notFound('Ride not found');

      final role = (request.context['userRole'] ?? '') as String;
      final userId = request.context['userId'] as String;
      if (role != 'admin' && role != 'superadmin' && userId != ride.userId) {
        return ApiResponse.forbidden('Access denied');
      }

      final body = await parseJsonBody(request);
      final updateData = <String, dynamic>{};

      for (final key in ['fromLocation', 'toLocation', 'pickupDate', 'pickupTime', 'timeslot', 'fare', 'notes']) {
        if (body.containsKey(key)) updateData[key] = body[key];
      }
      if (role == 'admin' || role == 'superadmin') {
        for (final key in ['status', 'paymentStatus', 'driverId']) {
          if (body.containsKey(key)) updateData[key] = body[key];
        }
      }

      final updatedRide = await ride.update(updateData);
      return ApiResponse.success('Ride updated successfully',
          data: {'ride': updatedRide.toJson()});
    } catch (e) {
      print('Update ride error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _deleteById(Request request, String id) async {
    try {
      final ride = await Ride.findById(id);
      if (ride == null) return ApiResponse.notFound('Ride not found');
      await ride.delete();
      return ApiResponse.success('Ride deleted successfully');
    } catch (e) {
      print('Delete ride error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _getStats(Request request) async {
    try {
      final stats = await Ride.getStats();
      return ApiResponse.success('Ride statistics retrieved successfully',
          data: {'stats': stats});
    } catch (e) {
      print('Get ride stats error: $e');
      return ApiResponse.error('Internal server error');
    }
  }
}
