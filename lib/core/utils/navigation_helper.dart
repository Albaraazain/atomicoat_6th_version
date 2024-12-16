import 'package:flutter/material.dart';
import '../enums/navigation_item.dart';
import '../../screens/main_screen.dart';
import '../../features/system/screens/admin_dashboard_screen.dart';
import '../../features/system/screens/main_dashboard.dart';
import '../../features/recipes/screens/recipe_management_screen.dart';
import '../../features/system/screens/system_overview_screen.dart';

void handleNavigation(BuildContext context, NavigationItem item) {
  switch (item) {
    case NavigationItem.mainDashboard:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainDashboard())
      );
      break;
    case NavigationItem.systemOverview:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SystemOverviewScreen())
      );
      break;
    case NavigationItem.recipeManagement:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => RecipeManagementScreen())
      );
      break;
    case NavigationItem.adminDashboard:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AdminDashboardScreen())
      );
      break;
  }
}