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
        // back button
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
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'system_overview_fab', // Unique tag for this FloatingActionButton
        mini: true,
        child: Icon(Icons.refresh, size: 20),
        onPressed: () {
          Provider.of<SystemStateProvider>(context, listen: false).refreshRecipes();
        },
        tooltip: 'Refresh System State',
      ),
    );
  }
}