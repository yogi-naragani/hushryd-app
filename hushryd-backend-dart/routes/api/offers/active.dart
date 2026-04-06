import 'package:dart_frog/dart_frog.dart';
import 'package:hushryd_backend/models/offer.dart';
import 'package:hushryd_backend/utils/response.dart';

Future<Response> onRequest(RequestContext context) async {
  final offers = await Offer.findActive();
  return ApiResponse.success('Active offers retrieved', data: {
    'offers': offers.map((o) => o.toJson()).toList()});
}
