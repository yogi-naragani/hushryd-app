import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:hushryd_backend/models/offer.dart';
import 'package:hushryd_backend/middleware/auth.dart';
import 'package:hushryd_backend/utils/response.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final payload = extractTokenPayload(context);
  if (payload == null) return ApiResponse.unauthorized('No token');
  if (!hasRole(payload, ['superadmin', 'admin'])) return ApiResponse.forbidden('Access denied');

  switch (context.request.method) {
    case HttpMethod.get:
      final offer = await Offer.findById(id);
      if (offer == null) return ApiResponse.notFound('Offer not found');
      return ApiResponse.success('Offer retrieved', data: {'offer': offer.toJson()});

    case HttpMethod.put:
      final offer = await Offer.findById(id);
      if (offer == null) return ApiResponse.notFound('Offer not found');
      final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;
      final updated = await offer.update(body);
      return ApiResponse.success('Offer updated', data: {'offer': updated.toJson()});

    case HttpMethod.delete:
      final offer = await Offer.findById(id);
      if (offer == null) return ApiResponse.notFound('Offer not found');
      await offer.delete();
      return ApiResponse.success('Offer deleted');

    default:
      return ApiResponse.error('Method not allowed', statusCode: 405);
  }
}
