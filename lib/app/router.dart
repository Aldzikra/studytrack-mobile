import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/matkul/matkul_page.dart';
import '../features/tugas/tugas.dart';
import '../features/tugas/tugas_form_screen.dart';
import '../features/tugas/tugas_page.dart';
import 'app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(authControllerProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/tugas',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final loc = state.matchedLocation;
      if (auth.isLoading) return loc == '/splash' ? null : '/splash';
      final loggedIn = auth.value != null;
      final isAuthPage = loc == '/login' || loc == '/register';
      if (!loggedIn) return isAuthPage ? null : '/login';
      return (isAuthPage || loc == '/splash') ? '/tugas' : null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, _) => const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: '/tugas/form',
        builder: (_, state) => TugasFormScreen(tugas: state.extra as Tugas?),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/tugas', builder: (_, _) => const TugasPage())]),
          StatefulShellBranch(routes: [GoRoute(path: '/matkul', builder: (_, _) => const MatkulPage())]),
        ],
      ),
    ],
  );
});
