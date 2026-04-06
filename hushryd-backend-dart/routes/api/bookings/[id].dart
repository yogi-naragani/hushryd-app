import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:hushryd_backend/models/booking.dart';
import 'package:hushryd_backend/middleware/auth.dart';
import 'package:hushryd_backend/utils/response.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final payload = extractTokenPayload(context);
  if (payload == null) return ApiResponse.unauthorized('No token');
  final role = payload['role']?.toString() ?? '';
  final userId = payload['id']?.toString() ?? '';

  switch (context.request.method) {
    case HttpMethod.get:
      final booking = await Booking.findById(id);
      if (booking == null) return ApiResponse.notFound('Booking not found');
      if (role != 'admin' && role != 'superadmin' && userId != booking.userId) {
        return ApiResponse.forbidden('Access denied');
      }
      return ApiResponse.success('Booking retrieved', data: {'booking': booking.toJson()});

    case HttpMethod.put:
      final booking = await Booking.findById(id);
      if (booking == null) return ApiResponse.notFound('Booking not found');
      if (role != 'admin' && role != 'superadmin' && userId != booking.userId) {
        return ApiResponse.forbidden('Access denied');
      }
      final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;
      final updated = await booking.update(body);
      return ApiResponse.success('Booking updated', data: {'booking': updated.toJson()});

    case HttpMethod.delete:
      if (!hasRole(payload, ['superadmin', 'admin'])) return ApiResponse.forbidden('Access denied');
      final booking = await Booking.findById(id);
      if (booking == null) return ApiResponse.notFound('Booking not found');
      await booking.delete();
      return ApiResponse.success('Booking deleted');

    default:
      return ApiResponse.error('Method not allowed', statusCode: 405);
  }
}
