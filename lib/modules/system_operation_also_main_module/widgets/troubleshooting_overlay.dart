// lib/modules/system_operation_also_main_module/widgets/troubleshooting_overlay.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../blocs/component/bloc/component_list_bloc.dart';
import '../../../blocs/component/bloc/component_list_state.dart';
import '../../../blocs/component/bloc/component_list_event.dart';
import '../models/system_component.dart';

class TroubleshootingOverlay extends StatefulWidget {
  final String overlayId;

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
      if (_componentPositions.isEmpty) {
        _initializeDefaultPositions();
      }
    }
  }

  Future<void> _resetComponentPositions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('component_positions_troubleshooting_overlay_${widget.overlayId}');
    _initializeDefaultPositions();
    setState(() {});
  }

  void _initializeDefaultPositions() {
    if (_diagramSize == Size.zero) return;

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
    _saveComponentPositions();
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
    return BlocBuilder<ComponentListBloc, ComponentListState>(
      builder: (context, state) {
        return Stack(
          children: _componentPositions.entries.map((entry) {
            final componentName = entry.key;
            final component = state.components[componentName];
            final position = entry.value;

            if (component == null) return SizedBox.shrink();

            if (component.status == ComponentStatus.normal) {
              return SizedBox.shrink();
            }

            return Positioned(
              left: position.dx - 20,
              top: position.dy - 20,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _componentPositions[componentName] = Offset(
                      _componentPositions[componentName]!.dx + details.delta.dx,
                      _componentPositions[componentName]!.dy + details.delta.dy,
                    );
                  });
                },
                onPanEnd: (_) => _saveComponentPositions(),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: ${component.status.toString().split('.').last}'),
              SizedBox(height: 10),
              if (component.errorMessages.isNotEmpty)
                ...component.errorMessages.map((message) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(child: Text(message)),
                    ],
                  ),
                ))
              else
                Text('No error messages.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Trigger diagnostic through BLoC
              context.read<ComponentListBloc>().add(
                CheckSystemReadiness(),
              );
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