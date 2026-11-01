import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'tugas.dart';

enum TugasCardKind { normal, mendekati, overdue, selesai }

/// Selesai menang atas kategori deadline.
TugasCardKind cardKind(Tugas t) {
  if (t.selesai) return TugasCardKind.selesai;
  return switch (t.category) {
    DeadlineCategory.mendekati => TugasCardKind.mendekati,
    DeadlineCategory.overdue => TugasCardKind.overdue,
    _ => TugasCardKind.normal,
  };
}

class TugasCardStyle {
  const TugasCardStyle({
    required this.background,
    required this.borderColor,
    this.borderWidth = 1,
    this.dashed = false,
    this.badgeColor,
    this.strikeDate = false,
  });

  final Color background;
  final Color borderColor;
  final double borderWidth;
  final bool dashed;

  /// Warna badge "Sisa/Terlambat X jam"; null = tanpa badge.
  final Color? badgeColor;
  final bool strikeDate;
}

TugasCardStyle styleFor(TugasCardKind k) => switch (k) {
      TugasCardKind.normal || TugasCardKind.selesai =>
        const TugasCardStyle(background: Colors.white, borderColor: AppColors.border),
      TugasCardKind.mendekati => const TugasCardStyle(
          background: Colors.white,
          borderColor: AppColors.mendekati,
          borderWidth: 2,
          badgeColor: AppColors.mendekati,
        ),
      TugasCardKind.overdue => const TugasCardStyle(
          background: AppColors.overdueBg,
          borderColor: AppColors.overdueBorder,
          dashed: true,
          badgeColor: AppColors.overdueBadge,
          strikeDate: true,
        ),
    };
