import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

class ApiResponse {
  static Response success(String message,
      {Map<String, dynamic>? data, int statusCode = 200}) {
    final body = <String, dynamic>{'error': false, 'message': message};
    if (data != null) body['data'] = data;
    return Response(statusCode: statusCode, body: jsonEncode(body),
        headers: {'content-type': 'application/json'});
  }

  static Response created(String message, {Map<String, dynamic>? data}) =>
      success(message, data: data, statusCode: 201);

  static Response error(String message,
      {int statusCode = 500, String? details}) {
    final body = <String, dynamic>{'error': true, 'message': message};
    if (details != null) body['details'] = details;
    return Response(statusCode: statusCode, body: jsonEncode(body),
        headers: {'content-type': 'application/json'});
  }

  static Response notFound(String msg) => error(msg, statusCode: 404);
  static Response badRequest(String msg) => error(msg, statusCode: 400);
  static Response unauthorized(String msg) => error(msg, statusCode: 401);
  static Response forbidden(String msg) => error(msg, statusCode: 403);
  static Response conflict(String msg) => error(msg, statusCode: 409);
}
