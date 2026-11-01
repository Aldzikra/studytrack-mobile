import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_controller.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        body: shell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) {
            // Tab ke-3 bukan halaman: langsung keluar, router redirect ke /login.
            if (i == 2) {
              ref.read(authControllerProvider.notifier).logout();
            } else {
              shell.goBranch(i, initialLocation: i == shell.currentIndex);
            }
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.checklist), label: 'Tugas'),
            NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Mata Kuliah'),
            NavigationDestination(icon: Icon(Icons.logout), label: 'Keluar'),
          ],
        ),
      );
}
