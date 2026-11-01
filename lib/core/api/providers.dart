import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_controller.dart';
import '../storage/token_storage.dart';
import 'api_client.dart';

final tokenStorageProvider = Provider((_) => TokenStorage());
final apiClientProvider = Provider((ref) => ApiClient(
      ref.watch(tokenStorageProvider),
      onUnauthorized: () =>
          ref.read(authControllerProvider.notifier).sessionExpired(),
    ));
