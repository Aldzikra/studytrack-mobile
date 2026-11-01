import 'dart:convert';

import '../../core/api/api_client.dart';
import '../../core/storage/token_storage.dart';
import 'user.dart';

class AuthRepository {
  AuthRepository(this._api, this._storage);
  final ApiClient _api;
  final TokenStorage _storage;

  /// User tersimpan bila token ada; selain itu null (belum login).
  Future<User?> restore() async {
    try {
      final token = await _storage.read();
      final json = await _storage.readUser();
      if (token == null || json == null) return null;
      return User.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      await _storage.clear();
      return null;
    }
  }

  Future<User> login(String email, String password) async {
    final res = await _api.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final data = res.data as Map<String, dynamic>;
    final user = User.fromJson(data['user'] as Map<String, dynamic>);
    await _storage.write(data['token'] as String);
    await _storage.writeUser(jsonEncode(user.toJson()));
    return user;
  }

  Future<User> register(String username, String email, String password) async {
    final res = await _api.dio.post('/auth/register', data: {
      'username': username,
      'email': email,
      'password': password,
    });
    return User.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> logout() => _storage.clear();
}
