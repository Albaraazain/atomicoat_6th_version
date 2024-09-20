import 'package:flutter/material.dart';
import '../enums/navigation_item.dart';
import '../enums/user_role.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  final Function(NavigationItem) onSelectItem;
  final NavigationItem selectedItem;

  AppDrawer({
    required this.onSelectItem,
    required this.selectedItem,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.userRole == UserRole.admin;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.build,
                  color: Theme.of(context).iconTheme.color,
                  size: 48,
                ),
                SizedBox(height: 8),
                Text(
                  'ALD Machine Maintenance',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.dashboard,
            text: 'Main Dashboard',
            isSelected: selectedItem == NavigationItem.mainDashboard,
            onTap: () => onSelectItem(NavigationItem.mainDashboard),
          ),
          if (isAdmin)
            _buildDrawerItem(
              context: context,
              icon: Icons.admin_panel_settings,
              text: 'Admin Dashboard',
              isSelected: selectedItem == NavigationItem.adminDashboard,
              onTap: () => onSelectItem(NavigationItem.adminDashboard),
            ),
          _buildDrawerItem(
            context: context,
            icon: Icons.book,
            text: 'Recipe Management',
            isSelected: selectedItem == NavigationItem.recipeManagement,
            onTap: () => onSelectItem(NavigationItem.recipeManagement),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.science,
            text: 'Calibration',
            isSelected: selectedItem == NavigationItem.calibration,
            onTap: () => onSelectItem(NavigationItem.calibration),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.assessment,
            text: 'Reporting',
            isSelected: selectedItem == NavigationItem.reporting,
            onTap: () => onSelectItem(NavigationItem.reporting),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.help,
            text: 'Troubleshooting',
            isSelected: selectedItem == NavigationItem.troubleshooting,
            onTap: () => onSelectItem(NavigationItem.troubleshooting),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.inventory,
            text: 'Spare Parts',
            isSelected: selectedItem == NavigationItem.spareParts,
            onTap: () => onSelectItem(NavigationItem.spareParts),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.library_books,
            text: 'Documentation',
            isSelected: selectedItem == NavigationItem.documentation,
            onTap: () => onSelectItem(NavigationItem.documentation),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.video_call,
            text: 'Remote Assistance',
            isSelected: selectedItem == NavigationItem.remoteAssistance,
            onTap: () => onSelectItem(NavigationItem.remoteAssistance),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.health_and_safety,
            text: 'Safety Procedures',
            isSelected: selectedItem == NavigationItem.safetyProcedures,
            onTap: () => onSelectItem(NavigationItem.safetyProcedures),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.home_repair_service,
            text: 'Maintenance Overview',
            isSelected: selectedItem == NavigationItem.overview,
            onTap: () => onSelectItem(NavigationItem.overview),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: isSelected ? theme.colorScheme.secondary : theme.iconTheme.color),
      title: Text(
        text,
        style: theme.textTheme.bodyLarge!.copyWith(
          color: isSelected ? theme.colorScheme.secondary : theme.textTheme.bodyLarge!.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: theme.colorScheme.surface.withOpacity(0.2),
      onTap: onTap,
    );
  }
}