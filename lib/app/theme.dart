import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF1A5FD6);
  static const brand = Color(0xFF2373F4);
  static const sky = Color(0xFF578EF5);
  static const cyan = Color(0xFF65D0F4);
  static const bg = Color(0xFFF4F7FD);
  static const ink = Color(0xFF0F1B33);
  static const muted = Color(0xFF55627A);
  static const border = Color(0xFFDCE5F5);
  static const belumBg = Color(0xFFF2F7A0);
  static const belumFg = Color(0xFF4D4A00);
  static const selesaiBg = Color(0xFFDDF4E4);
  static const selesaiFg = Color(0xFF14632C);
  static const mendekati = Color(0xFFE2580B);
  static const overdueBg = Color(0xFFF7F8FA);
  static const overdueBorder = Color(0xFF8D96A8);
  static const overdueBadge = Color(0xFF3A4256);
  static const text2 = Color(0xFF3B4863);
  static const brand50 = Color(0xFFE8F0FE);
  static const mendekatiBg = Color(0xFFFFF1E6);
  static const mendekatiBorder = Color(0xFFF7C9A6);
  static const mendekatiFg = Color(0xFF9A3A00);
  static const overdueChipBg = Color(0xFFECEFF4);
  static const overdueChipBorder = Color(0xFFCDD3DE);
  static const overdueFg = Color(0xFF2E3546);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.brand,
    primary: AppColors.primary,
    surface: Colors.white,
    onSurface: AppColors.ink,
    outline: AppColors.border,
  );
  final text = GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme)
      .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: text,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.ink,
      elevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(44, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: text.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
