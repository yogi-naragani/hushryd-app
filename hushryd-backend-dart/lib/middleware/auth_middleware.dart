import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../config/env.dart';
import '../utils/response.dart';

/// Extracts and verifies JWT from Authorization header.
/// Sets 'userId', 'userEmail', 'userRole' in request context.
Middleware authenticateToken() {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return ApiResponse.error('Access denied. No token provided.',
            statusCode: 401);
      }

      final token = authHeader.substring(7);
      try {
        final jwt = JWT.verify(token, SecretKey(Env.jwtSecret));
        final payload = jwt.payload as Map<String, dynamic>;

        final updatedRequest = request.change(context: {
          'userId': payload['id'] ?? payload['userId'] ?? '',
          'userEmail': payload['email'] ?? '',
          'userRole': payload['role'] ?? 'user',
        });

        return innerHandler(updatedRequest);
      } on JWTExpiredException {
        return ApiResponse.error('Token expired', statusCode: 401);
      } on JWTException {
        return ApiResponse.error('Invalid token', statusCode: 401);
      }
    };
  };
}

/// Authenticates admin users specifically.
Middleware authenticateAdmin() {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return ApiResponse.error('Access denied. No token provided.',
            statusCode: 401);
      }

      final token = authHeader.substring(7);
      try {
        final jwt = JWT.verify(token, SecretKey(Env.jwtSecret));
        final payload = jwt.payload as Map<String, dynamic>;

        final updatedRequest = request.change(context: {
          'adminId': payload['id'] ?? payload['adminId'] ?? '',
          'adminEmail': payload['email'] ?? '',
          'adminRole': payload['role'] ?? 'admin',
        });

        return innerHandler(updatedRequest);
      } on JWTExpiredException {
        return ApiResponse.error('Token expired', statusCode: 401);
      } on JWTException {
        return ApiResponse.error('Invalid token', statusCode: 401);
      }
    };
  };
}

/// Checks if the admin has one of the required roles.
Middleware requireRole(List<String> roles) {
  return (Handler innerHandler) {
    return (Request request) async {
      final role = (request.context['adminRole'] ??
              request.context['userRole'] ??
              '') as String;

      if (!roles.contains(role)) {
        return ApiResponse.error('Access denied. Insufficient permissions.',
            statusCode: 403);
      }

      return innerHandler(request);
    };
  };
}

/// Security headers middleware (equivalent to helmet.js).
Middleware securityHeaders() {
  return (Handler innerHandler) {
    return (Request request) async {
      final response = await innerHandler(request);
      return response.change(headers: {
        'X-Content-Type-Options': 'nosniff',
        'X-Frame-Options': 'DENY',
        'X-XSS-Protection': '1; mode=block',
        'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
        'Referrer-Policy': 'no-referrer',
      });
    };
  };
}

/// Helper to parse JSON body from request.
Future<Map<String, dynamic>> parseJsonBody(Request request) async {
  final body = await request.readAsString();
  if (body.isEmpty) return {};
  return jsonDecode(body) as Map<String, dynamic>;
}
