import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'package:hushryd_backend_dart/config/env.dart';
import 'package:hushryd_backend_dart/middleware/cors_middleware.dart';
import 'package:hushryd_backend_dart/middleware/logger_middleware.dart';
import 'package:hushryd_backend_dart/middleware/rate_limiter.dart';
import 'package:hushryd_backend_dart/middleware/auth_middleware.dart';
import 'package:hushryd_backend_dart/routes/auth_routes.dart';
import 'package:hushryd_backend_dart/routes/user_routes.dart';
import 'package:hushryd_backend_dart/routes/admin_routes.dart';
import 'package:hushryd_backend_dart/routes/ride_routes.dart';
import 'package:hushryd_backend_dart/routes/booking_routes.dart';
import 'package:hushryd_backend_dart/routes/dashboard_routes.dart';
import 'package:hushryd_backend_dart/routes/database_routes.dart';
import 'package:hushryd_backend_dart/routes/offer_routes.dart';
import 'package:hushryd_backend_dart/routes/sms_gateway_routes.dart';

void main(List<String> args) async {
  Env.load();

  final app = Router();

  // Health check
  app.get('/api/health', (Request request) {
    return Response.ok(
        '{"status":"ok","timestamp":"${DateTime.now().toIso8601String()}"}',
        headers: {'content-type': 'application/json'});
  });

  // Mount route groups
  app.mount('/api/auth/', AuthRoutes().router.call);
  app.mount('/api/users/', UserRoutes().router.call);
  app.mount('/api/admins/', AdminRoutes().router.call);
  app.mount('/api/rides/', RideRoutes().router.call);
  app.mount('/api/bookings/', BookingRoutes().router.call);
  app.mount('/api/dashboard/', DashboardRoutes().router.call);
  app.mount('/api/database/', DatabaseRoutes().router.call);
  app.mount('/api/offers/', OfferRoutes().router.call);
  app.mount('/api/sms-gateway/', SmsGatewayRoutes().router.call);

  // Build pipeline with middleware
  final handler = Pipeline()
      .addMiddleware(loggerMiddleware())
      .addMiddleware(corsMiddleware())
      .addMiddleware(securityHeaders())
      .addMiddleware(rateLimiter())
      .addHandler(app.call);

  final port = Env.port;
  final server =
      await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  print('HushRyd Backend (Dart) running on http://localhost:${server.port}');
}
