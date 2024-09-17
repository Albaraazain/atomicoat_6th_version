// lib/widgets/graph_overlay.dart

import 'dart:convert';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/system_component.dart';
import '../providers/system_state_provider.dart';

class GraphOverlay extends StatefulWidget {
  final String overlayId;

  GraphOverlay({required this.overlayId});

  @override
  _GraphOverlayState createState() => _GraphOverlayState();
}

class _GraphOverlayState extends State<GraphOverlay> {
  Map<String, Offset> _componentPositions = {};
  Size _diagramSize = Size.zero;
  bool _isEditMode = false; // Tracks edit mode

  // Define a color palette for components
  final Map<String, Color> componentColors = {
    'Nitrogen Generator': Colors.blueAccent,
    'MFC': Colors.green,
    'Backline Heater': Colors.orange,
    'Frontline Heater': Colors.purple,
    'Precursor Heater 1': Colors.teal,
    'Precursor Heater 2': Colors.indigo,
    'Reaction Chamber': Colors.redAccent,
    'Pressure Control System': Colors.cyan,
    'Vacuum Pump': Colors.amber,
    'Valve 1': Colors.brown,
    'Valve 2': Colors.pink,
  };

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
      print("Diagram size updated: $_diagramSize");
      // Initialize default positions after diagram size is known
      if (_componentPositions.isEmpty) {
        _initializeDefaultPositions();
      }
    }
  }

  Future<void> _resetComponentPositions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('component_positions_graph_overlay_${widget.overlayId}');
    _initializeDefaultPositions();
    setState(() {}); // Refresh the UI
    print("Component positions have been reset.");
  }

  void _initializeDefaultPositions() {
    if (_diagramSize == Size.zero) return; // Diagram size not yet available

    setState(() {
      _componentPositions = {
        'Nitrogen Generator': Offset(_diagramSize.width * 0.05, _diagramSize.height * 0.80),
        'MFC': Offset(_diagramSize.width * 0.20, _diagramSize.height * 0.70),
        'Backline Heater': Offset(_diagramSize.width * 0.35, _diagramSize.height * 0.60),
        'Frontline Heater': Offset(_diagramSize.width * 0.50, _diagramSize.height * 0.50),
        'Precursor Heater 1': Offset(_diagramSize.width * 0.65, _diagramSize.height * 0.40),
        'Precursor Heater 2': Offset(_diagramSize.width * 0.80, _diagramSize.height * 0.30),
        'Reaction Chamber': Offset(_diagramSize.width * 0.50, _diagramSize.height * 0.20),
        'Pressure Control System': Offset(_diagramSize.width * 0.75, _diagramSize.height * 0.75),
        'Vacuum Pump': Offset(_diagramSize.width * 0.85, _diagramSize.height * 0.85),
        'Valve 1': Offset(_diagramSize.width * 0.60, _diagramSize.height * 0.60),
        'Valve 2': Offset(_diagramSize.width * 0.60, _diagramSize.height * 0.40),
      };
    });
    print("Default component positions initialized.");
    _saveComponentPositions();
  }

  Future<void> _loadComponentPositions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final positionsJson = prefs.getString('component_positions_graph_overlay_${widget.overlayId}');

      if (positionsJson != null) {
        final positionsMap = jsonDecode(positionsJson) as Map<String, dynamic>;
        setState(() {
          _componentPositions = positionsMap.map((key, value) {
            final offsetList = (value as List<dynamic>).cast<double>();
            return MapEntry(key, Offset(offsetList[0], offsetList[1]));
          });
        });
        print("Loaded component positions from SharedPreferences.");
      } else {
        // Initialize default positions if no saved positions are found
        _initializeDefaultPositions();
        print("No saved component positions found. Initialized defaults.");
      }
    } catch (e) {
      print("Error loading component positions: $e");
      // Handle error or initialize default positions
      _initializeDefaultPositions();
    }
  }

  Future<void> _saveComponentPositions() async {
    final prefs = await SharedPreferences.getInstance();
    final positionsMap = _componentPositions.map((key, value) {
      return MapEntry(key, [value.dx, value.dy]);
    });
    await prefs.setString('component_positions_graph_overlay_${widget.overlayId}', jsonEncode(positionsMap));
    print("Component positions saved to SharedPreferences.");
  }

  @override
  Widget build(BuildContext context) {
    // Define graph sizes based on overlayId
    double graphWidth;
    double graphHeight;
    double fontSize;

    if (widget.overlayId == 'main_dashboard') {
      // Smaller graphs for the small diagram view
      graphWidth = 60; // Reduced from 80 to 60
      graphHeight = 50; // Reduced from 60 to 50
      fontSize = 7; // Reduced from 8 to 7
    } else {
      // Default sizes for the full diagram view
      graphWidth = 120; // Reduced from 150 to 120
      graphHeight = 100; // Reduced from 100 to 80
      fontSize = 9; // Reduced from 10 to 9
    }

    // Offsets to center the graphs at the component positions
    double horizontalOffset = graphWidth / 2;
    double verticalOffset = graphHeight / 2;

    return Stack(
      children: [
        Consumer<SystemStateProvider>(
          builder: (context, systemStateProvider, child) {
            print("Consumer rebuilding. Components count: ${systemStateProvider.components.length}");
            return LayoutBuilder(
              builder: (context, constraints) {
                print("LayoutBuilder: ${constraints.maxWidth} x ${constraints.maxHeight}");

                return Stack(
                  children: _componentPositions.entries.map((entry) {
                    final componentName = entry.key;
                    final componentPosition = entry.value;

                    final component = systemStateProvider.getComponentByName(componentName);
                    if (component == null) {
                      print("Component not found: $componentName");
                      return SizedBox.shrink();
                    }

                    final parameterToPlot = _getParameterToPlot(component);
                    if (parameterToPlot == null) {
                      print("No parameter to plot for: $componentName");
                      return SizedBox.shrink();
                    }

                    // Calculate absolute position based on componentPosition
                    final left = componentPosition.dx - horizontalOffset;
                    final top = componentPosition.dy - verticalOffset;

                    return Positioned(
                      left: left,
                      top: top,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanUpdate: _isEditMode
                            ? (details) {
                          setState(() {
                            // Update position while dragging
                            _componentPositions[componentName] = Offset(
                              _componentPositions[componentName]!.dx + details.delta.dx,
                              _componentPositions[componentName]!.dy + details.delta.dy,
                            );
                          });
                        }
                            : null,
                        onPanEnd: _isEditMode
                            ? (_) {
                          // Save positions when dragging ends
                          _saveComponentPositions();
                        }
                            : null,
                        child: Container(
                          width: graphWidth,
                          height: graphHeight,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.all(4),
                          child: Column(
                            children: [
                              Text(
                                '$componentName\n($parameterToPlot)',
                                style: TextStyle(color: Colors.white, fontSize: fontSize),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 4),
                              Expanded(
                                child: _buildMinimalGraph(component, parameterToPlot),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList()
                  // Add Reset Button
                    ..add(
                      Positioned(
                        top: 40,
                        right: widget.overlayId == 'main_dashboard' ? 8 : null,
                        left: widget.overlayId != 'main_dashboard' ? 8 : null,
                        child: GestureDetector(
                          onTap: _resetToCenter,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.restore,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                );
              },
            );
          },
        ),
        // Toggle Edit Mode Button
        Positioned(
          top: 8,
          right: widget.overlayId == 'main_dashboard' ? 8 : null,
          left: widget.overlayId != 'main_dashboard' ? 8 : null,
          child: _buildEditModeToggle(),
        ),
        // Legend Positioned at Bottom Right (Optional: Remove for Minimalistic Look)
        // Positioned(
        //   bottom: 16,
        //   right: 16,
        //   child: Container(
        //     padding: EdgeInsets.all(8),
        //     decoration: BoxDecoration(
        //       color: Colors.black54,
        //       borderRadius: BorderRadius.circular(8),
        //     ),
        //     child: Wrap(
        //       spacing: 8,
        //       runSpacing: 4,
        //       children: componentColors.entries.map((entry) {
        //         return Row(
        //           mainAxisSize: MainAxisSize.min,
        //           children: [
        //             Container(
        //               width: 12,
        //               height: 12,
        //               color: entry.value,
        //             ),
        //             SizedBox(width: 4),
        //             Text(
        //               entry.key,
        //               style: TextStyle(color: Colors.white, fontSize: 10),
        //             ),
        //           ],
        //         );
        //       }).toList(),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildEditModeToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isEditMode = !_isEditMode;
        });
        print("Edit mode toggled: $_isEditMode");
      },
      child: Container(
        decoration: BoxDecoration(
          color: _isEditMode ? Colors.blueAccent : Colors.grey,
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(8),
        child: Icon(
          _isEditMode ? Icons.lock_open : Icons.lock,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  void _resetToCenter() {
    final centerX = _diagramSize.width / 2;
    final centerY = _diagramSize.height / 2;

    setState(() {
      _componentPositions = _componentPositions.map((key, value) {
        // Position each component relative to the center
        double newX;
        double newY;

        switch (key) {
          case 'Nitrogen Generator':
            newX = centerX * 0.2;
            newY = centerY * 1.6;
            break;
          case 'MFC':
            newX = centerX * 0.4;
            newY = centerY * 1.4;
            break;
          case 'Backline Heater':
            newX = centerX * 0.7;
            newY = centerY * 1.2;
            break;
          case 'Frontline Heater':
            newX = centerX;
            newY = centerY;
            break;
          case 'Precursor Heater 1':
            newX = centerX * 1.3;
            newY = centerY * 0.8;
            break;
          case 'Precursor Heater 2':
            newX = centerX * 1.6;
            newY = centerY * 0.6;
            break;
          case 'Reaction Chamber':
            newX = centerX;
            newY = centerY * 0.4;
            break;
          case 'Pressure Control System':
            newX = centerX * 1.5;
            newY = centerY * 1.5;
            break;
          case 'Vacuum Pump':
            newX = centerX * 1.7;
            newY = centerY * 1.7;
            break;
          case 'Valve 1':
            newX = centerX * 0.6;
            newY = centerY * 0.6;
            break;
          case 'Valve 2':
            newX = centerX * 0.6;
            newY = centerY * 0.4;
            break;
          default:
            newX = centerX;
            newY = centerY;
        }

        print("Resetting $key to position: ($newX, $newY)");

        return MapEntry(key, Offset(newX, newY));
      });
    });

    _saveComponentPositions(); // Save these new positions
  }

  String? _getParameterToPlot(SystemComponent component) {
    switch (component.name) {
      case 'Nitrogen Generator':
        return 'flow_rate';
      case 'MFC':
        return 'flow_rate';
      case 'Backline Heater':
      case 'Frontline Heater':
      case 'Precursor Heater 1':
      case 'Precursor Heater 2':
        return 'temperature';
      case 'Reaction Chamber':
        return 'pressure';
      case 'Pressure Control System':
        return 'pressure';
      case 'Vacuum Pump':
        return 'power';
      case 'Valve 1':
      case 'Valve 2':
        return 'status';
      default:
        return null;
    }
  }

  double _calculateYRange(SystemComponent component, String parameter, double? setValue) {
    final dataPoints = component.parameterHistory[parameter];
    if (dataPoints == null || dataPoints.isEmpty) {
      return 1.0; // Default range
    }

    double maxY = dataPoints.map((dp) => dp.value).reduce(max);
    double minY = dataPoints.map((dp) => dp.value).reduce(min);

    if (setValue != null) {
      maxY = max(maxY, setValue + 1);
      minY = min(minY, setValue - 1);
    }

    // Ensure a minimum range
    if (maxY - minY < 2.0) {
      maxY += 1.0;
      minY -= 1.0;
    }

    return (maxY - minY) / 2; // Calculate range around setValue
  }

  Widget _buildMinimalGraph(SystemComponent component, String parameter) {
    final dataPoints = component.parameterHistory[parameter];

    if (dataPoints == null || dataPoints.isEmpty) {
      print('No data available for $parameter in ${component.name}');
      return Container(
        color: Colors.black26,
        child: Center(
          child: Text(
            component.isActivated ? 'Waiting...' : 'Inactive',
            style: TextStyle(color: Colors.white, fontSize: 8),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    print('Building graph for $parameter in ${component.name}. Data points count: ${dataPoints.length}');

    // Get the set value for the parameter
    double? setValue = component.setValues[parameter];

    // Convert data points to FlSpot
    final firstTimestamp = dataPoints.first.timestamp.millisecondsSinceEpoch.toDouble();
    List<FlSpot> spots = dataPoints.map((dp) {
      double x = (dp.timestamp.millisecondsSinceEpoch.toDouble() - firstTimestamp) / 1000; // in seconds
      double y = dp.value;
      return FlSpot(x, y);
    }).toList();

    // Calculate Y-axis range
    double yRange = _calculateYRange(component, parameter, setValue);

    // Set minY and maxY based on setValue and yRange
    double minY = setValue != null ? setValue - yRange : dataPoints.map((dp) => dp.value).reduce(min) - 1;
    double maxY = setValue != null ? setValue + yRange : dataPoints.map((dp) => dp.value).reduce(max) + 1;

    // Ensure minY and maxY are reasonable
    if (maxY - minY < 1) {
      minY = minY - 1;
      maxY = maxY + 1;
    }

    // Determine the maxX value
    double maxX = spots.isNotEmpty ? spots.last.x : 60;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          // Actual parameter line
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: componentColors[component.name] ?? Colors.white,
            barWidth: 2, // Reduced line width for minimal look
            dotData: FlDotData(show: false),
          ),
          // Reference line for set value (optional: remove for more minimal look)
          if (setValue != null)
            LineChartBarData(
              spots: [
                FlSpot(0, setValue),
                FlSpot(maxX, setValue),
              ],
              isCurved: false,
              color: Colors.grey,
              barWidth: 1,
              dotData: FlDotData(show: false),
              dashArray: [5, 5],
            ),
        ],
        titlesData: FlTitlesData(
          show: false, // Hide all titles for minimal look
        ),
        gridData: FlGridData(
          show: false, // Hide grid lines
        ),
        borderData: FlBorderData(
          show: false, // Hide borders
        ),
        lineTouchData: LineTouchData(
          enabled: false, // Disable touch interactions
        ),
      ),
    );
  }
}
