import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:hushryd_backend/models/user.dart';
import 'package:hushryd_backend/middleware/auth.dart';
import 'package:hushryd_backend/utils/response.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final payload = extractTokenPayload(context);
  if (payload == null) return ApiResponse.unauthorized('No token');
  final role = payload['role']?.toString() ?? '';
  final userId = payload['id']?.toString() ?? '';

  switch (context.request.method) {
    case HttpMethod.get:
      if (role != 'admin' && role != 'superadmin' && userId != id) {
        return ApiResponse.forbidden('Access denied');
      }
      final user = await User.findById(id);
      if (user == null) return ApiResponse.notFound('User not found');
      return ApiResponse.success('User retrieved', data: {'user': user.toJson()});

    case HttpMethod.put:
      if (role != 'admin' && role != 'superadmin' && userId != id) {
        return ApiResponse.forbidden('Access denied');
      }
      final user = await User.findById(id);
      if (user == null) return ApiResponse.notFound('User not found');
      final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;
      if (role != 'admin' && role != 'superadmin') { body.remove('role'); body.remove('isActive'); }
      final updated = await user.update(body);
      return ApiResponse.success('User updated', data: {'user': updated.toJson()});

    case HttpMethod.delete:
      if (!hasRole(payload, ['superadmin', 'admin'])) return ApiResponse.forbidden('Access denied');
      final user = await User.findById(id);
      if (user == null) return ApiResponse.notFound('User not found');
      await user.delete();
      return ApiResponse.success('User deleted');

    default:
      return ApiResponse.error('Method not allowed', statusCode: 405);
  }
}
