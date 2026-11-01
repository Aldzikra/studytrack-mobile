import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../features/auth/auth_controller.dart';
import 'app_logo.dart';

/// Header mobile sesuai MobileHeader.tsx: logo kiri, avatar + tombol Keluar kanan.
class AppHeader extends ConsumerWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = (ref.watch(authControllerProvider).value?.username ?? '').trim();
    final initials = name.isEmpty ? '?' : name.substring(0, name.length < 2 ? 1 : 2).toUpperCase();
    return Container(
      padding: EdgeInsets.fromLTRB(20, 8 + MediaQuery.paddingOf(context).top, 8, 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        const AppLogo(),
        const Spacer(),
        Semantics(
          label: name,
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.cyan),
            child: Text(initials,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0B3A4A))),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          tooltip: 'Keluar',
          constraints: const BoxConstraints.tightFor(width: 44, height: 44),
          icon: const Icon(Icons.logout, size: 22, color: AppColors.muted),
          onPressed: () => ref.read(authControllerProvider.notifier).logout(),
        ),
      ]),
    );
  }
}
