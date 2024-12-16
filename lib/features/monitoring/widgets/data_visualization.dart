

import 'package:experiment_planner/blocs/component/bloc/component_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../components/models/system_component.dart';
import '../../../blocs/component/bloc/component_bloc.dart';
import '../../../blocs/component/bloc/component_list_bloc.dart';
import '../../../blocs/component/bloc/component_state.dart';
import '../../../blocs/component/bloc/component_list_state.dart';

class DataVisualization extends StatefulWidget {
  @override
  _DataVisualizationState createState() => _DataVisualizationState();
}

class _DataVisualizationState extends State<DataVisualization> {
  String _selectedParameter = 'Chamber Pressure';

  @override
  Widget build(BuildContext context) {
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
                _initializeComponent(newValue);
              }
            },
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocBuilder<ComponentBloc, ComponentState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.error != null) {
                  return Center(child: Text('Error: ${state.error}'));
                }
                if (state.component == null) {
                  return const Center(child: Text('No data available'));
                }
                return _buildChart(state.component!);
              },
            ),
          ),
        ),
      ],
    );
  }

  void _initializeComponent(String parameter) {
    final componentName = _getComponentName(parameter);
    context.read<ComponentBloc>().add(ComponentInitialized(componentName));
  }

  Widget _buildChart(SystemComponent component) {
    final parameterData = _getParameterData(component);
    if (parameterData.isEmpty) {
      return const Center(child: Text('No data available'));
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

  String _getComponentName(String parameter) {
    switch (parameter) {
      case 'Chamber Pressure':
      case 'Chamber Temperature':
        return 'Reaction Chamber';
      case 'MFC Flow Rate':
        return 'MFC';
      case 'Precursor Heater 1 Temperature':
        return 'Precursor Heater 1';
      case 'Precursor Heater 2 Temperature':
        return 'Precursor Heater 2';
      default:
        throw Exception('Unknown parameter: $parameter');
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

  @override
  void initState() {
    super.initState();
    _initializeComponent(_selectedParameter);
  }
}