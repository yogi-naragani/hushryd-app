import 'package:dart_frog/dart_frog.dart';
import 'package:hushryd_backend/models/ride.dart';
import 'package:hushryd_backend/middleware/auth.dart';
import 'package:hushryd_backend/utils/response.dart';

Future<Response> onRequest(RequestContext context) async {
  final payload = extractTokenPayload(context);
  if (payload == null) return ApiResponse.unauthorized('No token');
  if (!hasRole(payload, ['superadmin', 'admin'])) return ApiResponse.forbidden('Access denied');
  final stats = await Ride.getStats();
  return ApiResponse.success('Ride stats retrieved', data: {'stats': stats});
}
