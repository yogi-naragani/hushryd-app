import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:hushryd_backend/models/user.dart';
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

    final user = await User.findByEmail(email);
    if (user == null) return ApiResponse.unauthorized('Invalid email or password');

    final passResult = await Database.query(
      'SELECT password_hash FROM user_passwords WHERE user_id = :id', {'id': user.id});
    final rows = passResult.rows.toList();
    if (rows.isEmpty) return ApiResponse.unauthorized('Invalid email or password');

    final hash = rows.first.assoc()['password_hash'] ?? '';
    if (!BCrypt.checkpw(password, hash)) {
      return ApiResponse.unauthorized('Invalid email or password');
    }

    final token = generateToken({'id': user.id, 'email': user.email, 'role': user.role});
    return ApiResponse.success('Login successful', data: {'user': user.toJson(), 'token': token});
  } catch (e) {
    print('Login error: $e');
    return ApiResponse.error('Internal server error');
  }
}
