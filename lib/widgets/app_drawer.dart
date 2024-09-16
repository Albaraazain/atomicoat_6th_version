import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);

    return Drawer(
      child: Container(
        color: theme.colorScheme.background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.electric_car,
                    color: theme.colorScheme.primary,
                    size: 48,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tesla ALD Maintenance',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            _buildSectionHeader(theme, 'Maintenance'),
            _buildDrawerItem(theme, Icons.home_repair_service, 'Home', NavigationItem.mainDashboard),
            _buildDrawerItem(theme, Icons.calendar_today, 'Schedule', NavigationItem.schedule),
            _buildDrawerItem(theme, Icons.science, 'Calibration', NavigationItem.calibration),
            _buildDrawerItem(theme, Icons.assessment, 'Reports', NavigationItem.reports),
            _buildDrawerItem(theme, Icons.report, 'Reporting', NavigationItem.reporting),
            _buildDrawerItem(theme, Icons.help, 'Troubleshooting', NavigationItem.troubleshooting),
            _buildDrawerItem(theme, Icons.inventory, 'Spare Parts', NavigationItem.spareParts),
            _buildDrawerItem(theme, Icons.library_books, 'Documentation', NavigationItem.documentation),
            _buildDrawerItem(theme, Icons.video_call, 'Remote Assistance', NavigationItem.remoteAssistance),
            _buildDrawerItem(theme, Icons.health_and_safety, 'Safety Procedures', NavigationItem.safetyProcedures),

            Divider(color: theme.colorScheme.onBackground.withOpacity(0.1)),

            _buildSectionHeader(theme, 'System Operation'),
            _buildDrawerItem(theme, Icons.dashboard_customize, 'Main Dashboard', NavigationItem.mainDashboard),
            _buildDrawerItem(theme, Icons.book, 'Recipe Management', NavigationItem.recipeManagement),

            Divider(color: theme.colorScheme.onBackground.withOpacity(0.1)),

            _buildSectionHeader(theme, 'Others'),
            _buildDrawerItem(theme, Icons.person, 'Profile', NavigationItem.profile),
            _buildDrawerItem(theme, Icons.settings_applications, 'Settings', NavigationItem.settings),
            _buildDrawerItem(theme, Icons.help_outline, 'Help & Support', NavigationItem.helpSupport),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(ThemeData theme, IconData icon, String text, NavigationItem item) {
    final isSelected = selectedItem == item;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? theme.colorScheme.secondary : theme.colorScheme.onBackground.withOpacity(0.7),
      ),
      title: Text(
        text,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isSelected ? theme.colorScheme.secondary : theme.colorScheme.onBackground,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: theme.colorScheme.secondary.withOpacity(0.1),
      onTap: () => onSelectItem(item),
    );
  }
}