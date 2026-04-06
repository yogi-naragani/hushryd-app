import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:hushryd_backend/models/admin.dart';
import 'package:hushryd_backend/middleware/auth.dart';
import 'package:hushryd_backend/utils/response.dart';
import 'package:hushryd_backend/utils/validators.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return ApiResponse.error('Method not allowed', statusCode: 405);
  }
  try {
    final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;
    final missing = Validators.validateRequired(body, ['email', 'password', 'firstName', 'lastName']);
    if (missing != null) return ApiResponse.badRequest(missing);

    final existing = await Admin.findByEmail(body['email'] as String);
    if (existing != null) return ApiResponse.conflict('Admin with this email already exists');

    final hashedPassword = BCrypt.hashpw(body['password'] as String, BCrypt.gensalt());
    final admin = await Admin.create({
      'id': const Uuid().v4(), 'email': body['email'], 'password': hashedPassword,
      'firstName': body['firstName'], 'lastName': body['lastName'],
      'role': body['role'] ?? 'admin', 'permissions': body['permissions'] ?? <String>[],
      'isActive': true,
    });

    final token = generateToken({
      'id': admin.id, 'email': admin.email, 'role': admin.role, 'adminId': admin.id,
    });

    return ApiResponse.created('Admin created successfully',
        data: {'admin': admin.toJson(), 'token': token});
  } catch (e) {
    print('Admin create error: $e');
    return ApiResponse.error('Internal server error');
  }
}
