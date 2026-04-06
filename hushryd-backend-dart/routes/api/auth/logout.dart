import 'package:dart_frog/dart_frog.dart';
import 'package:hushryd_backend/utils/response.dart';

Response onRequest(RequestContext context) {
  return ApiResponse.success('Logged out successfully');
}
