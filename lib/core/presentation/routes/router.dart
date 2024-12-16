// lib/core/presentation/routes/router.dart
import 'package:auto_route/auto_route.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: LoginPage, initial: true),
    AutoRoute(page: RegisterPage),
    AutoRoute(page: HomePage),
    AutoRoute(page: AdminDashboardPage),
  ],
)
class $AppRouter {}
