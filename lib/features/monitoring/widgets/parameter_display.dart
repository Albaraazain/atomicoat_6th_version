

import 'package:experiment_planner/features/components/bloc/component_bloc.dart';
import 'package:experiment_planner/features/components/bloc/component_event.dart';
import 'package:experiment_planner/features/components/bloc/component_state.dart';
import 'package:experiment_planner/features/components/models/system_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'parameter_card.dart';

class ParameterDisplay extends StatefulWidget {
  @override
  State<ParameterDisplay> createState() => _ParameterDisplayState();
}

class _ParameterDisplayState extends State<ParameterDisplay> {
  final List<String> componentNames = [
    'Reaction Chamber',
    'MFC',
    'Nitrogen Generator',
    'Precursor Heater 1',
    'Precursor Heater 2',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize component blocs
    for (final componentName in componentNames) {
      context.read<ComponentBloc>().add(ComponentInitialized(componentName));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.extent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 1.5,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildReactorParameters(),
                _buildMFCParameters(),
                _buildNitrogenParameters(),
                _buildPrecursorParameters('Precursor Heater 1'),
                _buildPrecursorParameters('Precursor Heater 2'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReactorParameters() {
    return BlocBuilder<ComponentBloc, ComponentState>(
      builder: (context, state) {
        if (state.component?.name != 'Reaction Chamber') return SizedBox.shrink();

        final component = state.component;
        if (component == null) return SizedBox.shrink();

        return Column(
          children: [
            ParameterCard(
              title: 'Chamber Pressure',
              value: '${component.currentValues['pressure']?.toStringAsFixed(2) ?? 'N/A'} atm',
              normalRange: '0.9 - 1.1 atm',
              isNormal: _isPressureNormal(component),
            ),
            ParameterCard(
              title: 'Chamber Temperature',
              value: '${component.currentValues['temperature']?.toStringAsFixed(1) ?? 'N/A'} °C',
              normalRange: '145 - 155 °C',
              isNormal: _isTemperatureNormal(component),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMFCParameters() {
    return BlocBuilder<ComponentBloc, ComponentState>(
      builder: (context, state) {
        if (state.component?.name != 'MFC') return SizedBox.shrink();

        final component = state.component;
        if (component == null) return SizedBox.shrink();

        return ParameterCard(
          title: 'MFC Flow Rate',
          value: '${component.currentValues['flow_rate']?.toStringAsFixed(2) ?? 'N/A'} sccm',
          normalRange: '0 - 100 sccm',
          isNormal: _isFlowRateNormal(component),
        );
      },
    );
  }

  Widget _buildNitrogenParameters() {
    return BlocBuilder<ComponentBloc, ComponentState>(
      builder: (context, state) {
        if (state.component?.name != 'Nitrogen Generator') return SizedBox.shrink();

        final component = state.component;
        if (component == null) return SizedBox.shrink();

        return ParameterCard(
          title: 'Nitrogen Flow Rate',
          value: '${component.currentValues['flow_rate']?.toStringAsFixed(2) ?? 'N/A'} sccm',
          normalRange: '0 - 100 sccm',
          isNormal: _isFlowRateNormal(component),
        );
      },
    );
  }

  Widget _buildPrecursorParameters(String heaterName) {
    return BlocBuilder<ComponentBloc, ComponentState>(
      builder: (context, state) {
        if (state.component?.name != heaterName) return SizedBox.shrink();

        final component = state.component;
        if (component == null) return SizedBox.shrink();

        return ParameterCard(
          title: heaterName,
          value: '${component.currentValues['temperature']?.toStringAsFixed(1) ?? 'N/A'} °C',
          normalRange: '28 - 32 °C',
          isNormal: _isPrecursorTemperatureNormal(component),
        );
      },
    );
  }

  bool _isPressureNormal(SystemComponent component) {
    final pressure = component.currentValues['pressure'] as double?;
    return pressure != null && pressure >= 0.9 && pressure <= 1.1;
  }

  bool _isTemperatureNormal(SystemComponent component) {
    final temperature = component.currentValues['temperature'] as double?;
    return temperature != null && temperature >= 145 && temperature <= 155;
  }

  bool _isFlowRateNormal(SystemComponent component) {
    final flowRate = component.currentValues['flow_rate'] as double?;
    return flowRate != null && flowRate >= 0 && flowRate <= 100;
  }

  bool _isPrecursorTemperatureNormal(SystemComponent component) {
    final temperature = component.currentValues['temperature'] as double?;
    return temperature != null && temperature >= 28 && temperature <= 32;
  }
}