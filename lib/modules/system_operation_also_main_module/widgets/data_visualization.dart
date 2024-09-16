// lib/modules/system_operation_also_main_module/widgets/data_visualization.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/system_component.dart';
import '../providers/system_state_provider.dart';

class DataVisualization extends StatefulWidget {
  @override
  _DataVisualizationState createState() => _DataVisualizationState();
}

class _DataVisualizationState extends State<DataVisualization> {
  String _selectedParameter = 'Chamber Pressure';

  @override
  Widget build(BuildContext context) {
    return Consumer<SystemStateProvider>(
      builder: (context, systemStateProvider, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<String>(
                value: _selectedParameter,
                items: [
                  'Chamber Pressure',
                  'Chamber Temperature',
                  'MFC Flow Rate',
                  'Precursor Heater 1 Temperature',
                  'Precursor Heater 2 Temperature',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedParameter = newValue;
                    });
                  }
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildChart(systemStateProvider),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChart(SystemStateProvider systemStateProvider) {
    final component = _getComponentForParameter(systemStateProvider);
    if (component == null) {
      return Center(child: Text('No data available'));
    }

    final parameterData = _getParameterData(component);
    if (parameterData.isEmpty) {
      return Center(child: Text('No data available'));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 22),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: parameterData,
            isCurved: true,
            color: Colors.blue,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  SystemComponent? _getComponentForParameter(SystemStateProvider systemStateProvider) {
    switch (_selectedParameter) {
      case 'Chamber Pressure':
      case 'Chamber Temperature':
        return systemStateProvider.getComponentByName('Reaction Chamber');
      case 'MFC Flow Rate':
        return systemStateProvider.getComponentByName('MFC');
      case 'Precursor Heater 1 Temperature':
        return systemStateProvider.getComponentByName('Precursor Heater 1');
      case 'Precursor Heater 2 Temperature':
        return systemStateProvider.getComponentByName('Precursor Heater 2');
      default:
        return null;
    }
  }

  List<FlSpot> _getParameterData(SystemComponent component) {
    final parameterKey = _getParameterKey();
    final history = component.parameterHistory[parameterKey];
    if (history == null || history.isEmpty) {
      return [];
    }

    return history.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();
  }

  String _getParameterKey() {
    switch (_selectedParameter) {
      case 'Chamber Pressure':
        return 'pressure';
      case 'Chamber Temperature':
      case 'Precursor Heater 1 Temperature':
      case 'Precursor Heater 2 Temperature':
        return 'temperature';
      case 'MFC Flow Rate':
        return 'flow_rate';
      default:
        return '';
    }
  }
}