import 'package:dart_frog/dart_frog.dart';
import 'package:hushryd_backend/models/user.dart';
import 'package:hushryd_backend/models/admin.dart';
import 'package:hushryd_backend/middleware/auth.dart';
import 'package:hushryd_backend/utils/response.dart';

Future<Response> onRequest(RequestContext context) async {
  final authError = verifyToken(context);
  if (authError != null) return authError;

  try {
    final payload = extractTokenPayload(context);
    if (payload == null) return ApiResponse.unauthorized('Invalid token');

    final role = payload['role'] as String? ?? '';
    final id = payload['id']?.toString() ?? '';

    if (role == 'admin' || role == 'superadmin') {
      final admin = await Admin.findById(id);
      if (admin == null) return ApiResponse.unauthorized('Admin not found');
      return ApiResponse.success('Token is valid', data: {'admin': admin.toJson(), 'role': role});
    }

    final user = await User.findById(id);
    if (user == null) return ApiResponse.unauthorized('User not found');
    return ApiResponse.success('Token is valid', data: {'user': user.toJson(), 'role': role});
  } catch (e) {
    print('Verify error: $e');
    return ApiResponse.error('Internal server error');
  }
}
