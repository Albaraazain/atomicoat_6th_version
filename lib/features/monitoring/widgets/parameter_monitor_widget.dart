
import 'package:experiment_planner/blocs/monitoring/parameter/bloc/parameter_monitoring_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/monitoring/parameter/bloc/parameter_monitoring_bloc.dart';
import '../../../blocs/monitoring/parameter/bloc/parameter_monitoring_state.dart';
import '../../components/models/system_component.dart';

class ParameterMonitorWidget extends StatelessWidget {
  final SystemComponent component;

  const ParameterMonitorWidget({
    Key? key,
    required this.component,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParameterMonitoringBloc, ParameterMonitoringState>(
      builder: (context, state) {
        final isMonitoring = state.monitoringStatus[component.name] ?? false;
        final violations = state.violations[component.name] ?? {};

        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isMonitoring),
              const Divider(),
              _buildParameterList(context, state, violations),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isMonitoring) {
    return ListTile(
      title: Text(component.name),
      subtitle: Text(component.description),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMonitoring ? Icons.monitor : Icons.monitor_outlined,
            color: isMonitoring ? Colors.green : Colors.grey,
          ),
          Switch(
            value: isMonitoring,
            onChanged: (value) {
              final bloc = context.read<ParameterMonitoringBloc>();
              if (value) {
                bloc.add(StartParameterMonitoring(
                  componentId: component.name,
                  thresholds: _buildThresholds(),
                ));
              } else {
                bloc.add(StopParameterMonitoring(
                  componentId: component.name,
                ));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildParameterList(
    BuildContext context,
    ParameterMonitoringState state,
    Map<String, bool> violations,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: component.currentValues.length,
      itemBuilder: (context, index) {
        final parameter = component.currentValues.keys.elementAt(index);
        final value = component.currentValues[parameter]!;
        final hasViolation = violations[parameter] ?? false;

        return _ParameterTile(
          parameterName: parameter,
          currentValue: value,
          thresholds: state.thresholds[component.name]?[parameter],
          hasViolation: hasViolation,
          onThresholdUpdate: (min, max) {
            context.read<ParameterMonitoringBloc>().add(
              UpdateParameterThresholds(
                componentId: component.name,
                parameterName: parameter,
                minValue: min,
                maxValue: max,
              ),
            );
          },
        );
      },
    );
  }

  Map<String, Map<String, double>> _buildThresholds() {
    final thresholds = <String, Map<String, double>>{};
    for (final parameter in component.currentValues.keys) {
      thresholds[parameter] = {
        'min': component.minValues[parameter] ?? double.negativeInfinity,
        'max': component.maxValues[parameter] ?? double.infinity,
      };
    }
    return thresholds;
  }
}

class _ParameterTile extends StatelessWidget {
  final String parameterName;
  final double currentValue;
  final Map<String, double>? thresholds;
  final bool hasViolation;
  final Function(double min, double max) onThresholdUpdate;

  const _ParameterTile({
    Key? key,
    required this.parameterName,
    required this.currentValue,
    this.thresholds,
    required this.hasViolation,
    required this.onThresholdUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(parameterName),
      subtitle: Text('Current: $currentValue'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasViolation)
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showThresholdDialog(context),
          ),
        ],
      ),
    );
  }

  void _showThresholdDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ThresholdSettingsDialog(
        parameterName: parameterName,
        currentMin: thresholds?['min'] ?? double.negativeInfinity,
        currentMax: thresholds?['max'] ?? double.infinity,
        onUpdate: onThresholdUpdate,
      ),
    );
  }
}

class ThresholdSettingsDialog extends StatefulWidget {
  final String parameterName;
  final double currentMin;
  final double currentMax;
  final Function(double min, double max) onUpdate;

  const ThresholdSettingsDialog({
    Key? key,
    required this.parameterName,
    required this.currentMin,
    required this.currentMax,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<ThresholdSettingsDialog> createState() => _ThresholdSettingsDialogState();
}

class _ThresholdSettingsDialogState extends State<ThresholdSettingsDialog> {
  late TextEditingController _minController;
  late TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    _minController = TextEditingController(text: widget.currentMin.toString());
    _maxController = TextEditingController(text: widget.currentMax.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.parameterName} Thresholds'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _minController,
            decoration: const InputDecoration(labelText: 'Minimum Value'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _maxController,
            decoration: const InputDecoration(labelText: 'Maximum Value'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final min = double.tryParse(_minController.text) ?? widget.currentMin;
            final max = double.tryParse(_maxController.text) ?? widget.currentMax;
            widget.onUpdate(min, max);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }
}