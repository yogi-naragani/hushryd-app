import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:hushryd_backend/models/offer.dart';
import 'package:hushryd_backend/utils/response.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return ApiResponse.error('Method not allowed', statusCode: 405);
  }
  final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;
  final code = body['code'] as String?;
  if (code == null || code.isEmpty) return ApiResponse.badRequest('code required');

  final offer = await Offer.findByCode(code.toUpperCase());
  if (offer == null) return ApiResponse.notFound('Invalid offer code');
  if (!offer.isValid) return ApiResponse.badRequest('Offer expired');

  final amount = body['amount'] != null ? double.tryParse(body['amount'].toString()) : null;
  if (amount != null && offer.minAmount != null && amount < offer.minAmount!) {
    return ApiResponse.badRequest('Minimum amount ${offer.minAmount} required');
  }

  final discount = amount != null ? offer.calculateDiscount(amount) : null;
  final finalAmount = amount != null && discount != null ? (amount - discount).clamp(0, double.infinity) : null;

  return ApiResponse.success('Offer valid', data: {
    'offer': offer.toJson(), 'discount': discount, 'finalAmount': finalAmount});
}
