import 'dart:async';
import 'package:shelf/shelf.dart';
import '../config/env.dart';
import '../utils/response.dart';

class _RateEntry {
  int count;
  DateTime windowStart;
  _RateEntry(this.count, this.windowStart);
}

Middleware rateLimiter() {
  final store = <String, _RateEntry>{};
  final maxRequests = Env.rateLimitMax;
  final windowMs = Env.rateLimitWindowMs;

  // Cleanup old entries every 5 minutes
  Timer.periodic(Duration(minutes: 5), (_) {
    final now = DateTime.now();
    store.removeWhere(
        (_, entry) => now.difference(entry.windowStart).inMilliseconds > windowMs);
  });

  return (Handler innerHandler) {
    return (Request request) async {
      final ip = request.headers['x-forwarded-for'] ??
          request.headers['x-real-ip'] ??
          'unknown';

      final now = DateTime.now();
      final entry = store[ip];

      if (entry == null ||
          now.difference(entry.windowStart).inMilliseconds > windowMs) {
        store[ip] = _RateEntry(1, now);
      } else {
        entry.count++;
        if (entry.count > maxRequests) {
          return ApiResponse.error('Too many requests', statusCode: 429);
        }
      }

      return innerHandler(request);
    };
  };
}
