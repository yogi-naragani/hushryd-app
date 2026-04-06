import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:hushryd_backend/models/admin.dart';
import 'package:hushryd_backend/middleware/auth.dart';
import 'package:hushryd_backend/utils/response.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final payload = extractTokenPayload(context);
  if (payload == null) return ApiResponse.unauthorized('No token');
  if (!hasRole(payload, ['superadmin', 'admin'])) return ApiResponse.forbidden('Access denied');

  switch (context.request.method) {
    case HttpMethod.get:
      final admin = await Admin.findById(id);
      if (admin == null) return ApiResponse.notFound('Admin not found');
      return ApiResponse.success('Admin retrieved', data: {'admin': admin.toJson()});

    case HttpMethod.put:
      final adminRole = payload['role']?.toString() ?? '';
      final adminId = payload['id']?.toString() ?? '';
      if (adminRole != 'superadmin' && adminId != id) return ApiResponse.forbidden('Access denied');
      final admin = await Admin.findById(id);
      if (admin == null) return ApiResponse.notFound('Admin not found');
      final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;
      if (adminRole != 'superadmin') { body.remove('role'); body.remove('permissions'); }
      final updated = await admin.update(body);
      return ApiResponse.success('Admin updated', data: {'admin': updated.toJson()});

    case HttpMethod.delete:
      if (!hasRole(payload, ['superadmin'])) return ApiResponse.forbidden('Access denied');
      if (payload['id'] == id) return ApiResponse.badRequest('Cannot delete yourself');
      final admin = await Admin.findById(id);
      if (admin == null) return ApiResponse.notFound('Admin not found');
      await admin.delete();
      return ApiResponse.success('Admin deleted');

    default:
      return ApiResponse.error('Method not allowed', statusCode: 405);
  }
}
