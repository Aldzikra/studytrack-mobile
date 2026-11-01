import 'package:go_router/go_router.dart';

import '../features/health/health_screen.dart';

final router = GoRouter(
  routes: [GoRoute(path: '/', builder: (_, _) => const HealthScreen())],
);
