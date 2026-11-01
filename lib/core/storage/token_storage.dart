import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _key = 'auth_token';
  final _s = const FlutterSecureStorage();

  Future<String?> read() => _s.read(key: _key);
  Future<void> write(String token) => _s.write(key: _key, value: token);
  Future<void> clear() => _s.delete(key: _key);
}
