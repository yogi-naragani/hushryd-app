import 'dart:convert';
import 'package:shelf/shelf.dart';

/// Standardized API response helpers matching Express backend format:
/// { error: bool, message: string, data?: object }
class ApiResponse {
  static Response success(
    String message, {
    Map<String, dynamic>? data,
    int statusCode = 200,
  }) {
    final body = <String, dynamic>{
      'error': false,
      'message': message,
    };
    if (data != null) body['data'] = data;
    return Response(statusCode,
        body: jsonEncode(body),
        headers: {'content-type': 'application/json'});
  }

  static Response created(
    String message, {
    Map<String, dynamic>? data,
  }) {
    return success(message, data: data, statusCode: 201);
  }

  static Response error(
    String message, {
    int statusCode = 500,
    String? details,
  }) {
    final body = <String, dynamic>{
      'error': true,
      'message': message,
    };
    if (details != null) body['details'] = details;
    return Response(statusCode,
        body: jsonEncode(body),
        headers: {'content-type': 'application/json'});
  }

  static Response notFound(String message) =>
      error(message, statusCode: 404);

  static Response badRequest(String message) =>
      error(message, statusCode: 400);

  static Response unauthorized(String message) =>
      error(message, statusCode: 401);

  static Response forbidden(String message) =>
      error(message, statusCode: 403);

  static Response conflict(String message) =>
      error(message, statusCode: 409);
}
