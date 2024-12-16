// lib/blocs/monitoring/parameter/bloc/parameter_monitoring_event.dart
import '../../../base/base_bloc_event.dart';

sealed class ParameterMonitoringEvent extends BaseBlocEvent {
  ParameterMonitoringEvent() : super();
}

class StartParameterMonitoring extends ParameterMonitoringEvent {
  final String componentId;
  final Map<String, Map<String, double>> thresholds;

  StartParameterMonitoring({
    required this.componentId,
    required this.thresholds,
  });
}

class StopParameterMonitoring extends ParameterMonitoringEvent {
  final String componentId;
  StopParameterMonitoring({required this.componentId});
}

class ParameterValueUpdated extends ParameterMonitoringEvent {
  final String componentId;
  final String parameterName;
  final double value;

  ParameterValueUpdated({
    required this.componentId,
    required this.parameterName,
    required this.value,
  });
}

class UpdateParameterThresholds extends ParameterMonitoringEvent {
  final String componentId;
  final String parameterName;
  final double minValue;
  final double maxValue;

  UpdateParameterThresholds({
    required this.componentId,
    required this.parameterName,
    required this.minValue,
    required this.maxValue,
  });
}