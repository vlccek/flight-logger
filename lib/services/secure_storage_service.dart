import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final _storage = const FlutterSecureStorage();

  Future<void> saveEmail(String email) async {
    await _storage.write(key: 'email', value: email);
  }

  Future<String?> getEmail() async {
    return await _storage.read(key: 'email');
  }

  Future<void> deleteEmail() async {
    await _storage.delete(key: 'email');
  }

  Future<void> savePassword(String password) async {
    await _storage.write(key: 'password', value: password);
  }

  Future<String?> getPassword() async {
    return await _storage.read(key: 'password');
  }

  Future<void> deletePassword() async {
    await _storage.delete(key: 'password');
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'token');
  }

  Future<void> saveApiUrl(String apiUrl) async {
    await _storage.write(key: 'api_url', value: apiUrl);
  }

  Future<String?> getApiUrl() async {
    return await _storage.read(key: 'api_url');
  }
}
