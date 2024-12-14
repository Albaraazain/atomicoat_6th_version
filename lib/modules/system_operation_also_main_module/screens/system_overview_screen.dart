// lib/modules/system_operation_also_main_module/screens/system_overview_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/system_state/bloc/system_state_bloc.dart';
import '../../../blocs/system_state/bloc/system_state_state.dart';
import '../widgets/system_diagram_view.dart';
import '../widgets/component_control_overlay.dart';
import '../widgets/graph_overlay.dart';
import '../widgets/troubleshooting_overlay.dart';
import '../widgets/system_status_indicator.dart';
import '../widgets/recipe_progress_indicator.dart';
import '../widgets/alarm_indicator.dart';
import '../widgets/recipe_control.dart';
import '../widgets/system_readiness_indicator.dart';  // New import

class SystemIssuesDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SystemStateBloc, SystemStateState>(
      builder: (context, state) {
        final issues = state.systemIssues;

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
      },
    );
  }
}

class SystemOverviewScreen extends StatefulWidget {
  const SystemOverviewScreen({Key? key}) : super(key: key);

  @override
  _SystemOverviewScreenState createState() => _SystemOverviewScreenState();
}

class _SystemOverviewScreenState extends State<SystemOverviewScreen> {
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
      body: BlocBuilder<SystemStateBloc, SystemStateState>(
        builder: (context, state) {
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
              if (state.status == SystemOperationalStatus.running)
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
                        'System Running',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              SystemReadinessIndicator(),
            ],
          );
        },
      ),
    );
  }
}