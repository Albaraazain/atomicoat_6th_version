// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';

// Import Providers
import 'modules/maintenance_module/providers/maintenance_provider.dart';
import 'modules/maintenance_module/providers/calibration_provider.dart';
import 'modules/maintenance_module/providers/spare_parts_provider.dart';
import 'modules/maintenance_module/providers/report_provider.dart';
import 'modules/system_operation_also_main_module/providers/alarm_provider.dart';
import 'modules/system_operation_also_main_module/providers/recipe_provider.dart';
import 'modules/system_operation_also_main_module/providers/system_state_provider.dart';
import 'services/navigation_service.dart';

// Import Screens
import 'modules/maintenance_module/screens/maintenance_home_screen.dart';
import 'modules/maintenance_module/screens/calibration_screen.dart';
import 'modules/maintenance_module/screens/troubleshooting_screen.dart';
import 'modules/maintenance_module/screens/spare_parts_screen.dart';
import 'modules/maintenance_module/screens/documentation_screen.dart';
import 'modules/maintenance_module/screens/reporting_screen.dart';
import 'modules/maintenance_module/screens/remote_assistance_screen.dart';
import 'modules/maintenance_module/screens/safety_procedures_screen.dart';
import 'modules/system_operation_also_main_module/screens/system_overview_screen.dart';
import 'modules/system_operation_also_main_module/screens/main_dashboard.dart';
import 'modules/system_operation_also_main_module/screens/recipe_management_screen.dart';

// Import Enums and Widgets
import 'enums/navigation_item.dart';
import 'widgets/app_drawer.dart';

void main() {
  runApp(
    Provider<NavigationService>(
      create: (_) => NavigationService(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  ReportProvider _initReportProvider(BuildContext context) {
    return ReportProvider(
      Provider.of<MaintenanceProvider>(context, listen: false),
      Provider.of<CalibrationProvider>(context, listen: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Maintenance Module Providers
        ChangeNotifierProvider(create: (_) => MaintenanceProvider()),
        ChangeNotifierProvider(create: (_) => CalibrationProvider()),
        ChangeNotifierProvider(create: (_) => SparePartsProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => AlarmProvider()),

        // this basically says that SystemStateProvider depends on RecipeProvider and AlarmProvider
        // this is important because SystemStateProvider needs to know the active recipe and alarm status to function properly
        // without this dependency, SystemStateProvider would not be able to access RecipeProvider and AlarmProvider
        // it has to be here because SystemStateProvider is not a direct child of the main widget
        // what changenotifierproxyprovider does is that it provides the value of RecipeProvider and AlarmProvider to SystemStateProvider
        ChangeNotifierProxyProvider2<RecipeProvider, AlarmProvider, SystemStateProvider>(
          create: (context) => SystemStateProvider(
            context.read<RecipeProvider>(),
            context.read<AlarmProvider>(),
          ),
          update: (context, recipeProvider, alarmProvider, previous) =>
          previous ?? SystemStateProvider(recipeProvider, alarmProvider),
        ),



        // ReportProvider depends on MaintenanceProvider and CalibrationProvider
        ChangeNotifierProxyProvider2<MaintenanceProvider, CalibrationProvider, ReportProvider>(
          create: (ctx) => _initReportProvider(ctx),
          update: (ctx, maintenance, calibration, previous) =>
              ReportProvider(maintenance, calibration),
        ),
      ],
      child: MaterialApp(
        title: 'Tesla ALD Machine Maintenance',
        navigatorKey: Provider.of<NavigationService>(context, listen: false).navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: _getTeslaTheme(),
        home: MainScreen(),
        routes: {
          '/maintenance': (ctx) => MaintenanceHomeScreen(),
          '/calibration': (ctx) => CalibrationScreen(),
          '/troubleshooting': (ctx) => TroubleshootingScreen(),
          '/spare_parts': (ctx) => SparePartsScreen(),
          '/documentation': (ctx) => DocumentationScreen(),
          '/reporting': (ctx) => ReportingScreen(),
          '/remote_assistance': (ctx) => RemoteAssistanceScreen(),
          '/safety_procedures': (ctx) => SafetyProceduresScreen(),
          '/system_overview': (ctx) => SystemOverviewScreen(),
          '/recipe_management': (ctx) => RecipeManagementScreen(),
        },
      ),
    );
  }

  ThemeData _getTeslaTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF2C2C2C),    // Dark Grey
        secondary: Color(0xFF4A4A4A),  // Light Grey
        background: Color(0xFF121212), // Very Dark Grey (Almost Black)
        surface: Color(0xFF1E1E1E),    // Dark Surface
        onBackground: Colors.white,
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
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  NavigationItem _selectedItem = NavigationItem.mainDashboard;

  void _selectNavigationItem(NavigationItem item) {
    setState(() {
      _selectedItem = item;
    });
    if (MediaQuery.of(context).size.width <= 800) {
      Navigator.of(context).pop();
    }
  }

  Widget _getSelectedScreen() {
    switch (_selectedItem) {
      case NavigationItem.mainDashboard:
        return MainDashboard();
      case NavigationItem.recipeManagement:
        return RecipeManagementScreen();
      case NavigationItem.calibration:
        return CalibrationScreen();
      case NavigationItem.reporting:
        return ReportingScreen();
      case NavigationItem.troubleshooting:
        return TroubleshootingScreen();
      case NavigationItem.spareParts:
        return SparePartsScreen();
      case NavigationItem.documentation:
        return DocumentationScreen();
      case NavigationItem.remoteAssistance:
        return RemoteAssistanceScreen();
      case NavigationItem.safetyProcedures:
        return SafetyProceduresScreen();
      case NavigationItem.overview:
        return MaintenanceHomeScreen();
      default:
        return MainDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 800;
    return LayoutBuilder(builder: (context, constraints) {
      if (isLargeScreen) {
        return Row(
          children: [
            Container(
              width: 240,
              color: Theme.of(context).drawerTheme.backgroundColor,
              child: AppDrawer(
                onSelectItem: _selectNavigationItem,
                selectedItem: _selectedItem,
              ),
            ),
            Expanded(
              child: PageTransitionSwitcher(
                duration: Duration(milliseconds: 300),
                transitionBuilder: (child, animation, secondaryAnimation) =>
                    FadeThroughTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      child: child,
                    ),
                child: _getSelectedScreen(),
              ),
            ),
          ],
        );
      } else {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text('Tesla ALD Maintenance'),
            actions: [
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  // Implement search functionality
                },
              ),
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () {
                  // Implement notifications functionality
                },
              ),
            ],
          ),
          drawer: Container(
            width: 240,
            child: AppDrawer(
              onSelectItem: _selectNavigationItem,
              selectedItem: _selectedItem,
            ),
          ),
          body: PageTransitionSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (child, animation, secondaryAnimation) =>
                FadeThroughTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  child: child,
                ),
            child: _getSelectedScreen(),
          ),
        );
      }
    });
  }
}