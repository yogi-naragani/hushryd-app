import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:uuid/uuid.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:hushryd_backend/models/admin.dart';
import 'package:hushryd_backend/middleware/auth.dart';
import 'package:hushryd_backend/utils/response.dart';

Future<Response> onRequest(RequestContext context) async {
  final payload = extractTokenPayload(context);
  if (payload == null) return ApiResponse.unauthorized('No token');

  switch (context.request.method) {
    case HttpMethod.get:
      if (!hasRole(payload, ['superadmin', 'admin'])) return ApiResponse.forbidden('Access denied');
      final p = context.request.uri.queryParameters;
      final admins = await Admin.findAll(page: int.tryParse(p['page'] ?? '') ?? 1,
        limit: int.tryParse(p['limit'] ?? '') ?? 10, role: p['role'],
        isActive: p['isActive'] != null ? p['isActive'] == 'true' : null);
      return ApiResponse.success('Admins retrieved', data: {
        'admins': admins.map((a) => a.toJson()).toList(),
        'pagination': {'page': 1, 'limit': 10, 'total': admins.length}});

    case HttpMethod.post:
      if (!hasRole(payload, ['superadmin'])) return ApiResponse.forbidden('Access denied');
      final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;
      if (body['email'] == null || body['firstName'] == null || body['lastName'] == null || body['role'] == null) {
        return ApiResponse.badRequest('email, firstName, lastName, role required');
      }
      final existing = await Admin.findByEmail(body['email'] as String);
      if (existing != null) return ApiResponse.conflict('Admin already exists');
      final admin = await Admin.create({
        'id': const Uuid().v4(), 'email': body['email'],
        'password': BCrypt.hashpw('Password123!', BCrypt.gensalt()),
        'firstName': body['firstName'], 'lastName': body['lastName'],
        'role': body['role'], 'permissions': body['permissions'] ?? <String>[], 'isActive': true});
      return ApiResponse.created('Admin created', data: {'admin': admin.toJson()});

    default:
      return ApiResponse.error('Method not allowed', statusCode: 405);
  }
}
