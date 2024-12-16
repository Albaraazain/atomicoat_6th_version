import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/providers/auth_provider.dart';
import '../core/enums/navigation_item.dart';
import '../shared/widgets/app_drawer.dart';
import '../features/system/screens/main_dashboard.dart';
import '../features/recipes/screens/recipe_management_screen.dart';
import '../features/system/screens/system_overview_screen.dart';
import '../features/system/screens/admin_dashboard_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  NavigationItem _selectedItem = NavigationItem.mainDashboard;

  @override
  Widget build(BuildContext context) {
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
      case NavigationItem.systemOverview:
        return SystemOverviewScreen();
      case NavigationItem.recipeManagement:
        return RecipeManagementScreen();
      case NavigationItem.adminDashboard:
        return AdminDashboardScreen();
      default:
        return MainDashboard();
    }
  }
}