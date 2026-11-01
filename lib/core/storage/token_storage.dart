import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';
  final _s = const FlutterSecureStorage();

  Future<String?> read() => _s.read(key: _tokenKey);
  Future<void> write(String token) => _s.write(key: _tokenKey, value: token);

  Future<String?> readUser() => _s.read(key: _userKey);
  Future<void> writeUser(String json) => _s.write(key: _userKey, value: json);

  Future<void> clear() async {
    await _s.delete(key: _tokenKey);
    await _s.delete(key: _userKey);
  }
}
