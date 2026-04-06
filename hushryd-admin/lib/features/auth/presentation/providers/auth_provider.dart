import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../domain/admin_model.dart';
import '../../data/auth_repository.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/security/secure_storage.dart';

class AuthState {
  final AdminUser? admin;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.admin,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    AdminUser? admin,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      admin: admin ?? this.admin,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repo.adminLogin(email, password);
      if (result['error'] == true) {
        state = state.copyWith(
            isLoading: false, error: result['message'] as String?);
        return false;
      }
      final data = result['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final adminJson = data['admin'] as Map<String, dynamic>;
      final admin = AdminUser.fromJson(adminJson);

      await SecureStorage.setToken(token);
      await SecureStorage.setAdminData(jsonEncode(adminJson));

      state = state.copyWith(
        admin: admin,
        isLoading: false,
        isAuthenticated: true,
      );
      return true;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Login failed';
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> checkAuth() async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      state = const AuthState();
      return;
    }

    final expired = await SecureStorage.isSessionExpired();
    if (expired) {
      await logout();
      return;
    }

    final adminData = await SecureStorage.getAdminData();
    if (adminData != null) {
      final admin = AdminUser.fromJson(jsonDecode(adminData));
      state = AuthState(admin: admin, isAuthenticated: true);
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    await SecureStorage.clearAll();
    state = const AuthState();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(dioProvider));
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});
