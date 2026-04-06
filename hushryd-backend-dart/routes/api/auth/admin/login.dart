import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:hushryd_backend/models/admin.dart';
import 'package:hushryd_backend/config/database.dart';
import 'package:hushryd_backend/middleware/auth.dart';
import 'package:hushryd_backend/utils/response.dart';
import 'package:bcrypt/bcrypt.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return ApiResponse.error('Method not allowed', statusCode: 405);
  }
  try {
    final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;
    final email = body['email'] as String?;
    final password = body['password'] as String?;
    if (email == null || password == null) {
      return ApiResponse.badRequest('Email and password are required');
    }

    final admin = await Admin.findByEmail(email);
    if (admin == null) return ApiResponse.unauthorized('Invalid email or password');
    if (!admin.isActive) return ApiResponse.unauthorized('Account is deactivated');
    if (admin.password == null || !BCrypt.checkpw(password, admin.password!)) {
      return ApiResponse.unauthorized('Invalid email or password');
    }

    await Database.query(
      'UPDATE admins SET last_login = CURRENT_TIMESTAMP WHERE id = :id', {'id': admin.id});

    final token = generateToken({
      'id': admin.id, 'email': admin.email,
      'role': admin.role, 'adminId': admin.id,
    });

    return ApiResponse.success('Admin login successful',
        data: {'admin': admin.toJson(), 'token': token});
  } catch (e) {
    print('Admin login error: $e');
    return ApiResponse.error('Internal server error');
  }
}
