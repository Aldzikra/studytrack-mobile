import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studytrack_mobile/features/tugas/tugas.dart';
import 'package:studytrack_mobile/features/tugas/widgets/task_card.dart';
import 'package:studytrack_mobile/shared/motion/motion.dart';

Tugas _t({String status = 'belum', String? cat, int jam = 5}) => Tugas.fromJson({
      'id': 1,
      'judul': 'Laporan Akhir',
      'deskripsi': '',
      'deadline': DateTime.now().toUtc().add(Duration(hours: jam)).toIso8601String(),
      'status': status,
      'matkul_id': 1,
      'matkul_nama': 'Basis Data',
      'created_at': '2026-06-30T01:00:00Z',
      'deadline_category': ?cat,
    });

Widget _app(Widget child, {bool disableAnimations = false}) => ProviderScope(
      child: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child))),
      ),
    );

void main() {
  final cases = <String, (Tugas, List<String>)>{
    'normal': (_t(cat: 'normal'), ['Belum', 'Tandai selesai']),
    'mendekati': (_t(cat: 'mendekati'), ['Sisa', 'Belum', 'Tandai selesai']),
    'overdue': (_t(cat: 'overdue', jam: -3), ['Terlambat', 'Belum', 'Tandai selesai']),
    'selesai': (_t(status: 'selesai', cat: 'overdue', jam: -3), ['Selesai', 'Batalkan']),
  };

  cases.forEach((name, c) {
    testWidgets('TaskCard $name ter-render', (tester) async {
      await tester.pumpWidget(_app(TaskCard(tugas: c.$1)));
      expect(find.text('Laporan Akhir'), findsOneWidget);
      for (final s in c.$2) {
        expect(find.textContaining(s), findsWidgets, reason: s);
      }
    });
  });

  testWidgets('selesai tidak menampilkan badge Terlambat', (tester) async {
    await tester.pumpWidget(_app(TaskCard(tugas: cases['selesai']!.$1)));
    expect(find.textContaining('Terlambat'), findsNothing);
  });

  testWidgets('FadeUp & Pop: animasi jalan sampai selesai', (tester) async {
    await tester.pumpWidget(_app(const Column(children: [
      FadeUp(child: Text('a')),
      Pop(child: Text('b')),
    ])));
    expect(tester.widget<Opacity>(find.byType(Opacity).first).opacity, 0);
    await tester.pumpAndSettle();
    expect(tester.widget<Opacity>(find.byType(Opacity).first).opacity, 1);
  });

  testWidgets('disableAnimations: langsung tampil tanpa Opacity/animasi', (tester) async {
    await tester.pumpWidget(_app(
      const Column(children: [FadeUp(child: Text('a')), Pop(child: Text('b'))]),
      disableAnimations: true,
    ));
    expect(find.byType(Opacity), findsNothing);
    expect(find.text('a'), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('PressScale tidak error saat ditekan (reduced motion)', (tester) async {
    await tester.pumpWidget(_app(
      PressScale(child: FilledButton(onPressed: () {}, child: const Text('Tekan'))),
      disableAnimations: true,
    ));
    final g = await tester.startGesture(tester.getCenter(find.text('Tekan')));
    await tester.pump();
    await g.up();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
