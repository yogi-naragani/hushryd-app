import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';

class AuthState {
  final Map<String, dynamic>? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.isAuthenticated = false, this.error});

  AuthState copyWith({Map<String, dynamic>? user, bool? isLoading, bool? isAuthenticated, String? error}) =>
      AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        error: error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState()) {
    _loadSavedSession();
  }

  Future<void> _loadSavedSession() async {
    state = state.copyWith(isLoading: true);
    final user = await _repo.getSavedUser();
    if (user != null) {
      state = AuthState(user: user, isAuthenticated: true);
    } else {
      state = const AuthState();
    }
  }

  Future<String?> sendOtp(String mobile) async {
    state = state.copyWith(isLoading: true, error: null);
    final res = await _repo.sendOtp(mobile);
    state = state.copyWith(isLoading: false);
    if (!res.success) return res.message;
    return null;
  }

  Future<String?> verifyOtp(String mobile, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    final res = await _repo.verifyOtp(mobile, otp);
    if (!res.success) {
      state = state.copyWith(isLoading: false, error: res.message);
      return res.message;
    }
    final data = res.data as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = data['user'] as Map<String, dynamic>;
    await _repo.saveSession(token, user);
    state = AuthState(user: user, isAuthenticated: true);
    return null;
  }

  Future<String?> loginWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final res = await _repo.login(email, password);
    if (!res.success) {
      state = state.copyWith(isLoading: false, error: res.message);
      return res.message;
    }
    final data = res.data as Map<String, dynamic>;
    await _repo.saveSession(data['token'] as String, data['user'] as Map<String, dynamic>);
    state = AuthState(user: data['user'] as Map<String, dynamic>, isAuthenticated: true);
    return null;
  }

  Future<String?> register(Map<String, dynamic> userData) async {
    state = state.copyWith(isLoading: true, error: null);
    final res = await _repo.register(userData);
    if (!res.success) {
      state = state.copyWith(isLoading: false, error: res.message);
      return res.message;
    }
    final data = res.data as Map<String, dynamic>;
    await _repo.saveSession(data['token'] as String, data['user'] as Map<String, dynamic>);
    state = AuthState(user: data['user'] as Map<String, dynamic>, isAuthenticated: true);
    return null;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final res = await _repo.updateProfile(data);
    if (res.success && res.data != null) {
      final updated = (res.data as Map<String, dynamic>)['user'] as Map<String, dynamic>;
      await _repo.saveSession('', updated); // token unchanged
      state = state.copyWith(user: updated);
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }

  String get userName {
    if (state.user == null) return 'Guest';
    return '${state.user!['firstName'] ?? ''} ${state.user!['lastName'] ?? ''}'.trim();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
    (ref) => AuthNotifier(ref.read(authRepositoryProvider)));
