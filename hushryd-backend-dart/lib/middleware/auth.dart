import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:hushryd_backend/config/env.dart';
import 'package:hushryd_backend/utils/response.dart';

/// Verify JWT and return error Response if invalid, null if valid.
Response? verifyToken(RequestContext context) {
  final authHeader = context.request.headers['authorization'];
  if (authHeader == null || !authHeader.startsWith('Bearer ')) {
    return ApiResponse.error('Access denied. No token provided.', statusCode: 401);
  }

  try {
    JWT.verify(authHeader.substring(7), SecretKey(Env.jwtSecret));
    return null; // success
  } on JWTExpiredException {
    return ApiResponse.error('Token expired', statusCode: 401);
  } on JWTException {
    return ApiResponse.error('Invalid token', statusCode: 401);
  }
}

/// Extract JWT payload from Authorization header.
Map<String, dynamic>? extractTokenPayload(RequestContext context) {
  final authHeader = context.request.headers['authorization'];
  if (authHeader == null || !authHeader.startsWith('Bearer ')) return null;

  try {
    final jwt = JWT.verify(authHeader.substring(7), SecretKey(Env.jwtSecret));
    return jwt.payload as Map<String, dynamic>;
  } catch (_) {
    return null;
  }
}

/// Generate a JWT token with 24h expiry.
String generateToken(Map<String, dynamic> payload) {
  final jwt = JWT(payload);
  return jwt.sign(SecretKey(Env.jwtSecret), expiresIn: Duration(hours: 24));
}

/// Check if user has one of the required roles.
bool hasRole(Map<String, dynamic>? payload, List<String> roles) {
  if (payload == null) return false;
  final role = payload['role'] as String? ?? '';
  return roles.contains(role);
}
