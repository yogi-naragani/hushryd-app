import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:uuid/uuid.dart';
import 'package:hushryd_backend/models/user.dart';
import 'package:hushryd_backend/middleware/auth.dart';
import 'package:hushryd_backend/utils/response.dart';

Future<Response> onRequest(RequestContext context) async {
  final payload = extractTokenPayload(context);
  if (payload == null) return ApiResponse.unauthorized('No token');
  if (!hasRole(payload, ['superadmin', 'admin'])) {
    return ApiResponse.forbidden('Access denied');
  }

  switch (context.request.method) {
    case HttpMethod.get:
      return _getAll(context);
    case HttpMethod.post:
      return _create(context);
    default:
      return ApiResponse.error('Method not allowed', statusCode: 405);
  }
}

Future<Response> _getAll(RequestContext context) async {
  try {
    final params = context.request.uri.queryParameters;
    final page = int.tryParse(params['page'] ?? '') ?? 1;
    final limit = int.tryParse(params['limit'] ?? '') ?? 10;
    final users = await User.findAll(page: page, limit: limit,
      role: params['role'],
      isActive: params['isActive'] != null ? params['isActive'] == 'true' : null,
      isVerified: params['isVerified'] != null ? params['isVerified'] == 'true' : null);
    return ApiResponse.success('Users retrieved successfully', data: {
      'users': users.map((u) => u.toJson()).toList(),
      'pagination': {'page': page, 'limit': limit, 'total': users.length},
    });
  } catch (e) {
    return ApiResponse.error('Internal server error');
  }
}

Future<Response> _create(RequestContext context) async {
  try {
    final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;
    if (body['email'] == null || body['firstName'] == null) {
      return ApiResponse.badRequest('Email and firstName are required');
    }
    final existing = await User.findByEmail(body['email'] as String);
    if (existing != null) return ApiResponse.conflict('User already exists');
    final user = await User.create({'id': const Uuid().v4(), ...body});
    return ApiResponse.created('User created successfully', data: {'user': user.toJson()});
  } catch (e) {
    return ApiResponse.error('Internal server error');
  }
}
