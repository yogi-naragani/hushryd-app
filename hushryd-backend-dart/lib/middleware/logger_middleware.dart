import 'package:shelf/shelf.dart';

Middleware loggerMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final stopwatch = Stopwatch()..start();
      final response = await innerHandler(request);
      stopwatch.stop();

      print(
          '[${DateTime.now().toIso8601String()}] ${request.method} ${request.requestedUri.path} '
          '-> ${response.statusCode} (${stopwatch.elapsedMilliseconds}ms)');

      return response;
    };
  };
}
