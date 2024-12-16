import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:experiment_planner/blocs/component/bloc/component_list_event.dart';
import 'package:experiment_planner/blocs/recipe/repository/recipe_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:provider/single_child_widget.dart';
import 'core/config/firebase_options.dart';

// Bloc imports
import 'blocs/alarm/bloc/alarm_bloc.dart';
import 'blocs/component/bloc/component_bloc.dart';
import 'blocs/component/bloc/component_list_bloc.dart';
import 'blocs/monitoring/parameter/bloc/parameter_monitoring_bloc.dart';
import 'blocs/recipe/bloc/recipe_bloc.dart';
import 'blocs/safety/bloc/safety_bloc.dart';
import 'blocs/simulation/bloc/simulation_bloc.dart';
import 'blocs/system_state/bloc/system_state_bloc.dart';

// Repository imports
import 'blocs/alarm/repository/alarm_repository.dart';
import 'blocs/component/repository/component_repository.dart';
import 'blocs/safety/repository/safety_repository.dart';
import 'features/system/repositories/system_state_repository.dart';

// Screen imports
import 'features/system/screens/admin_dashboard_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'features/system/screens/main_dashboard.dart';
import 'features/recipes/screens/recipe_management_screen.dart';
import 'features/system/screens/system_overview_screen.dart';

// Service imports
import 'features/auth/services/auth_service.dart';
import 'shared/services/navigation_service.dart';

// Provider imports
import 'features/auth/providers/auth_provider.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Check if Firebase is already initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }

    runApp(MyApp());
  } catch (e, stack) {
    print('Initialization error: $e');
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

Future<void> createFirestoreIndexes() async {
  try {
    final firestore = FirebaseFirestore.instance;

    // Check if index already exists
    final indexDoc = await firestore.collection('alarms').doc('__indexes__').get();
    if (indexDoc.exists) {
      return; // Index already exists
    }

    // Create composite index for alarms collection
    await firestore.collection('alarms').doc('__indexes__').set({
      'composite_indexes': [{
        'fields': [
          {'fieldPath': 'acknowledged', 'order': 'ASCENDING'},
          {'fieldPath': 'timestamp', 'order': 'DESCENDING'},
          {'fieldPath': '__name__', 'order': 'DESCENDING'}
        ],
        'queryScope': 'COLLECTION'
      }]
    });

    print('Firestore indexes created successfully');
  } catch (e) {
    print('Error creating Firestore indexes: $e');
    // Don't throw the error as indexes are not critical for app startup
  }
}


class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final authService = AuthService();
  final navigationService = NavigationService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Ensure all critical services are initialized
      future: Future.wait([
        Firebase.initializeApp(),
        // Add other initialization futures here
      ]),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    SizedBox(height: 16),
                    Text('Failed to initialize services'),
                    if (snapshot.error != null)
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          snapshot.error.toString(),
                          style: TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        return MultiBlocProvider(
          providers: _createBlocProviders(),
          child: MultiProvider(
            providers: _createServiceProviders(),
            child: MaterialApp(
              title: 'ALD System Operations',
              navigatorKey: navigationService.navigatorKey,
              debugShowCheckedModeBanner: false,
              theme: _buildAppTheme(),
              initialRoute: '/',
              routes: _buildAppRoutes(),
            ),
          ),
        );
      },
    );
  }

  List<BlocProvider> _createBlocProviders() {
    final systemStateRepository = SystemStateRepository();
    final recipeRepository = RecipeRepository();
    final componentRepository = ComponentRepository();
    final alarmRepository = AlarmRepository();

    // Initialize all repositories first
    final componentListBloc = ComponentListBloc(componentRepository)
      ..add(const LoadComponents());

    final alarmBloc = AlarmBloc(alarmRepository);
    final systemStateBloc = SystemStateBloc(systemStateRepository);

    return [
      BlocProvider<AlarmBloc>.value(value: alarmBloc),
      BlocProvider<ComponentBloc>(
        create: (context) => ComponentBloc(componentRepository),
      ),
      BlocProvider<ComponentListBloc>.value(value: componentListBloc),
      BlocProvider<SafetyBloc>(
        create: (context) => SafetyBloc(
          repository: SafetyRepository(userId: authService.currentUserId),
          authService: authService,
          alarmBloc: alarmBloc,
        ),
      ),
      BlocProvider<SystemStateBloc>.value(value: systemStateBloc),
      BlocProvider<ParameterMonitoringBloc>(
        create: (context) => ParameterMonitoringBloc(
          safetyBloc: context.read<SafetyBloc>(),
        ),
      ),
      BlocProvider<RecipeBloc>(
        create: (context) => RecipeBloc(
          repository: recipeRepository,
          authService: authService,
          systemStateBloc: systemStateBloc,
          alarmBloc: alarmBloc,
        ),
      ),
      BlocProvider<SimulationBloc>(
        create: (context) => SimulationBloc(
          componentBloc: context.read<ComponentBloc>(),
          alarmBloc: alarmBloc,
          safetyBloc: context.read<SafetyBloc>(),
        ),
      ),
    ];
  }

  List<SingleChildWidget> _createServiceProviders() {
    return [
      Provider<NavigationService>.value(value: navigationService),
      Provider<AuthService>.value(value: authService),
      ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
    ];
  }

  Map<String, WidgetBuilder> _buildAppRoutes() {
    return {
      '/': (context) => _buildHomeScreen(),
      '/main_dashboard': (context) => MainDashboard(),
      '/system_overview': (context) => SystemOverviewScreen(),
      '/recipe_management': (context) => RecipeManagementScreen(),
      '/admin_dashboard': (context) => AdminDashboardScreen(),
      '/login': (context) => LoginScreen(),
    };
  }

  Widget _buildHomeScreen() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return _LoadingScreen();
        }

        if (!authProvider.isAuthenticated) {
          return LoginScreen();
        }

        final status = authProvider.userStatus;
        if (status == 'approved' || status == 'active') {
          return MainScreen();
        } else if (status == 'pending') {
          return _PendingApprovalScreen();
        } else {
          return _AccessDeniedScreen();
        }
      },
    );
  }
}


class _LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _PendingApprovalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              onPressed: () => Provider.of<AuthProvider>(context, listen: false).signOut(),
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessDeniedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              onPressed: () => Provider.of<AuthProvider>(context, listen: false).signOut(),
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

ThemeData _buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF2C2C2C),
      secondary: Color(0xFF4A4A4A),
      surface: Color(0xFF1E1E1E),
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: Color(0xFF121212),
    fontFamily: GoogleFonts.roboto().fontFamily,
    textTheme: _buildTextTheme(),
    appBarTheme: _buildAppBarTheme(),
    cardTheme: _buildCardTheme(),
    elevatedButtonTheme: _buildElevatedButtonTheme(),
    drawerTheme: _buildDrawerTheme(),
    iconTheme: _buildIconTheme(),
    inputDecorationTheme: _buildInputDecorationTheme(),
    dividerTheme: _buildDividerTheme(),
  );
}

TextTheme _buildTextTheme() {
  return TextTheme(
    displayLarge: GoogleFonts.roboto(
      fontSize: 56, fontWeight: FontWeight.w300, letterSpacing: -1.5),
    displayMedium: GoogleFonts.roboto(
      fontSize: 45, fontWeight: FontWeight.w300, letterSpacing: -0.5),
    displaySmall: GoogleFonts.roboto(
      fontSize: 36, fontWeight: FontWeight.w400),
    headlineMedium: GoogleFonts.roboto(
      fontSize: 28, fontWeight: FontWeight.w400, letterSpacing: 0.25),
    headlineSmall: GoogleFonts.roboto(
      fontSize: 24, fontWeight: FontWeight.w400),
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
  );
}

AppBarTheme _buildAppBarTheme() {
  return AppBarTheme(
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
  );
}

CardTheme _buildCardTheme() {
  return CardTheme(
    color: Color(0xFF1E1E1E),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}

ElevatedButtonThemeData _buildElevatedButtonTheme() {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Color(0xFF2C2C2C),
      textStyle: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.25,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    ),
  );
}

DrawerThemeData _buildDrawerTheme() {
  return DrawerThemeData(
    backgroundColor: Color(0xFF1E1E1E),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.horizontal(right: Radius.circular(0)),
    ),
  );
}

IconThemeData _buildIconTheme() {
  return IconThemeData(color: Colors.white, size: 24);
}

InputDecorationTheme _buildInputDecorationTheme() {
  return InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF2C2C2C),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    hintStyle: TextStyle(color: Colors.white70),
  );
}

DividerThemeData _buildDividerTheme() {
  return DividerThemeData(
    color: Color(0xFF2C2C2C),
    thickness: 1,
  );
}