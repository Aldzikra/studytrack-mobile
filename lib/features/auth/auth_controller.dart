import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/providers.dart';
import 'auth_repository.dart';
import 'user.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(
      ref.watch(apiClientProvider),
      ref.watch(tokenStorageProvider),
    ));

/// State = user yang login (null = belum login). Loading = cek token awal.
class AuthController extends AsyncNotifier<User?> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Future<User?> build() => _repo.restore();

  /// Melempar error API; pemanggil menampilkan lewat parseApiError.
  Future<void> login(String email, String password) async {
    state = AsyncData(await _repo.login(email, password));
  }

  Future<void> register(String username, String email, String password) =>
      _repo.register(username, email, password);

  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncData(null);
  }

  /// Token sudah dihapus oleh ApiClient (401).
  void sessionExpired() => state = const AsyncData(null);
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, User?>(AuthController.new);
