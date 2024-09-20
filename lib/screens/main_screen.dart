import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../enums/navigation_item.dart';
import '../widgets/app_drawer.dart';
import '../modules/system_operation_also_main_module/screens/main_dashboard.dart';
import '../modules/maintenance_module/screens/maintenance_home_screen.dart';
import '../modules/maintenance_module/screens/calibration_screen.dart';
import '../modules/maintenance_module/screens/reporting_screen.dart';
import '../modules/maintenance_module/screens/troubleshooting_screen.dart';
import '../modules/maintenance_module/screens/spare_parts_screen.dart';
import '../modules/maintenance_module/screens/documentation_screen.dart';
import '../modules/maintenance_module/screens/remote_assistance_screen.dart';
import '../modules/maintenance_module/screens/safety_procedures_screen.dart';
import '../modules/system_operation_also_main_module/screens/recipe_management_screen.dart';
import '../screens/admin_dashboard_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  NavigationItem _selectedItem = NavigationItem.mainDashboard;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      drawer: isLargeScreen ? null : _buildDrawer(),
      body: SafeArea(
        child: Row(
          children: [
            if (isLargeScreen) _buildDrawer(),
            Expanded(
              child: _getSelectedScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Container(
      width: 240,
      child: AppDrawer(
        onSelectItem: _selectNavigationItem,
        selectedItem: _selectedItem,
      ),
    );
  }

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
      case NavigationItem.adminDashboard:
        return AdminDashboardScreen();
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
}