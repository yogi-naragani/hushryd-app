import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response(
    body: jsonEncode({
      'name': 'HushRyd API',
      'version': '1.0.0',
      'framework': 'Dart Frog',
      'database': 'MySQL',
    }),
    headers: {'content-type': 'application/json'},
  );
}
