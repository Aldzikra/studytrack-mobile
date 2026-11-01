import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_controller.dart';
import 'theme.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        body: shell,
        bottomNavigationBar: _TabBar(
          current: shell.currentIndex,
          onTap: (i) {
            // Tab ke-3 bukan halaman: langsung keluar, router redirect ke /login.
            if (i == 2) {
              ref.read(authControllerProvider.notifier).logout();
            } else {
              shell.goBranch(i, initialLocation: i == shell.currentIndex);
            }
          },
        ),
      );
}

/// Tab bar sesuai MobileTabBar.tsx / MobileTugas.html: pill aktif brand-50.
class _TabBar extends StatelessWidget {
  const _TabBar({required this.current, required this.onTap});
  final int current;
  final ValueChanged<int> onTap;

  static const _items = [
    (Icons.format_list_bulleted, 'Tugas'),
    (Icons.school_outlined, 'Mata Kuliah'),
    (Icons.logout, 'Keluar'),
  ];

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.fromLTRB(12, 8, 12, math.max(20, MediaQuery.viewPaddingOf(context).bottom)),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(children: [
          for (var i = 0; i < _items.length; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 4),
                child: _TabItem(
                  icon: _items[i].$1,
                  label: _items[i].$2,
                  active: i == current,
                  onTap: () => onTap(i),
                ),
              ),
            ),
        ]),
      );
}

class _TabItem extends StatelessWidget {
  const _TabItem({required this.icon, required this.label, required this.active, required this.onTap});
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.muted;
    return Semantics(
      selected: active,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
              decoration: BoxDecoration(
                color: active ? AppColors.brand50 : null,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(fontSize: 12, fontWeight: active ? FontWeight.w800 : FontWeight.w700, color: color)),
          ]),
        ),
      ),
    );
  }
}
