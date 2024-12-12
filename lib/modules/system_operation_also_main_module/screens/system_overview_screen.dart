// lib/modules/system_operation_also_main_module/screens/system_overview_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/system_state_provider.dart';
import '../widgets/system_diagram_view.dart';
import '../widgets/component_control_overlay.dart';
import '../widgets/graph_overlay.dart';
import '../widgets/troubleshooting_overlay.dart';
import '../widgets/system_status_indicator.dart';
import '../widgets/recipe_progress_indicator.dart';
import '../widgets/alarm_indicator.dart';
import '../widgets/recipe_control.dart';

class SystemReadinessIndicator extends StatefulWidget {
  @override
  _SystemReadinessIndicatorState createState() => _SystemReadinessIndicatorState();
}

class _SystemReadinessIndicatorState extends State<SystemReadinessIndicator> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<SystemStateProvider>(
      builder: (context, systemProvider, child) {
        // First check if system is running
        if (systemProvider.isSystemRunning) {
          return AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.green.withOpacity(0.9),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.play_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'System Running${systemProvider.activeRecipe != null ? ': ${systemProvider.activeRecipe!.name}' : ''}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // If not running, show regular readiness status
        final issues = systemProvider.getSystemIssues();
        final isReady = issues.isEmpty;

        return AnimatedPositioned(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta! < -20) {
                setState(() => _isExpanded = true);
              } else if (details.primaryDelta! > 20) {
                setState(() => _isExpanded = false);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: isReady ? Colors.green.withOpacity(0.9) : Colors.red.withOpacity(0.9),
                  child: SafeArea(
                    top: false,
                    child: InkWell(
                      onTap: () => setState(() => _isExpanded = !_isExpanded),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              isReady ? Icons.check_circle : Icons.warning,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              isReady ? 'System Ready' : 'System Not Ready',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Icon(
                              _isExpanded ? Icons.expand_more : Icons.expand_less,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (_isExpanded && !isReady)
                  Container(
                    color: Colors.black87,
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                    child: SingleChildScrollView(
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Issues:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              ...issues.map((issue) => Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        issue,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SystemIssuesDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final systemProvider = Provider.of<SystemStateProvider>(context);
    final issues = systemProvider.getSystemIssues();

    return Container(
      width: 300,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Issues:',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          if (issues.isEmpty)
            Text('No issues detected', style: TextStyle(color: Colors.green))
          else
            ...issues.map((issue) =>
                Text('• $issue', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}

class SystemOverviewScreen extends StatefulWidget {
  const SystemOverviewScreen({Key? key}) : super(key: key);

  @override
  _SystemOverviewScreenState createState() => _SystemOverviewScreenState();
}

class _SystemOverviewScreenState extends State<SystemOverviewScreen> {
  final PageController _pageController = PageController();
  double _zoomFactor = 1.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('ALD System Overview'),
        actions: [
          IconButton(
            icon: Icon(Icons.zoom_in),
            onPressed: () {
              setState(() {
                _zoomFactor = _zoomFactor * 1.2;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.zoom_out),
            onPressed: () {
              setState(() {
                _zoomFactor = _zoomFactor / 1.2;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SystemStatusIndicator(),
          ),
        ],
      ),
      body: Consumer<SystemStateProvider>(
        builder: (context, systemProvider, child) {
          return Stack(
            children: [
              SystemDiagramView(
                overlays: [
                  ComponentControlOverlay(overlayId: 'full_overview'),
                  GraphOverlay(overlayId: 'full_overview'),
                  TroubleshootingOverlay(overlayId: 'full_overview'),
                ],
                zoomFactor: _zoomFactor,
                enableOverlaySwiping: true,
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Opacity(
                  opacity: 0.7,
                  child: Container(
                    width: 150,
                    child: RecipeProgressIndicator(),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Opacity(
                  opacity: 0.7,
                  child: Container(
                    width: 150,
                    child: AlarmIndicator(),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: RecipeControl(),
              ),
              if (systemProvider.activeRecipe != null)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Opacity(
                    opacity: 0.7,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Active: ${systemProvider.activeRecipe!.name}',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              // Add the new SystemReadinessIndicator
              SystemReadinessIndicator(),
            ],
          );
        },
      ),
    );
  }
}
