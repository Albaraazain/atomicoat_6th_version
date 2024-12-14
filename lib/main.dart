// path: lib/main.dart

import 'package:experiment_planner/blocs/alarm/bloc/alarm_bloc.dart';
import 'package:experiment_planner/blocs/alarm/repository/alarm_repository.dart';
import 'package:experiment_planner/blocs/component/bloc/component_bloc.dart';
import 'package:experiment_planner/blocs/component/bloc/component_list_bloc.dart';
import 'package:experiment_planner/blocs/component/repository/component_repository.dart';
import 'package:experiment_planner/blocs/monitoring/parameter/bloc/parameter_monitoring_bloc.dart';
import 'package:experiment_planner/blocs/recipe/bloc/recipe_bloc.dart';
import 'package:experiment_planner/blocs/safety/bloc/safety_bloc.dart';
import 'package:experiment_planner/blocs/safety/repository/safety_repository.dart';
import 'package:experiment_planner/blocs/simulation/bloc/simulation_bloc.dart';
import 'package:experiment_planner/blocs/system_state/bloc/system_state_bloc.dart';
import 'package:experiment_planner/providers/auth_provider.dart';
import 'package:experiment_planner/repositories/recipe_reposiory.dart';
import 'package:experiment_planner/repositories/system_state_repository.dart';
import 'package:experiment_planner/screens/admin_dashboard_screen.dart';
import 'package:experiment_planner/screens/login_screen.dart';
import 'package:experiment_planner/screens/main_screen.dart';
import 'package:experiment_planner/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Import Providers
import 'modules/system_operation_also_main_module/screens/main_dashboard.dart';
import 'modules/system_operation_also_main_module/screens/recipe_management_screen.dart';
import 'modules/system_operation_also_main_module/screens/system_overview_screen.dart';
import 'services/navigation_service.dart';

// Import Screens

// Import Enums and Widgets

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final authService = AuthService();
  final navigationService = NavigationService();
  final systemStateRepository = SystemStateRepository();
  final recipeRepository = RecipeRepository();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AlarmBloc>(
          create: (context) =>
              AlarmBloc(AlarmRepository(userId: authService.currentUserId)),
        ),
        BlocProvider<ComponentBloc>(
          create: (context) => ComponentBloc(ComponentRepository(authService)),
        ),
        BlocProvider<ComponentListBloc>(
          create: (context) =>
              ComponentListBloc(ComponentRepository(authService)),
        ),
        BlocProvider<SafetyBloc>(
          create: (context) => SafetyBloc(
            repository: SafetyRepository(userId: authService.currentUserId),
            authService: authService,
            alarmBloc: context.read<AlarmBloc>(),
          ),
        ),
        BlocProvider<SystemStateBloc>(
          create: (context) => SystemStateBloc(systemStateRepository),
        ),
        BlocProvider<ParameterMonitoringBloc>(
          create: (context) => ParameterMonitoringBloc(
            safetyBloc: context.read<SafetyBloc>(),
          ),
        ),
        BlocProvider<RecipeBloc>(
          create: (context) => RecipeBloc(
            repository: recipeRepository,
            authService: authService,
            systemStateBloc: context.read<SystemStateBloc>(),
            alarmBloc: context.read<AlarmBloc>(),
          ),
        ),
        BlocProvider<SimulationBloc>(
          create: (context) => SimulationBloc(
            componentBloc: context.read<ComponentBloc>(),
            alarmBloc: context.read<AlarmBloc>(),
            safetyBloc: context.read<SafetyBloc>(),
          ),
        ),
      ],
      child: MultiProvider(
        providers: [
          Provider<NavigationService>(create: (_) => navigationService),
          Provider<AuthService>(create: (_) => authService),
          ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ],
        child: Builder(
          builder: (BuildContext context) {
            return MaterialApp(
              title: 'ALD System Operations',
              navigatorKey: navigationService.navigatorKey,
              debugShowCheckedModeBanner: false,
              theme: _getTeslaTheme(),
              initialRoute: '/',
              routes: {
                '/': (context) => Consumer<AuthProvider>(
                      builder: (BuildContext context, authProvider, _) {
                        if (authProvider.isLoading()) {
                          return _buildLoadingScreen();
                        }
                        if (authProvider.isAuthenticated) {
                          if (authProvider.userStatus == 'approved' ||
                              authProvider.userStatus == 'active') {
                            return MainScreen();
                          } else if (authProvider.userStatus == 'pending') {
                            return _buildPendingApprovalScreen(context);
                          } else {
                            return _buildAccessDeniedScreen(context);
                          }
                        } else {
                          return LoginScreen();
                        }
                      },
                    ),
                '/main_dashboard': (context) => MainDashboard(),
                '/system_overview': (context) => SystemOverviewScreen(),
                '/recipe_management': (context) => RecipeManagementScreen(),
                '/admin_dashboard': (context) => AdminDashboardScreen(),
              },
            );
          },
        ),
      ),
    ),
  );
}

ThemeData _getTeslaTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF2C2C2C), // Dark Grey
      secondary: Color(0xFF4A4A4A), // Very Dark Grey (Almost Black)
      surface: Color(0xFF1E1E1E),
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: Color(0xFF121212),
    fontFamily: GoogleFonts.roboto().fontFamily,
    textTheme: TextTheme(
      displayLarge: GoogleFonts.roboto(
          fontSize: 56, fontWeight: FontWeight.w300, letterSpacing: -1.5),
      displayMedium: GoogleFonts.roboto(
          fontSize: 45, fontWeight: FontWeight.w300, letterSpacing: -0.5),
      displaySmall:
          GoogleFonts.roboto(fontSize: 36, fontWeight: FontWeight.w400),
      headlineMedium: GoogleFonts.roboto(
          fontSize: 28, fontWeight: FontWeight.w400, letterSpacing: 0.25),
      headlineSmall:
          GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.w400),
      titleLarge: GoogleFonts.roboto(
          fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: 0.15),
      titleMedium: GoogleFonts.roboto(
          fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.15),
      titleSmall: GoogleFonts.roboto(
          fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
      bodyLarge: GoogleFonts.roboto(
          fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
      bodyMedium: GoogleFonts.roboto(
          fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
      labelLarge: GoogleFonts.roboto(
          fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25),
      bodySmall: GoogleFonts.roboto(
          fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
      labelSmall: GoogleFonts.roboto(
          fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 1.5),
    ).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.roboto(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: CardTheme(
      color: Color(0xFF1E1E1E),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFF2C2C2C),
        textStyle: GoogleFonts.roboto(
            fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(0))),
    ),
    iconTheme: IconThemeData(color: Colors.white, size: 24),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: Colors.white70),
    ),
    dividerTheme: DividerThemeData(
      color: Color(0xFF2C2C2C),
      thickness: 1,
    ),
  );
}

Widget _buildLoadingScreen() {
  return Scaffold(
    body: Center(
      child: CircularProgressIndicator(),
    ),
  );
}

Widget _buildPendingApprovalScreen(BuildContext context) {
  return Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty, size: 64, color: Colors.orange),
          SizedBox(height: 16),
          Text(
            'Your account is pending approval',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'Please wait for an administrator to approve your account.',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            child: Text('Logout'),
          ),
        ],
      ),
    ),
  );
}

Widget _buildAccessDeniedScreen(BuildContext context) {
  return Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.block, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Access Denied',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'Your account has been deactivated or denied access.',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            child: Text('Logout'),
          ),
        ],
      ),
    ),
  );
}
