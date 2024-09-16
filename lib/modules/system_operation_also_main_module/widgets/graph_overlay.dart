import 'dart:convert';
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
  bool _isEditMode = false; // Added to track edit mode

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
    await prefs.remove('component_positions_graph_overlay_${widget.overlayId}');
    _initializeDefaultPositions();
    setState(() {}); // Refresh the UI
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
      };
    });
  }

  Future<void> _loadComponentPositions() async {
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
    await prefs.setString('component_positions_graph_overlay_${widget.overlayId}', jsonEncode(positionsMap));
  }

  @override
  Widget build(BuildContext context) {
    print("building graph overlay");
    // Define graph sizes based on overlayId
    double graphWidth;
    double graphHeight;
    double horizontalOffset;
    double verticalOffset;
    double fontSize;

    if (widget.overlayId == 'main_dashboard') {
      // Smaller graphs for the small diagram view
      graphWidth = 80;
      graphHeight = 60;
      fontSize = 8;
    } else {
      // Default sizes for the full diagram view
      graphWidth = 100;
      graphHeight = 80;
      fontSize = 10;
    }

    // Offsets to center the graphs at the component positions
    horizontalOffset = graphWidth / 2;
    verticalOffset = graphHeight / 2;

    return Stack(
      children: [
        Consumer<SystemStateProvider>(
          builder: (context, systemStateProvider, child) {
            print("Number of components: ${systemStateProvider.components.length}");
            return LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: _componentPositions.entries.map((entry) {
                    final componentName = entry.key;
                    final componentPosition = entry.value;

                    final component = systemStateProvider.getComponentByName(componentName);
                    if (component == null) return SizedBox.shrink();


                    final parameterToPlot = _getParameterToPlot(component);
                    if (parameterToPlot == null) return SizedBox.shrink();

                    // Calculate absolute position based on componentPosition
                    final left = componentPosition.dx - horizontalOffset;
                    final top = componentPosition.dy - verticalOffset;

                    return Positioned(
                      left: left - horizontalOffset, // Adjust to center the graph
                      top: top - verticalOffset,
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
                                child: _buildGraph(component, parameterToPlot),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList()
                    ..add(
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _buildEditModeToggle(),
                      ),
                    ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildEditModeToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isEditMode = !_isEditMode;
        });
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
      default:
        return null;
    }
  }

  Widget _buildGraph(SystemComponent component, String parameter) {
    final dataPoints = component.parameterHistory[parameter];

    if (dataPoints == null || dataPoints.isEmpty) {
      return Container(
        color: Colors.black26,
        child: Center(
          child: Text(
            component.isActivated ? 'Waiting for data...' : 'Component inactive',
            style: TextStyle(color: Colors.white, fontSize: 8),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    double? setValue = component.setValues[parameter];

    final firstTimestamp = dataPoints.first.timestamp.millisecondsSinceEpoch.toDouble();
    List<FlSpot> spots = dataPoints.map((dp) {
      double x = (dp.timestamp.millisecondsSinceEpoch.toDouble() - firstTimestamp) / 1000;
      double y = dp.value;
      return FlSpot(x, y);
    }).toList();

    double minY;
    double maxY;

    if (setValue != null) {
      double maxDeviation = dataPoints
          .map((dp) => (dp.value - setValue).abs())
          .reduce((a, b) => a > b ? a : b);
      double deviationRange = maxDeviation < 1 ? 1 : maxDeviation * 1.2;
      minY = setValue - deviationRange;
      maxY = setValue + deviationRange;
    } else {
      minY = dataPoints.map((dp) => dp.value).reduce((a, b) => a < b ? a : b) - 1;
      maxY = dataPoints.map((dp) => dp.value).reduce((a, b) => a > b ? a : b) + 1;
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: spots.isNotEmpty ? spots.last.x : 60,
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: component.isActivated ? Colors.greenAccent : Colors.blueAccent,
            barWidth: 2,
            dotData: FlDotData(show: false),
          ),
          if (setValue != null)
            LineChartBarData(
              spots: [
                FlSpot(0, setValue),
                FlSpot(spots.isNotEmpty ? spots.last.x : 60, setValue),
              ],
              isCurved: false,
              color: Colors.redAccent,
              barWidth: 1,
              dotData: FlDotData(show: false),
              dashArray: [5, 5],
            ),
        ],
        titlesData: FlTitlesData(show: false),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

}
