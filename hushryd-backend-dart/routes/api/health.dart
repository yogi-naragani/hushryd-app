import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response(
    body: jsonEncode({
      'status': 'ok',
      'timestamp': DateTime.now().toIso8601String(),
    }),
    headers: {'content-type': 'application/json'},
  );
}
