import 'package:dart_frog/dart_frog.dart';
import 'package:hushryd_backend/models/admin.dart';
import 'package:hushryd_backend/middleware/auth.dart';
import 'package:hushryd_backend/utils/response.dart';

Future<Response> onRequest(RequestContext context) async {
  final payload = extractTokenPayload(context);
  if (payload == null) return ApiResponse.unauthorized('No token');
  if (!hasRole(payload, ['superadmin'])) return ApiResponse.forbidden('Access denied');
  final stats = await Admin.getStats();
  return ApiResponse.success('Admin stats retrieved', data: {'stats': stats});
}
