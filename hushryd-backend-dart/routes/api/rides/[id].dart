import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:hushryd_backend/models/ride.dart';
import 'package:hushryd_backend/middleware/auth.dart';
import 'package:hushryd_backend/utils/response.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final payload = extractTokenPayload(context);
  if (payload == null) return ApiResponse.unauthorized('No token');
  final role = payload['role']?.toString() ?? '';
  final userId = payload['id']?.toString() ?? '';

  switch (context.request.method) {
    case HttpMethod.get:
      final ride = await Ride.findById(id);
      if (ride == null) return ApiResponse.notFound('Ride not found');
      if (role != 'admin' && role != 'superadmin' && userId != ride.userId) {
        return ApiResponse.forbidden('Access denied');
      }
      return ApiResponse.success('Ride retrieved', data: {'ride': ride.toJson()});

    case HttpMethod.put:
      final ride = await Ride.findById(id);
      if (ride == null) return ApiResponse.notFound('Ride not found');
      if (role != 'admin' && role != 'superadmin' && userId != ride.userId) {
        return ApiResponse.forbidden('Access denied');
      }
      final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;
      final updateData = <String, dynamic>{};
      for (final k in ['fromLocation','toLocation','pickupDate','pickupTime','timeslot','fare','notes']) {
        if (body.containsKey(k)) updateData[k] = body[k];
      }
      if (role == 'admin' || role == 'superadmin') {
        for (final k in ['status','paymentStatus','driverId']) {
          if (body.containsKey(k)) updateData[k] = body[k];
        }
      }
      final updated = await ride.update(updateData);
      return ApiResponse.success('Ride updated', data: {'ride': updated.toJson()});

    case HttpMethod.delete:
      if (!hasRole(payload, ['superadmin', 'admin'])) return ApiResponse.forbidden('Access denied');
      final ride = await Ride.findById(id);
      if (ride == null) return ApiResponse.notFound('Ride not found');
      await ride.delete();
      return ApiResponse.success('Ride deleted');

    default:
      return ApiResponse.error('Method not allowed', statusCode: 405);
  }
}
