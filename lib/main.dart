import 'package:experiment_planner/providers/auth_provider.dart';
import 'package:experiment_planner/repositories/system_state_repository.dart';
import 'package:experiment_planner/screens/admin_dashboard_screen.dart';
import 'package:experiment_planner/screens/login_screen.dart';
import 'package:experiment_planner/screens/main_screen.dart';
import 'package:experiment_planner/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Import Providers
import 'modules/maintenance_module/providers/maintenance_provider.dart';
import 'modules/maintenance_module/providers/calibration_provider.dart';
import 'modules/maintenance_module/providers/spare_parts_provider.dart';
import 'modules/maintenance_module/providers/report_provider.dart';
import 'modules/maintenance_module/screens/calibration_screen.dart';
import 'modules/maintenance_module/screens/documentation_screen.dart';
import 'modules/maintenance_module/screens/remote_assistance_screen.dart';
import 'modules/maintenance_module/screens/reporting_screen.dart';
import 'modules/maintenance_module/screens/safety_procedures_screen.dart';
import 'modules/maintenance_module/screens/spare_parts_screen.dart';
import 'modules/maintenance_module/screens/troubleshooting_screen.dart';
import 'modules/system_operation_also_main_module/providers/alarm_provider.dart';
import 'modules/system_operation_also_main_module/providers/recipe_provider.dart';
import 'modules/system_operation_also_main_module/providers/safety_error_provider.dart';
import 'modules/system_operation_also_main_module/providers/system_copmonent_provider.dart';
import 'modules/system_operation_also_main_module/providers/system_state_provider.dart';
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

  runApp(
    MultiProvider(
      providers: [
        // Services
        Provider<NavigationService>(create: (_) => navigationService),
        Provider<AuthService>(create: (_) => authService),
        Provider<SystemStateRepository>(create: (_) => SystemStateRepository()),

        // Global Providers
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(create: (_) => SystemComponentProvider()),

        // Maintenance Module Providers
        ChangeNotifierProvider(
          create: (context) => MaintenanceProvider(
            context.read<SystemComponentProvider>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CalibrationProvider(
            context.read<SystemComponentProvider>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => SparePartsProvider()),

        // System Operation Module Providers
        ChangeNotifierProvider(create: (_) => SafetyErrorProvider(authService)),
        ChangeNotifierProvider(create: (_) => RecipeProvider(authService)),
        ChangeNotifierProvider(create: (_) => AlarmProvider(authService)),

        // System State Provider
        ChangeNotifierProxyProvider5<
            SystemComponentProvider,
            RecipeProvider,
            AlarmProvider,
            SystemStateRepository,
            AuthService,
            SystemStateProvider>(
          create: (context) => SystemStateProvider(
            context.read<SystemComponentProvider>(),
            context.read<RecipeProvider>(),
            context.read<AlarmProvider>(),
            context.read<SystemStateRepository>(),
            context.read<AuthService>(),
          ),
          update: (context, componentProvider, recipeProvider, alarmProvider,
              systemStateRepository, authService, previous) =>
          previous!..updateProviders(recipeProvider, alarmProvider),
        ),

        // Maintenance Module Report Provider
        ChangeNotifierProxyProvider2<MaintenanceProvider, CalibrationProvider,
            ReportProvider>(
          create: (ctx) => ReportProvider(
            ctx.read<MaintenanceProvider>(),
            ctx.read<CalibrationProvider>(),
          ),
          update: (ctx, maintenance, calibration, previous) =>
          previous!..updateProviders(maintenance, calibration),
        ),
      ],
      child: Builder(
        builder: (BuildContext context) {
          return MaterialApp(
            title: 'ALD Machine Maintenance',
            navigatorKey: Provider.of<NavigationService>(context, listen: false).navigatorKey,
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
                    if (authProvider.userStatus == 'approved' || authProvider.userStatus == 'active') {
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
              '/calibration': (context) => CalibrationScreen(),
              '/reporting': (context) => ReportingScreen(),
              '/troubleshooting': (context) => TroubleshootingScreen(),
              '/spare_parts': (context) => SparePartsScreen(),
              '/documentation': (context) => DocumentationScreen(),
              '/remote_assistance': (context) => RemoteAssistanceScreen(),
              '/safety_procedures': (context) => SafetyProceduresScreen(),
              '/recipe_management': (context) => RecipeManagementScreen(),
              // '/profile': (context) => ProfileScreen(),
              // '/settings': (context) => SettingsScreen(),
              // '/help_support': (context) => HelpSupportScreen(),
              '/overview': (context) => SystemOverviewScreen(),
              // '/diagram_details': (context) => DiagramDetailsScreen(),
              '/admin_dashboard': (context) => AdminDashboardScreen(),
            },
          );
        },
      ),
    ),
  );
}


ThemeData _getTeslaTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF2C2C2C),    // Dark Grey
      secondary: Color(0xFF4A4A4A), // Very Dark Grey (Almost Black)
      surface: Color(0xFF1E1E1E),
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: Color(0xFF121212),
    fontFamily: GoogleFonts.roboto().fontFamily,
    textTheme: TextTheme(
      displayLarge: GoogleFonts.roboto(fontSize: 56, fontWeight: FontWeight.w300, letterSpacing: -1.5),
      displayMedium: GoogleFonts.roboto(fontSize: 45, fontWeight: FontWeight.w300, letterSpacing: -0.5),
      displaySmall: GoogleFonts.roboto(fontSize: 36, fontWeight: FontWeight.w400),
      headlineMedium: GoogleFonts.roboto(fontSize: 28, fontWeight: FontWeight.w400, letterSpacing: 0.25),
      headlineSmall: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.w400),
      titleLarge: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: 0.15),
      titleMedium: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.15),
      titleSmall: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
      bodyLarge: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
      bodyMedium: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
      labelLarge: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25),
      bodySmall: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
      labelSmall: GoogleFonts.roboto(fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 1.5),
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
        textStyle: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(0))),
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




