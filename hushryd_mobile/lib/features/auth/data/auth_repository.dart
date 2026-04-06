import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api.dart';
import '../../../core/network/api_client.dart';
import '../../../core/security/secure_storage.dart';

final authRepositoryProvider = Provider<AuthRepository>(
    (ref) => AuthRepository(ref.read(apiClientProvider)));

class AuthRepository {
  final ApiClient _api;
  AuthRepository(this._api);

  Future<ApiResponse> sendOtp(String mobile) =>
      _api.post(ApiEndpoints.sendOtp, data: {'mobileNumber': mobile});

  Future<ApiResponse> verifyOtp(String mobile, String otp) =>
      _api.post(ApiEndpoints.verifyOtp, data: {'mobileNumber': mobile, 'otp': otp});

  Future<ApiResponse> register(Map<String, dynamic> data) =>
      _api.post(ApiEndpoints.register, data: data);

  Future<ApiResponse> login(String email, String password) =>
      _api.post(ApiEndpoints.login, data: {'email': email, 'password': password});

  Future<ApiResponse> getProfile() => _api.get(ApiEndpoints.userMe);

  Future<ApiResponse> updateProfile(Map<String, dynamic> data) =>
      _api.put(ApiEndpoints.userMe, data: data);

  Future<void> saveSession(String token, Map<String, dynamic> user) async {
    await SecureStorage.saveToken(token);
    await SecureStorage.saveUserData(jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getSavedUser() async {
    final data = await SecureStorage.getUserData();
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  Future<void> logout() => SecureStorage.clearAll();
}
