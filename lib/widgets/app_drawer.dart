// lib/widgets/app_drawer.dart

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
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueGrey[800],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.build,
                  color: Colors.white,
                  size: 48,
                ),
                SizedBox(height: 8),
                Text(
                  'ALD Machine Maintenance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
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
              style: TextStyle(
                color: Colors.blueGrey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.home_repair_service,
            text: 'Home',
            isSelected: selectedItem == NavigationItem.mainDashboard,
            onTap: () {
              onSelectItem(NavigationItem.mainDashboard);
            },
          ),
          _buildDrawerItem(
            icon: Icons.calendar_today,
            text: 'Schedule',
            isSelected: selectedItem == NavigationItem.schedule,
            onTap: () {
              onSelectItem(NavigationItem.schedule);
            },
          ),
          _buildDrawerItem(
            icon: Icons.science,
            text: 'Calibration',
            isSelected: selectedItem == NavigationItem.calibration,
            onTap: () {
              onSelectItem(NavigationItem.calibration);
            },
          ),
          _buildDrawerItem(
            icon: Icons.assessment,
            text: 'Reports',
            isSelected: selectedItem == NavigationItem.reports,
            onTap: () {
              onSelectItem(NavigationItem.reports);
            },
          ),
          _buildDrawerItem(
            icon: Icons.report,
            text: 'Reporting',
            isSelected: selectedItem == NavigationItem.reporting,
            onTap: () {
              onSelectItem(NavigationItem.reporting);
            },
          ),
          _buildDrawerItem(
            icon: Icons.help,
            text: 'Troubleshooting',
            isSelected: selectedItem == NavigationItem.troubleshooting,
            onTap: () {
              onSelectItem(NavigationItem.troubleshooting);
            },
          ),
          _buildDrawerItem(
            icon: Icons.inventory,
            text: 'Spare Parts',
            isSelected: selectedItem == NavigationItem.spareParts,
            onTap: () {
              onSelectItem(NavigationItem.spareParts);
            },
          ),
          _buildDrawerItem(
            icon: Icons.library_books,
            text: 'Documentation',
            isSelected: selectedItem == NavigationItem.documentation,
            onTap: () {
              onSelectItem(NavigationItem.documentation);
            },
          ),
          _buildDrawerItem(
            icon: Icons.video_call,
            text: 'Remote Assistance',
            isSelected: selectedItem == NavigationItem.remoteAssistance,
            onTap: () {
              onSelectItem(NavigationItem.remoteAssistance);
            },
          ),
          _buildDrawerItem(
            icon: Icons.health_and_safety,
            text: 'Safety Procedures',
            isSelected: selectedItem == NavigationItem.safetyProcedures,
            onTap: () {
              onSelectItem(NavigationItem.safetyProcedures);
            },
          ),

          Divider(), // Separator between sections

          // **System Operation Module Section**
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'System Operation',
              style: TextStyle(
                color: Colors.blueGrey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.dashboard_customize,
            text: 'Main Dashboard',
            isSelected: selectedItem == NavigationItem.mainDashboard,
            onTap: () {
              onSelectItem(NavigationItem.mainDashboard);
            },
          ),
          _buildDrawerItem(
            icon: Icons.book, // Icon for Recipe Management
            text: 'Recipe Management',
            isSelected: selectedItem == NavigationItem.recipeManagement,
            onTap: () {
              onSelectItem(NavigationItem.recipeManagement);
            },
          ),

          Divider(), // Separator between sections

          // **Others Section (Optional)**
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Others',
              style: TextStyle(
                color: Colors.blueGrey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.person,
            text: 'Profile',
            isSelected: selectedItem == NavigationItem.profile,
            onTap: () {
              onSelectItem(NavigationItem.profile);
            },
          ),
          _buildDrawerItem(
            icon: Icons.settings_applications,
            text: 'Settings',
            isSelected: selectedItem == NavigationItem.settings,
            onTap: () {
              onSelectItem(NavigationItem.settings);
            },
          ),
          _buildDrawerItem(
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
    required IconData icon,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blueAccent : null),
      title: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.blueAccent : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: onTap,
    );
  }
}
