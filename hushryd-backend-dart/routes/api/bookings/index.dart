import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:uuid/uuid.dart';
import 'package:hushryd_backend/models/booking.dart';
import 'package:hushryd_backend/middleware/auth.dart';
import 'package:hushryd_backend/utils/response.dart';

Future<Response> onRequest(RequestContext context) async {
  final payload = extractTokenPayload(context);
  if (payload == null) return ApiResponse.unauthorized('No token');

  switch (context.request.method) {
    case HttpMethod.get:
      if (!hasRole(payload, ['superadmin', 'admin'])) return ApiResponse.forbidden('Access denied');
      final p = context.request.uri.queryParameters;
      final bookings = await Booking.findAllWithDetails(
        page: int.tryParse(p['page'] ?? '') ?? 1, limit: int.tryParse(p['limit'] ?? '') ?? 10,
        userId: p['userId'], rideId: p['rideId'], status: p['status'], paymentStatus: p['paymentStatus']);
      return ApiResponse.success('Bookings retrieved', data: {
        'bookings': bookings, 'pagination': {'page': 1, 'limit': 10, 'total': bookings.length}});

    case HttpMethod.post:
      final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;
      if (body['rideId'] == null || body['passengerCount'] == null || body['totalPrice'] == null) {
        return ApiResponse.badRequest('rideId, passengerCount, totalPrice required');
      }
      final booking = await Booking.create({
        'id': const Uuid().v4(), 'userId': payload['id'],
        'rideId': body['rideId'], 'passengerCount': body['passengerCount'],
        'totalPrice': body['totalPrice'], 'currency': body['currency'] ?? 'INR',
        'status': 'pending', 'paymentStatus': 'pending',
        'paymentMethod': body['paymentMethod'], 'specialRequests': body['specialRequests']});
      return ApiResponse.created('Booking created', data: {'booking': booking.toJson()});

    default:
      return ApiResponse.error('Method not allowed', statusCode: 405);
  }
}
