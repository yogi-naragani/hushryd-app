import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:hushryd_backend/models/user.dart';
import 'package:hushryd_backend/middleware/auth.dart';
import 'package:hushryd_backend/utils/response.dart';

Future<Response> onRequest(RequestContext context) async {
  final payload = extractTokenPayload(context);
  if (payload == null) return ApiResponse.unauthorized('No token');
  final userId = payload['id']?.toString() ?? '';

  switch (context.request.method) {
    case HttpMethod.get:
      final user = await User.findById(userId);
      if (user == null) return ApiResponse.notFound('User not found');
      return ApiResponse.success('User profile retrieved', data: {'user': user.toJson()});
    case HttpMethod.put:
      final user = await User.findById(userId);
      if (user == null) return ApiResponse.notFound('User not found');
      final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;
      final updates = <String, dynamic>{};
      for (final k in ['firstName','lastName','email','phone','emergencyContact','address','city','state','pincode','bio']) {
        if (body.containsKey(k) && body[k] != null) updates[k] = body[k];
      }
      if (body['avatar'] != null) updates['profileImage'] = body['avatar'];
      final updated = await user.update(updates);
      return ApiResponse.success('Profile updated', data: {'user': updated.toJson()});
    default:
      return ApiResponse.error('Method not allowed', statusCode: 405);
  }
}
