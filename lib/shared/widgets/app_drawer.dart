import 'package:flutter/material.dart';
import '../../core/enums/navigation_item.dart';
import '../../core/enums/user_role.dart';
import '../../features/auth/providers/auth_provider.dart';
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
                  Icons.precision_manufacturing,
                  color: Theme.of(context).iconTheme.color,
                  size: 48,
                ),
                SizedBox(height: 8),
                Text(
                  'ALD System Operations',
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
          _buildDrawerItem(
            context: context,
            icon: Icons.monitor,
            text: 'System Overview',
            isSelected: selectedItem == NavigationItem.systemOverview,
            onTap: () => onSelectItem(NavigationItem.systemOverview),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.book,
            text: 'Recipe Management',
            isSelected: selectedItem == NavigationItem.recipeManagement,
            onTap: () => onSelectItem(NavigationItem.recipeManagement),
          ),
          if (isAdmin)
            _buildDrawerItem(
              context: context,
              icon: Icons.admin_panel_settings,
              text: 'Admin Dashboard',
              isSelected: selectedItem == NavigationItem.adminDashboard,
              onTap: () => onSelectItem(NavigationItem.adminDashboard),
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
      leading: Icon(
        icon,
        color: isSelected ? theme.colorScheme.secondary : theme.iconTheme.color,
      ),
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