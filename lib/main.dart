// lib/main.dart
import 'package:experiment_planner/features/auth/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'core/app/app_bootstrap.dart';
import 'core/app/app_providers.dart';
import 'core/app/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_state.dart';
import 'shared/services/navigation_service.dart';

// Screen imports
import 'features/auth/screens/login_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  try {
    await AppBootstrap.initialize();
    runApp(const App());
  } catch (e, stack) {
    print('Fatal error during app initialization: $e');
    print(stack);
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
      home: const _AppRouter(),
    );
  }
}

class _AppRouter extends StatelessWidget {
  const _AppRouter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.loading) {
          return const LoadingScreen();
        }

        if (state.status == AuthStatus.unauthenticated) {
          return const LoginScreen();
        }

        if (state.status == AuthStatus.authenticated && state.user != null) {
          // Check user status
          if (state.user!.status == 'approved' || state.user!.status == 'active') {
            return  MainScreen();
          } else if (state.user!.status == 'pending') {
            return const PendingApprovalScreen();
          }
        }

        return const AccessDeniedScreen();
      },
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
  const PendingApprovalScreen({Key? key}) : super(key: key);

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
  const AccessDeniedScreen({Key? key}) : super(key: key);

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
            const Text(
              'Your account has been deactivated or denied access.',
              textAlign: TextAlign.center,
            ),
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