import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:uuid/uuid.dart';
import 'package:hushryd_backend/models/offer.dart';
import 'package:hushryd_backend/middleware/auth.dart';
import 'package:hushryd_backend/utils/response.dart';

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      final payload = extractTokenPayload(context);
      if (payload == null) return ApiResponse.unauthorized('No token');
      final p = context.request.uri.queryParameters;
      final offers = await Offer.findAll(
        page: int.tryParse(p['page'] ?? '') ?? 1,
        limit: int.tryParse(p['limit'] ?? '') ?? 10,
        isActive: p['isActive'] != null ? p['isActive'] == 'true' : null);
      return ApiResponse.success('Offers retrieved', data: {
        'offers': offers.map((o) => o.toJson()).toList()});

    case HttpMethod.post:
      final payload = extractTokenPayload(context);
      if (payload == null) return ApiResponse.unauthorized('No token');
      if (!hasRole(payload, ['superadmin', 'admin'])) return ApiResponse.forbidden('Access denied');
      final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;
      for (final f in ['code','title','discountValue','validFrom','validUntil']) {
        if (body[f] == null) return ApiResponse.badRequest('$f required');
      }
      final code = (body['code'] as String).toUpperCase();
      final existing = await Offer.findByCode(code);
      if (existing != null) return ApiResponse.conflict('Offer code exists');
      final offer = await Offer.create({
        'id': const Uuid().v4(), 'code': code, 'title': body['title'],
        'description': body['description'], 'discountType': body['discountType'] ?? 'percentage',
        'discountValue': body['discountValue'], 'minAmount': body['minAmount'] ?? 0,
        'maxDiscount': body['maxDiscount'], 'maxUses': body['maxUses'],
        'validFrom': body['validFrom'], 'validUntil': body['validUntil'],
        'isActive': true, 'applicableTo': body['applicableTo'] ?? 'all',
        'createdBy': payload['id']});
      return ApiResponse.created('Offer created', data: {'offer': offer.toJson()});

    default:
      return ApiResponse.error('Method not allowed', statusCode: 405);
  }
}
