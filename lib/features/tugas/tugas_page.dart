import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/api/api_error.dart';
import '../../shared/widgets/message_view.dart';
import 'tugas.dart';
import 'tugas_repository.dart';
import 'widgets/stat_card.dart';
import 'widgets/task_card.dart';

class TugasPage extends ConsumerWidget {
  const TugasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(tugasListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Tugas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tugas/form'),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Tugas'),
      ),
      body: list.when(
        // skipLoadingOnRefresh (default) menjaga daftar tetap tampil saat refresh.
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => MessageView(
          icon: Icons.cloud_off,
          text: parseApiError(e),
          action: FilledButton(
            onPressed: () => ref.invalidate(tugasListProvider),
            child: const Text('Coba lagi'),
          ),
        ),
        data: (items) => RefreshIndicator(
          onRefresh: () => ref.refresh(tugasListProvider.future),
          child: items.isEmpty
              ? const MessageView(icon: Icons.inbox_outlined, text: 'Belum ada tugas.')
              : _TugasList(items),
        ),
      ),
    );
  }
}

class _TugasList extends StatelessWidget {
  const _TugasList(this.items);
  final List<Tugas> items;

  @override
  Widget build(BuildContext context) {
    // where() mempertahankan urutan dari API.
    List<Tugas> by(DeadlineCategory c) => items.where((t) => t.category == c).toList();
    final mendekati = by(DeadlineCategory.mendekati);
    final overdue = by(DeadlineCategory.overdue);
    final lainnya = items.where((t) =>
        t.category != DeadlineCategory.mendekati && t.category != DeadlineCategory.overdue).toList();

    Iterable<Widget> section(String title, List<Tugas> l) => l.isEmpty
        ? const []
        : [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 8),
              child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            ),
            for (final t in l) Padding(padding: const EdgeInsets.only(bottom: 12), child: TaskCard(tugas: t)),
          ];

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          Expanded(child: StatCard(label: 'Mendekati', count: mendekati.length, color: AppColors.mendekati)),
          const SizedBox(width: 8),
          Expanded(child: StatCard(label: 'Terlambat', count: overdue.length, color: AppColors.overdueBadge)),
          const SizedBox(width: 8),
          Expanded(child: StatCard(label: 'Lainnya', count: lainnya.length, color: AppColors.primary)),
        ]),
        ...section('Mendekati', mendekati),
        ...section('Terlambat', overdue),
        ...section('Lainnya', lainnya),
      ],
    );
  }
}
