import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/system_component.dart';
import '../providers/system_state_provider.dart';

class TroubleshootingOverlay extends StatefulWidget {
  final String overlayId; // Added to distinguish between instances

  TroubleshootingOverlay({required this.overlayId});

  @override
  _TroubleshootingOverlayState createState() => _TroubleshootingOverlayState();
}

class _TroubleshootingOverlayState extends State<TroubleshootingOverlay> {
  Map<String, Offset> _componentPositions = {};
  Size _diagramSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _loadComponentPositions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateDiagramSize();
    });
  }

  void _updateDiagramSize() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _diagramSize = renderBox.size;
      });
      // Initialize default positions after diagram size is known
      if (_componentPositions.isEmpty) {
        _initializeDefaultPositions();
      }
    }
  }

  Future<void> _resetComponentPositions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('component_positions_troubleshooting_overlay_${widget.overlayId}');
    _initializeDefaultPositions();
    setState(() {}); // Refresh the UI
  }

  void _initializeDefaultPositions() {
    if (_diagramSize == Size.zero) return; // Diagram size not yet available

    setState(() {
      _componentPositions = {
        'Nitrogen Generator': Offset(_diagramSize.width * 0.10, _diagramSize.height * 0.80),
        'MFC': Offset(_diagramSize.width * 0.20, _diagramSize.height * 0.70),
        'Backline Heater': Offset(_diagramSize.width * 0.30, _diagramSize.height * 0.60),
        'Frontline Heater': Offset(_diagramSize.width * 0.40, _diagramSize.height * 0.50),
        'Precursor Heater 1': Offset(_diagramSize.width * 0.50, _diagramSize.height * 0.40),
        'Precursor Heater 2': Offset(_diagramSize.width * 0.60, _diagramSize.height * 0.30),
        'Reaction Chamber': Offset(_diagramSize.width * 0.70, _diagramSize.height * 0.20),
        'Valve 1': Offset(_diagramSize.width * 0.80, _diagramSize.height * 0.10),
        'Valve 2': Offset(_diagramSize.width * 0.85, _diagramSize.height * 0.10),
        'Pressure Control System': Offset(_diagramSize.width * 0.75, _diagramSize.height * 0.75),
        'Vacuum Pump': Offset(_diagramSize.width * 0.85, _diagramSize.height * 0.85),
      };
    });
  }

  Future<void> _loadComponentPositions() async {
    final prefs = await SharedPreferences.getInstance();
    final positionsJson = prefs.getString('component_positions_troubleshooting_overlay_${widget.overlayId}');

    if (positionsJson != null) {
      final positionsMap = jsonDecode(positionsJson) as Map<String, dynamic>;
      setState(() {
        _componentPositions = positionsMap.map((key, value) {
          final offsetList = (value as List<dynamic>).cast<double>();
          return MapEntry(key, Offset(offsetList[0], offsetList[1]));
        });
      });
    } else {
      // Initialize default positions if no saved positions are found
      _initializeDefaultPositions();
    }
  }

  Future<void> _saveComponentPositions() async {
    final prefs = await SharedPreferences.getInstance();
    final positionsMap = _componentPositions.map((key, value) {
      return MapEntry(key, [value.dx, value.dy]);
    });
    await prefs.setString('component_positions_troubleshooting_overlay_${widget.overlayId}', jsonEncode(positionsMap));
  }

  @override
  Widget build(BuildContext context) {
    print("creating troubleshooting overlay");
    return Consumer<SystemStateProvider>(
      builder: (context, systemStateProvider, child) {
        print("Number of components: ${systemStateProvider.components.length}");
        return Stack(
          children: _componentPositions.entries.map((entry) {
            final componentName = entry.key;
            final componentPosition = entry.value;

            // Get the component by name from the provider
            final component = systemStateProvider.getComponentByName(componentName);
if (component == null) return SizedBox.shrink();

            // Only display components that have warnings or errors
            if (component.status == ComponentStatus.normal) {
              return SizedBox.shrink();
            }

            // Calculate absolute position based on componentPosition
            final left = componentPosition.dx;
            final top = componentPosition.dy;

            return Positioned(
              left: left - 20, // Adjust to center the icon
              top: top - 20,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _componentPositions[componentName] = Offset(
                      _componentPositions[componentName]!.dx + details.delta.dx,
                      _componentPositions[componentName]!.dy + details.delta.dy,
                    );
                  });
                },
                onPanEnd: (_) {
                  _saveComponentPositions();
                },
                onTap: () => _showTroubleshootingDialog(context, component),
                child: Icon(
                  Icons.warning,
                  color: _getStatusColor(component.status),
                  size: 40,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showTroubleshootingDialog(BuildContext context, SystemComponent component) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Troubleshoot ${component.name}'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Text('Status: ${component.status.toString().split('.').last}'),
              SizedBox(height: 10),
              if (component.errorMessages.isNotEmpty)
                ...component.errorMessages.map((message) => Text('- $message')).toList()
              else
                Text('No error messages.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<SystemStateProvider>(context, listen: false).runDiagnostic(component.name);
              Navigator.of(context).pop();
            },
            child: Text('Run Diagnostic'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }


  Color _getStatusColor(ComponentStatus status) {
    switch (status) {
      case ComponentStatus.warning:
        return Colors.yellow;
      case ComponentStatus.error:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
