import 'package:flutter_test/flutter_test.dart';
import 'package:studytrack_mobile/app/theme.dart';
import 'package:studytrack_mobile/features/tugas/tugas.dart';
import 'package:studytrack_mobile/features/tugas/tugas_style.dart';

Map<String, dynamic> _json({String status = 'belum', String? cat}) => {
      'id': 7,
      'judul': 'Laporan',
      'deskripsi': 'Bab 1',
      'deadline': '2026-07-02T03:00:00Z',
      'status': status,
      'matkul_id': 3,
      'matkul_nama': 'Basis Data',
      'created_at': '2026-06-30T01:00:00Z',
      'deadline_category': ?cat,
    };

void main() {
  group('Tugas.fromJson', () {
    test('lengkap dengan kategori', () {
      final t = Tugas.fromJson(_json(cat: 'mendekati'));
      expect(t.id, 7);
      expect(t.matkulNama, 'Basis Data');
      expect(t.deadline, DateTime.utc(2026, 7, 2, 3));
      expect(t.status, TugasStatus.belum);
      expect(t.category, DeadlineCategory.mendekati);
    });
    test('tanpa kategori → null; status selesai', () {
      final t = Tugas.fromJson(_json(status: 'selesai'));
      expect(t.category, isNull);
      expect(t.selesai, isTrue);
    });
  });

  group('cardKind / styleFor', () {
    TugasCardKind kind(String status, String? cat) =>
        cardKind(Tugas.fromJson(_json(status: status, cat: cat)));

    test('mapping kategori', () {
      expect(kind('belum', 'normal'), TugasCardKind.normal);
      expect(kind('belum', null), TugasCardKind.normal);
      expect(kind('belum', 'mendekati'), TugasCardKind.mendekati);
      expect(kind('belum', 'overdue'), TugasCardKind.overdue);
    });
    test('selesai mengalahkan kategori', () {
      expect(kind('selesai', 'overdue'), TugasCardKind.selesai);
    });
    test('gaya mendekati: border oranye 2px + badge', () {
      final s = styleFor(TugasCardKind.mendekati);
      expect(s.borderColor, AppColors.mendekati);
      expect(s.borderWidth, 2);
      expect(s.badgeColor, AppColors.mendekati);
    });
    test('gaya overdue: putus-putus, dicoret, badge gelap', () {
      final s = styleFor(TugasCardKind.overdue);
      expect(s.background, AppColors.overdueBg);
      expect(s.dashed, isTrue);
      expect(s.strikeDate, isTrue);
      expect(s.badgeColor, AppColors.overdueBadge);
    });
    test('normal & selesai tanpa badge deadline', () {
      expect(styleFor(TugasCardKind.normal).badgeColor, isNull);
      expect(styleFor(TugasCardKind.selesai).badgeColor, isNull);
    });
  });
}
