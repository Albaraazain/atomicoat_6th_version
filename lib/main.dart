// lib/main.dart
import 'package:experiment_planner/features/auth/bloc/auth_event.dart';
import 'package:experiment_planner/features/system/screens/admin_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'dart:developer' as developer;

import 'core/app/app_bootstrap.dart';
import 'core/app/app_providers.dart';
import 'core/app/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_state.dart';
import 'shared/services/navigation_service.dart';

// Screen imports
import 'features/auth/screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'features/system/screens/system_overview_screen.dart';

// Logger utility
void _log(String message, {String? error}) {
  if (kDebugMode) {
    if (error != null) {
      print('🔴 $message\nError: $error');
      developer.log(message, error: error);
    } else {
      print('📘 $message');
      developer.log(message);
    }
  }
}

void main() async {
  try {
    await AppBootstrap.initialize();

    // Add error logging
    FlutterError.onError = (details) {
      debugPrint('Flutter error: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');
    };

    runApp(const App());
  } catch (e, stack) {
    debugPrint('Fatal error during app initialization: $e\n$stack');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Failed to initialize app: $e'),
        ),
      ),
    ));
  }
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _AppSetup(
      child: _AppConfiguration(
        child: _AppContent(),
      ),
    );
  }
}

class _AppSetup extends StatelessWidget {
  final Widget child;

  const _AppSetup({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => NavigationService()),
      ],
      child: child,
    );
  }
}

class _AppConfiguration extends StatelessWidget {
  final Widget child;

  const _AppConfiguration({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationService = context.read<NavigationService>();

    return MultiBlocProvider(
      providers: AppProviders.createBlocProviders(),
      child: MultiProvider(
        providers: AppProviders.createServiceProviders(
          navigationService: navigationService,
        ),
        child: child,
      ),
    );
  }
}

class _AppContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final navigationService = context.read<NavigationService>();

    return MaterialApp(
      title: 'ALD System Operations',
      navigatorKey: navigationService.navigatorKey,
      theme: AppTheme.buildTheme(),
      debugShowCheckedModeBanner: false,
      // Remove the home property since we're using routes
      routes: {
        '/': (context) => const _AppRouter(),  // Keep this as the initial route
        '/home': (context) => MainScreen(),
        '/admin': (context) => AdminDashboardScreen(),
        '/system_overview': (context) => const SystemOverviewScreen(),
      },
      onGenerateRoute: (settings) {
        _log("Generating route for: ${settings.name}");
        return MaterialPageRoute(
          builder: (context) => const ErrorScreen(
            title: 'Route Not Found',
            message: 'The requested page does not exist',
          ),
        );
      },
      // Add onUnknownRoute handler
      onUnknownRoute: (settings) {
        _log("Unknown route: ${settings.name}", error: "Route not found");
        return MaterialPageRoute(
          builder: (context) => const ErrorScreen(
            title: '404 - Not Found',
            message: 'The requested page could not be found',
          ),
        );
      },
      builder: (context, child) {
        return child ?? const ErrorScreen(
          title: 'Navigation Error',
          message: 'Failed to load application content',
        );
      },
    );
  }
}

class _AppRouter extends StatelessWidget {
  const _AppRouter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        debugPrint('Current auth state: ${state.status}'); // Add more logging

        switch (state.status) {
          case AuthStatus.initial:
            context.read<AuthBloc>().add(AuthCheckRequested());
            return const LoadingScreen();

          case AuthStatus.loading:
            _log("ROUTER: Showing loading screen");
            return const LoadingScreen();

          case AuthStatus.authError:
            _log("ROUTER: Authentication error", error: state.errorMessage);
            return LoginScreen(
              errorMessage: state.errorMessage,
              errorCode: state.errorCode,
            );

          case AuthStatus.userDataError:
            _log("ROUTER: User data error", error: state.errorMessage);
            return ErrorScreen(
              title: 'User Data Error',
              message: state.errorMessage ?? 'Error loading user data',
              onRetry: () {
                _log("ROUTER: Retrying user data load");
                context.read<AuthBloc>().add(AuthCheckRequested());
              },
            );

          case AuthStatus.accessDenied:
            _log("ROUTER: Access denied", error: "${state.errorMessage} (${state.errorCode})");
            return AccessDeniedScreen(
              message: state.errorMessage ?? 'Access denied',
              status: state.errorCode ?? 'unknown',
            );

          case AuthStatus.unauthenticated:
            _log("ROUTER: User is unauthenticated");
            return const LoginScreen();

          case AuthStatus.authenticated:
            if (state.user == null) {
              _log("ROUTER: Invalid authenticated state - user is null",
                   error: "Authentication state inconsistency");
              return const ErrorScreen(
                title: 'Authentication Error',
                message: 'User state is invalid. Please try logging in again.',
              );
            }

            _log("ROUTER: User authenticated - checking status");
            if (state.user!.status == 'pending') {
              _log("ROUTER: User pending approval");
              return PendingApprovalScreen(email: state.user!.email);
            }

            _log("ROUTER: Loading main application screen");
            return MainScreen();

          default:
            _log("ROUTER: Unhandled state - defaulting to login",
                 error: "Unhandled AuthStatus: ${state.status}");
            return const LoginScreen();
        }
      },
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorScreen({
    Key? key,
    required this.title,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              if (onRetry != null)
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => context.read<AuthBloc>().add(SignOutRequested()),
                icon: const Icon(Icons.logout),
                label: const Text('Back to Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class PendingApprovalScreen extends StatelessWidget {
  final String? email;

  const PendingApprovalScreen({Key? key, this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_empty, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Your account is pending approval',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please wait for an administrator to approve your account.',
              textAlign: TextAlign.center,
            ),
            if (email != null) ...[
              const SizedBox(height: 16),
              Text(
                'Email: $email',
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<AuthBloc>().add(SignOutRequested()),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class AccessDeniedScreen extends StatelessWidget {
  final String? message;
  final String? status;

  const AccessDeniedScreen({Key? key, this.message, this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.block, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Access Denied',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              message ?? 'Your account has been deactivated or denied access.',
              textAlign: TextAlign.center,
            ),
            if (status != null) ...[
              const SizedBox(height: 16),
              Text(
                'Status: $status',
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<AuthBloc>().add(SignOutRequested()),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
