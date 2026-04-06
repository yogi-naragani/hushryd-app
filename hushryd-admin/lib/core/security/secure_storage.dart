import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _adminKey = 'admin_data';
  static const _lastActivityKey = 'last_activity';

  static Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    await updateLastActivity();
  }

  static Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  static Future<void> setAdminData(String jsonData) async {
    await _storage.write(key: _adminKey, value: jsonData);
  }

  static Future<String?> getAdminData() async {
    return _storage.read(key: _adminKey);
  }

  static Future<void> updateLastActivity() async {
    await _storage.write(
      key: _lastActivityKey,
      value: DateTime.now().toIso8601String(),
    );
  }

  static Future<bool> isSessionExpired({int timeoutMinutes = 30}) async {
    final lastActivity = await _storage.read(key: _lastActivityKey);
    if (lastActivity == null) return true;
    final last = DateTime.parse(lastActivity);
    return DateTime.now().difference(last).inMinutes > timeoutMinutes;
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
