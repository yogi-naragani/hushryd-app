import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:uuid/uuid.dart';
import 'package:hushryd_backend/models/ride.dart';
import 'package:hushryd_backend/middleware/auth.dart';
import 'package:hushryd_backend/utils/response.dart';

Future<Response> onRequest(RequestContext context) async {
  final payload = extractTokenPayload(context);
  if (payload == null) return ApiResponse.unauthorized('No token');

  switch (context.request.method) {
    case HttpMethod.get:
      if (!hasRole(payload, ['superadmin', 'admin'])) return ApiResponse.forbidden('Access denied');
      final p = context.request.uri.queryParameters;
      final rides = await Ride.findAll(page: int.tryParse(p['page'] ?? '') ?? 1,
        limit: int.tryParse(p['limit'] ?? '') ?? 10, status: p['status'],
        userId: p['userId'], driverId: p['driverId'], pickupDate: p['pickupDate']);
      return ApiResponse.success('Rides retrieved', data: {
        'rides': rides.map((r) => r.toJson()).toList(),
        'pagination': {'page': 1, 'limit': 10, 'total': rides.length}});

    case HttpMethod.post:
      final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;
      for (final f in ['fromLocation', 'toLocation', 'pickupDate', 'pickupTime', 'timeslot', 'fare']) {
        if (body[f] == null) return ApiResponse.badRequest('$f is required');
      }
      final userId = payload['id']?.toString() ?? '';
      final fromLoc = body['fromLocation'] is String ? body['fromLocation'] : jsonEncode(body['fromLocation']);
      final toLoc = body['toLocation'] is String ? body['toLocation'] : jsonEncode(body['toLocation']);
      final ride = await Ride.create({
        'id': const Uuid().v4(), 'userId': userId, 'driverId': null,
        'fromLocation': fromLoc, 'toLocation': toLoc,
        'pickupDate': body['pickupDate'], 'pickupTime': body['pickupTime'],
        'timeslot': body['timeslot'], 'fare': body['fare'],
        'distance': body['distance'], 'duration': body['duration'],
        'notes': body['notes'], 'status': 'pending', 'paymentStatus': 'pending'});
      return ApiResponse.created('Ride created', data: {'ride': ride.toJson()});

    default:
      return ApiResponse.error('Method not allowed', statusCode: 405);
  }
}
