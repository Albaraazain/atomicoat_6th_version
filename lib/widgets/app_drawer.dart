import 'package:flutter/material.dart';

// Import Enums
import '../enums/navigation_item.dart';

class AppDrawer extends StatelessWidget {
  final Function(NavigationItem) onSelectItem;
  final NavigationItem selectedItem;

  AppDrawer({
    required this.onSelectItem,
    required this.selectedItem,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).drawerTheme.backgroundColor, // Ensure the background color is consistent
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Drawer Header with updated styling
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface, // Consistent color for the header
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.build,
                  color: Theme.of(context).iconTheme.color, // Consistent icon color
                  size: 48,
                ),
                SizedBox(height: 8),
                Text(
                  'ALD Machine Maintenance',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface, // Text style from theme
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // **Maintenance Module Section**
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Maintenance',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.home_repair_service,
            text: 'Home',
            isSelected: selectedItem == NavigationItem.mainDashboard,
            onTap: () {
              onSelectItem(NavigationItem.mainDashboard);
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.calendar_today,
            text: 'Schedule',
            isSelected: selectedItem == NavigationItem.schedule,
            onTap: () {
              onSelectItem(NavigationItem.schedule);
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.science,
            text: 'Calibration',
            isSelected: selectedItem == NavigationItem.calibration,
            onTap: () {
              onSelectItem(NavigationItem.calibration);
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.assessment,
            text: 'Reports',
            isSelected: selectedItem == NavigationItem.reports,
            onTap: () {
              onSelectItem(NavigationItem.reports);
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.report,
            text: 'Reporting',
            isSelected: selectedItem == NavigationItem.reporting,
            onTap: () {
              onSelectItem(NavigationItem.reporting);
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.help,
            text: 'Troubleshooting',
            isSelected: selectedItem == NavigationItem.troubleshooting,
            onTap: () {
              onSelectItem(NavigationItem.troubleshooting);
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.inventory,
            text: 'Spare Parts',
            isSelected: selectedItem == NavigationItem.spareParts,
            onTap: () {
              onSelectItem(NavigationItem.spareParts);
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.library_books,
            text: 'Documentation',
            isSelected: selectedItem == NavigationItem.documentation,
            onTap: () {
              onSelectItem(NavigationItem.documentation);
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.video_call,
            text: 'Remote Assistance',
            isSelected: selectedItem == NavigationItem.remoteAssistance,
            onTap: () {
              onSelectItem(NavigationItem.remoteAssistance);
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.health_and_safety,
            text: 'Safety Procedures',
            isSelected: selectedItem == NavigationItem.safetyProcedures,
            onTap: () {
              onSelectItem(NavigationItem.safetyProcedures);
            },
          ),

          Divider(color: Theme.of(context).dividerTheme.color), // Consistent divider

          // **System Operation Module Section**
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'System Operation',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.dashboard_customize,
            text: 'Main Dashboard',
            isSelected: selectedItem == NavigationItem.mainDashboard,
            onTap: () {
              onSelectItem(NavigationItem.mainDashboard);
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.book,
            text: 'Recipe Management',
            isSelected: selectedItem == NavigationItem.recipeManagement,
            onTap: () {
              onSelectItem(NavigationItem.recipeManagement);
            },
          ),

          Divider(color: Theme.of(context).dividerTheme.color), // Consistent divider

          // **Others Section**
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Others',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.person,
            text: 'Profile',
            isSelected: selectedItem == NavigationItem.profile,
            onTap: () {
              onSelectItem(NavigationItem.profile);
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.settings_applications,
            text: 'Settings',
            isSelected: selectedItem == NavigationItem.settings,
            onTap: () {
              onSelectItem(NavigationItem.settings);
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.help_outline,
            text: 'Help & Support',
            isSelected: selectedItem == NavigationItem.helpSupport,
            onTap: () {
              onSelectItem(NavigationItem.helpSupport);
            },
          ),
        ],
      ),
    );
  }

  // Helper method to build a drawer item with selection highlighting
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
