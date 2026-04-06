import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<Map<String, dynamic>> adminLogin(String email, String password) async {
    final response = await _dio.post(ApiEndpoints.adminLogin, data: {
      'email': email,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyToken() async {
    final response = await _dio.get(ApiEndpoints.verify);
    return response.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } catch (_) {}
  }

  Future<Map<String, dynamic>> changePassword(
      String currentPassword, String newPassword) async {
    final response = await _dio.put(ApiEndpoints.changePassword, data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
    return response.data as Map<String, dynamic>;
  }
}
