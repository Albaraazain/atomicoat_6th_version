// lib/modules/system_operation_also_main_module/screens/main_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../../providers/auth_provider.dart';
import '../providers/system_state_provider.dart';
import '../widgets/component_control_overlay.dart';
import '../widgets/data_visualization.dart';
import '../widgets/graph_overlay.dart';
import '../widgets/parameter_display.dart';
import '../widgets/recipe_control.dart';
import '../widgets/alarm_display.dart';
import '../widgets/system_diagram_view.dart';
import '../widgets/troubleshooting_overlay.dart';

class MainDashboard extends StatefulWidget {
  @override
  _MainDashboardState createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  final List<_TabItem> _tabs = [
    _TabItem(Icons.dashboard_rounded, 'Overview'),
    _TabItem(Icons.science_rounded, 'Recipe'),
    _TabItem(Icons.warning_rounded, 'Alarms'),
    _TabItem(Icons.analytics_rounded, 'Data'),
  ];

  int _selectedTabIndex = 0;
  late Widget _currentOverlay;

  @override
  void initState() {
    super.initState();
    _currentOverlay = ComponentControlOverlay(overlayId: 'main_dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Text('Main Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notifications not implemented yet')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildSpeedDial(context),
    );
  }


  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          return _buildTabItem(tab.icon, tab.label, index);
        }).toList(),
      ),
    ).animate().fadeIn(duration: 500.ms, curve: Curves.easeInOut);
  }

  Widget _buildTabItem(IconData icon, String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return InkWell(
      onTap: () => _selectTab(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Color(0xFF4A4A4A) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Color(0xFFD0D0D0) : Color(0xFF808080),
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Color(0xFFD0D0D0) : Color(0xFF808080),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTab(int index) {
    if (_selectedTabIndex != index) {
      setState(() => _selectedTabIndex = index);
    }
  }

  Widget _buildTabContent() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, -0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: _getSelectedTabContent(),
    );
  }

  Widget _getSelectedTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewTab(context);
      case 1:
        return _buildRecipeControlTab(context);
      case 2:
        return AlarmDisplay();
      case 3:
        return DataVisualization();
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildOverviewTab(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 600;
        return Column(
          children: [
            Expanded(
              flex: isLargeScreen ? 2 : 1,
              child: Card(
                margin: EdgeInsets.all(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      SystemDiagramView(
                        overlays: [_currentOverlay],
                        zoomFactor: 1.0,
                        enableOverlaySwiping: true,
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: _buildOverlaySelector(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ParameterDisplay(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed('/system_overview'),
                icon: Icon(Icons.fullscreen, size: 18),
                label: Text('Full System Overview', style: TextStyle(fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color(0xFFFFFFFF),
                  backgroundColor: Color(0xFF4A4A4A),
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOverlaySelector() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A).withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: PopupMenuButton<String>(
        icon: Icon(Icons.layers, color: Color(0xFFD0D0D0), size: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Color(0xFF3A3A3A),
        padding: EdgeInsets.zero,
        onSelected: (String value) {
          setState(() {
            switch (value) {
              case 'Control':
                _currentOverlay = ComponentControlOverlay(overlayId: 'main_dashboard');
                break;
              case 'Graph':
                _currentOverlay = GraphOverlay(overlayId: 'main_dashboard');
                break;
              case 'Troubleshoot':
                _currentOverlay = TroubleshootingOverlay(overlayId: 'main_dashboard');
                break;
            }
          });
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'Control',
            child: Text('Control', style: TextStyle(fontSize: 14, color: Color(0xFFD0D0D0))),
          ),
          PopupMenuItem<String>(
            value: 'Graph',
            child: Text('Graph', style: TextStyle(fontSize: 14, color: Color(0xFFD0D0D0))),
          ),
          PopupMenuItem<String>(
            value: 'Troubleshoot',
            child: Text('Troubleshoot', style: TextStyle(fontSize: 14, color: Color(0xFFD0D0D0))),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeControlTab(BuildContext context) {
    return RecipeControl(
    );
  }

  Widget _buildSpeedDial(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      backgroundColor: Color(0xFF3A3A3A),
      foregroundColor: Color(0xFFD0D0D0),
      visible: true,
      curve: Curves.easeInOut,
      children: [
        SpeedDialChild(
          child: Icon(Icons.stop, size: 24),
          backgroundColor: Color(0xFF8B0000),
          foregroundColor: Color(0xFFFFFFFF),
          label: 'Emergency Stop',
          labelStyle: TextStyle(fontSize: 14, color: Color(0xFFD0D0D0)),
          onTap: () => _handleEmergencyStop(context),
        ),
        SpeedDialChild(
          child: Icon(Icons.settings, size: 24),
          backgroundColor: Color(0xFF4A4A4A),
          foregroundColor: Color(0xFFD0D0D0),
          label: 'Settings',
          labelStyle: TextStyle(fontSize: 14, color: Color(0xFFD0D0D0)),
          onTap: () {
            // TODO: Implement settings navigation
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.help, size: 24),
          backgroundColor: Color(0xFF3A3A3A),
          foregroundColor: Color(0xFFD0D0D0),
          label: 'Help',
          labelStyle: TextStyle(fontSize: 14, color: Color(0xFFD0D0D0)),
          onTap: () {
            // TODO: Implement help functionality
          },
        ),
      ],
    );
  }

  void _handleEmergencyStop(BuildContext context) {
    Provider.of<SystemStateProvider>(context, listen: false).emergencyStop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Emergency Stop Activated!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Color(0xFF8B0000),
        duration: Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;

  _TabItem(this.icon, this.label);
}