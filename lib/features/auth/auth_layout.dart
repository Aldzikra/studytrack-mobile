import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Panel biru di atas + kartu form di bawah (desain auth).
class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.title, required this.subtitle, required this.child});
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(24, MediaQuery.paddingOf(context).top + 48, 24, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.brand],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('StudyTrack',
                      style: t.titleMedium?.copyWith(color: AppColors.cyan, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Text(title,
                      style: t.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: t.bodyMedium?.copyWith(color: Colors.white70)),
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.all(24), child: child),
          ],
        ),
      ),
    );
  }
}
