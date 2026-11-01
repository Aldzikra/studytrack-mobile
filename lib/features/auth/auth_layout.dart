import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../shared/motion/motion.dart';
import '../../shared/widgets/app_logo.dart';

/// Panel biru 300px (3 shape dekoratif beranimasi + headline) di atas, form di bawah.
class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.title, required this.subtitle, required this.child});
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const _Panel(),
          FadeUp(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text(title, style: t.headlineSmall?.copyWith(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                const SizedBox(height: 6),
                Text(subtitle, style: t.bodyMedium?.copyWith(color: AppColors.muted)),
                const SizedBox(height: 18),
                child,
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel();

  static Duration _ms(int v) => Duration(milliseconds: v);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      height: 300 + top,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        color: AppColors.brand,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Stack(children: [
        // Shape 1: lingkaran brand-400, scale 0→1, 700ms delay 150ms.
        Positioned(
          right: -60,
          top: -60,
          child: Entrance(
            duration: _ms(700),
            delay: _ms(150),
            scale: 0,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.sky),
            ),
          ),
        ),
        // Shape 2: kotak cyan miring 12°, dari offset (60,60) & rotasi 40°.
        Positioned(
          right: 28,
          bottom: 40,
          child: Entrance(
            duration: _ms(700),
            delay: _ms(300),
            offset: const Offset(60, 60),
            fromRotation: 40 * math.pi / 180,
            toRotation: 12 * math.pi / 180,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: AppColors.cyan, borderRadius: BorderRadius.circular(18)),
            ),
          ),
        ),
        // Shape 3: lingkaran lemon kecil, scale 0→1, 500ms delay 450ms.
        Positioned(
          right: 116,
          bottom: 22,
          child: Entrance(
            duration: _ms(500),
            delay: _ms(450),
            scale: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.belumBg),
            ),
          ),
        ),
        // Konten: fade-up y 24→0, 600ms, stagger 150ms.
        Padding(
          padding: EdgeInsets.fromLTRB(24, 32 + top, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Entrance(duration: _ms(600), offset: const Offset(0, 24), child: const AppLogo(light: true, size: 34)),
              Entrance(
                duration: _ms(600),
                delay: _ms(150),
                offset: const Offset(0, 24),
                child: const SizedBox(
                  width: 240,
                  child: Text(
                    'Semua tugas kuliah, satu daftar.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
