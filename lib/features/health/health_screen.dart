import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_error.dart';
import '../../core/api/providers.dart';

final _healthProvider = FutureProvider.autoDispose<String>((ref) async {
  final res = await ref.watch(apiClientProvider).dio.get('/health');
  final d = res.data as Map;
  return '${d['status']} · db: ${d['database']}\n${d['message']}';
});

// Layar sementara Fase 0, untuk cek koneksi.
class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(_healthProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('StudyTrack')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: health.when(
            loading: () => const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Menghubungi server…'),
              ],
            ),
            error: (e, _) => Text(parseApiError(e), textAlign: TextAlign.center),
            data: (m) => Text(m, textAlign: TextAlign.center),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ref.invalidate(_healthProvider),
        icon: const Icon(Icons.refresh),
        label: const Text('Cek ulang'),
      ),
    );
  }
}
