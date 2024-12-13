// lib/blocs/component/bloc/component_event.dart

import 'package:equatable/equatable.dart';
import 'package:experiment_planner/modules/system_operation_also_main_module/models/data_point.dart';
import '../../../modules/system_operation_also_main_module/models/system_component.dart';

abstract class ComponentEvent extends Equatable {
  const ComponentEvent();

  @override
  List<Object?> get props => [];
}

class ComponentInitialized extends ComponentEvent {
  final String componentName;

  const ComponentInitialized(this.componentName);

  @override
  List<Object?> get props => [componentName];
}

class ComponentCurrentValuesUpdated extends ComponentEvent {
  final String componentName;
  final Map<String, double> currentValues;

  const ComponentCurrentValuesUpdated(this.componentName, this.currentValues);

  @override
  List<Object?> get props => [componentName, currentValues];
}

class ComponentSetValuesUpdated extends ComponentEvent {
  final String componentName;
  final Map<String, double> setValues;

  const ComponentSetValuesUpdated(this.componentName, this.setValues);

  @override
  List<Object?> get props => [componentName, setValues];
}

class ComponentActivationToggled extends ComponentEvent {
  final String componentName;
  final bool isActivated;

  const ComponentActivationToggled(this.componentName, this.isActivated);

  @override
  List<Object?> get props => [componentName, isActivated];
}

class ComponentParameterUpdated extends ComponentEvent {
  final String componentName;
  final String parameter;
  final double value;

  const ComponentParameterUpdated(
    this.componentName,
    this.parameter,
    this.value,
  );

  @override
  List<Object?> get props => [componentName, parameter, value];
}

class ComponentDataPointAdded extends ComponentEvent {
  final String componentName;
  final String parameter;
  final DataPoint dataPoint;
  final int maxDataPoints;

  const ComponentDataPointAdded(
    this.componentName,
    this.parameter,
    this.dataPoint, {
    this.maxDataPoints = 1000,
  });

  @override
  List<Object?> get props =>
      [componentName, parameter, dataPoint, maxDataPoints];
}

// New events to match provider functionality
class ComponentParameterValueUpdated extends ComponentEvent {
  final String componentName;
  final String parameter;
  final double value;

  const ComponentParameterValueUpdated(
    this.componentName,
    this.parameter,
    this.value,
  );

  @override
  List<Object?> get props => [componentName, parameter, value];
}

class ComponentCleared extends ComponentEvent {
  final String componentName;

  const ComponentCleared(this.componentName);

  @override
  List<Object?> get props => [componentName];
}

class ComponentSetValueUpdated extends ComponentEvent {
  final String componentName;
  final String parameter;
  final double value;

  const ComponentSetValueUpdated(
    this.componentName,
    this.parameter,
    this.value,
  );

  @override
  List<Object?> get props => [componentName, parameter, value];
}

class ComponentValueUpdated extends ComponentEvent {
  final String componentName;
  final Map<String, double> currentValues;

  const ComponentValueUpdated(this.componentName, this.currentValues);

  @override
  List<Object?> get props => [componentName, currentValues];
}

class ComponentErrorAdded extends ComponentEvent {
  final String componentName;
  final String errorMessage;

  const ComponentErrorAdded(this.componentName, this.errorMessage);

  @override
  List<Object?> get props => [componentName, errorMessage];
}

class ComponentErrorsCleared extends ComponentEvent {
  final String componentName;

  const ComponentErrorsCleared(this.componentName);

  @override
  List<Object?> get props => [componentName];
}

class ComponentStatusUpdated extends ComponentEvent {
  final String componentName;
  final ComponentStatus status;

  const ComponentStatusUpdated(this.componentName, this.status);

  @override
  List<Object?> get props => [componentName, status];
}

class ComponentCheckDateUpdated extends ComponentEvent {
  final String componentName;
  final DateTime checkDate;

  const ComponentCheckDateUpdated(this.componentName, this.checkDate);

  @override
  List<Object?> get props => [componentName, checkDate];
}

class ComponentLimitsUpdated extends ComponentEvent {
  final String componentName;
  final Map<String, double>? minValues;
  final Map<String, double>? maxValues;

  const ComponentLimitsUpdated(
    this.componentName, {
    this.minValues,
    this.maxValues,
  });

  @override
  List<Object?> get props => [componentName, minValues, maxValues];
}
