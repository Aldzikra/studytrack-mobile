import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/api/api_error.dart';
import '../../core/utils/date_format.dart';
import '../../shared/motion/motion.dart';
import '../../shared/widgets/app_header.dart';
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
      body: Column(children: [
        const AppHeader(),
        Expanded(
          child: Stack(children: [
            list.when(
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
            const Positioned(right: 20, bottom: 20, child: Pop(child: _Fab())),
          ]),
        ),
      ]),
    );
  }
}

/// Kotak 56, radius 18 (sama dengan FAB web).
class _Fab extends StatelessWidget {
  const _Fab();

  @override
  Widget build(BuildContext context) => PressScale(
        child: Semantics(
          button: true,
          label: 'Tambah tugas',
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [BoxShadow(color: Color(0x591A5FD6), blurRadius: 20, offset: Offset(0, 8))],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => context.push('/tugas/form'),
                child: const Icon(Icons.add, size: 24, color: Colors.white),
              ),
            ),
          ),
        ),
      );
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
    final lainnya = items
        .where((t) => t.category != DeadlineCategory.mendekati && t.category != DeadlineCategory.overdue)
        .toList();

    List<Widget> section(String title, Color color, List<Tugas> l) => l.isEmpty
        ? const []
        : [
            const SizedBox(height: 20),
            Text(title.toUpperCase(),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.72, color: color)),
            const SizedBox(height: 10),
            for (var i = 0; i < l.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: i == l.length - 1 ? 0 : 10),
                child: FadeUp.item(key: ValueKey(l[i].id), index: i, child: TaskCard(tugas: l[i])),
              ),
          ];

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      // bawah: FAB 56 + jarak 20 + 20 agar card terakhir tidak tertutup.
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
      children: [
        FadeUp(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(formatWibLong(DateTime.now()),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted)),
            const SizedBox(height: 4),
            const Text('Daftar Tugas',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          ]),
        ),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
            child: StatCard(
              label: 'Mendekati',
              count: mendekati.length,
              background: AppColors.mendekatiBg,
              border: AppColors.mendekatiBorder,
              numberColor: AppColors.mendekatiFg,
              labelColor: const Color(0xFF7A2E00),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(
              label: 'Terlambat',
              count: overdue.length,
              background: AppColors.overdueChipBg,
              border: AppColors.overdueChipBorder,
              numberColor: AppColors.overdueFg,
              labelColor: AppColors.overdueFg,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(
              label: 'Lainnya',
              count: lainnya.length,
              background: Colors.white,
              border: AppColors.border,
              numberColor: AppColors.primary,
              labelColor: AppColors.text2,
            ),
          ),
        ]),
        ...section('Mendekati deadline', AppColors.mendekatiFg, mendekati),
        ...section('Terlambat', AppColors.overdueFg, overdue),
        ...section('Tugas lainnya', AppColors.text2, lainnya),
      ],
    );
  }
}
