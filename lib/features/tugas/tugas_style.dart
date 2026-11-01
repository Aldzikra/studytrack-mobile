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
    this.shadow = const [],
    this.titleColor = AppColors.ink,
    this.dateColor = AppColors.text2,
    this.dateWeight = FontWeight.w600,
    this.buttonBorder = AppColors.border,
    this.buttonColor = AppColors.primary,
  });

  final Color background;
  final Color borderColor;
  final double borderWidth;
  final bool dashed;

  /// Warna badge "Sisa/Terlambat X jam"; null = tanpa badge.
  final Color? badgeColor;
  final bool strikeDate;
  final List<BoxShadow> shadow;
  final Color titleColor;
  final Color dateColor;
  final FontWeight dateWeight;
  final Color buttonBorder;
  final Color buttonColor;
}

// Nilai dari docs/design/MobileTugas.html & CardStates.html.
TugasCardStyle styleFor(TugasCardKind k) => switch (k) {
      TugasCardKind.normal =>
        const TugasCardStyle(background: Colors.white, borderColor: AppColors.border),
      TugasCardKind.selesai => const TugasCardStyle(
          background: Colors.white,
          borderColor: AppColors.border,
          titleColor: AppColors.muted,
          dateColor: AppColors.muted,
          buttonColor: AppColors.muted,
        ),
      TugasCardKind.mendekati => const TugasCardStyle(
          background: Colors.white,
          borderColor: AppColors.mendekati,
          borderWidth: 2,
          badgeColor: AppColors.mendekati,
          dateColor: AppColors.mendekatiFg,
          dateWeight: FontWeight.w700,
          shadow: [BoxShadow(color: Color(0x1FE2580B), blurRadius: 18, offset: Offset(0, 6))],
        ),
      TugasCardKind.overdue => const TugasCardStyle(
          background: AppColors.overdueBg,
          borderColor: AppColors.overdueBorder,
          dashed: true,
          badgeColor: AppColors.overdueBadge,
          strikeDate: true,
          titleColor: AppColors.overdueFg,
          dateColor: AppColors.overdueBadge,
          dateWeight: FontWeight.w700,
          buttonBorder: AppColors.overdueChipBorder,
        ),
    };
