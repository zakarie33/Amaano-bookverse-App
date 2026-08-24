import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';

  Future<void> saveAuthToken(String token) =>
      _storage.write(key: _keyAuthToken, value: token);

  Future<String?> getAuthToken() => _storage.read(key: _keyAuthToken);

  Future<void> saveUserId(String userId) =>
      _storage.write(key: _keyUserId, value: userId);

  Future<String?> getUserId() => _storage.read(key: _keyUserId);

  Future<void> saveUserName(String name) =>
      _storage.write(key: _keyUserName, value: name);

  Future<String?> getUserName() => _storage.read(key: _keyUserName);

  Future<void> saveUserEmail(String email) =>
      _storage.write(key: _keyUserEmail, value: email);

  Future<String?> getUserEmail() => _storage.read(key: _keyUserEmail);

  Future<void> clearSession() async {
    await _storage.delete(key: _keyAuthToken);
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyUserName);
    await _storage.delete(key: _keyUserEmail);
  }
}
