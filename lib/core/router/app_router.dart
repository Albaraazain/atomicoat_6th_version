// lib/core/router/app_router.dart
import 'package:auto_route/auto_route.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/password_reset_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/screens/admin/admin_dashboard_screen.dart';
import '../../features/auth/presentation/screens/admin/user_management_screen.dart';
import '../../features/auth/presentation/screens/admin/pending_requests_screen.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Screen,Route',
  routes: <AutoRoute>[
    AutoRoute(
      path: '/',
      name: 'RootRouter',
      page: RootScreen,
      children: [
        AutoRoute(
          path: 'login',
          name: 'LoginRouter',
          page: LoginScreen,
        ),
        AutoRoute(
          path: 'register',
          name: 'RegisterRouter',
          page: RegisterScreen,
        ),
        AutoRoute(
          path: 'reset-password',
          name: 'PasswordResetRouter',
          page: PasswordResetScreen,
        ),
        AutoRoute(
          path: 'profile',
          name: 'ProfileRouter',
          page: ProfileScreen,
          guards: [AuthGuard],
        ),
        AutoRoute(
          path: 'admin',
          name: 'AdminRouter',
          page: EmptyRouterPage,
          guards: [AdminGuard],
          children: [
            AutoRoute(
              path: '',
              page: AdminDashboardScreen,
            ),
            AutoRoute(
              path: 'users',
              name: 'UserManagementRouter',
              page: UserManagementScreen,
            ),
            AutoRoute(
              path: 'requests',
              name: 'PendingRequestsRouter',
              page: PendingRequestsScreen,
            ),
          ],
        ),
      ],
    ),
  ],
)
class $AppRouter {}

