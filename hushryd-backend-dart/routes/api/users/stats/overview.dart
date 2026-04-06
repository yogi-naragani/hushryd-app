import 'package:dart_frog/dart_frog.dart';
import 'package:hushryd_backend/models/user.dart';
import 'package:hushryd_backend/middleware/auth.dart';
import 'package:hushryd_backend/utils/response.dart';

Future<Response> onRequest(RequestContext context) async {
  final payload = extractTokenPayload(context);
  if (payload == null) return ApiResponse.unauthorized('No token');
  if (!hasRole(payload, ['superadmin', 'admin'])) return ApiResponse.forbidden('Access denied');

  try {
    final stats = await User.getStats();
    return ApiResponse.success('User statistics retrieved', data: {'stats': stats});
  } catch (e) {
    return ApiResponse.error('Internal server error');
  }
}
