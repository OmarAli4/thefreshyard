import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
                resetOnError: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  static const String _keyCustomerToken = 'customer_access_token';
  static const String _keyCustomerEmail = 'customer_email';
  static const String _keyCustomerPassword = 'customer_password';

  Future<void> saveCustomerToken(String token) async {
    try {
      await _storage.write(key: _keyCustomerToken, value: token);
    } catch (_) {
      try {
        await _storage.deleteAll();
        await _storage.write(key: _keyCustomerToken, value: token);
      } catch (_) {}
    }
  }

  Future<String?> getCustomerToken() async {
    try {
      return await _storage.read(key: _keyCustomerToken);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCredentials(String email, String password) async {
    try {
      await _storage.write(key: _keyCustomerEmail, value: email);
      await _storage.write(key: _keyCustomerPassword, value: password);
    } catch (_) {}
  }

  Future<Map<String, String>?> getCredentials() async {
    try {
      final email = await _storage.read(key: _keyCustomerEmail);
      final password = await _storage.read(key: _keyCustomerPassword);
      if (email != null && password != null) {
        return {'email': email, 'password': password};
      }
    } catch (_) {}
    return null;
  }

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (_) {}
  }
}
