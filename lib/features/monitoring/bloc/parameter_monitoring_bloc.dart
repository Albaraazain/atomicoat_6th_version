
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:experiment_planner/blocs/safety/bloc/safety_bloc.dart';
import 'package:experiment_planner/blocs/safety/bloc/safety_event.dart';
import 'package:experiment_planner/core/utils/bloc_utils.dart';
import 'package:experiment_planner/features/safety/models/safety_error.dart';
import 'parameter_monitoring_event.dart';
import 'parameter_monitoring_state.dart';

class ParameterMonitoringBloc extends Bloc<ParameterMonitoringEvent, ParameterMonitoringState> {
  final SafetyBloc _safetyBloc;
  final Map<String, StreamSubscription> _monitoringSubscriptions = {};

  ParameterMonitoringBloc({
    required SafetyBloc safetyBloc,
  }) : _safetyBloc = safetyBloc,
       super(ParameterMonitoringState.initial()) {
    on<StartParameterMonitoring>(_onStartMonitoring);
    on<StopParameterMonitoring>(_onStopMonitoring);
    on<ParameterValueUpdated>(_onParameterValueUpdated);
    on<UpdateParameterThresholds>(_onUpdateThresholds);
  }

  Future<void> _onStartMonitoring(
    StartParameterMonitoring event,
    Emitter<ParameterMonitoringState> emit,
  ) async {
    try {
      final updatedStatus = Map<String, bool>.from(state.monitoringStatus)
        ..[event.componentId] = true;

      final updatedThresholds = Map<String, Map<String, Map<String, double>>>.from(state.thresholds)
        ..[event.componentId] = event.thresholds;

      emit(state.copyWith(
        monitoringStatus: updatedStatus,
        thresholds: updatedThresholds,
      ));
    } catch (error) {
      emit(state.copyWith(error: BlocUtils.handleError(error)));
    }
  }

  Future<void> _onStopMonitoring(
    StopParameterMonitoring event,
    Emitter<ParameterMonitoringState> emit,
  ) async {
    try {
      await _monitoringSubscriptions[event.componentId]?.cancel();
      _monitoringSubscriptions.remove(event.componentId);

      final updatedStatus = Map<String, bool>.from(state.monitoringStatus)
        ..remove(event.componentId);

      emit(state.copyWith(monitoringStatus: updatedStatus));
    } catch (error) {
      emit(state.copyWith(error: BlocUtils.handleError(error)));
    }
  }

  Future<void> _onParameterValueUpdated(
    ParameterValueUpdated event,
    Emitter<ParameterMonitoringState> emit,
  ) async {
    try {
      // Update current values
      final componentValues = state.currentValues[event.componentId] ?? {};
      final updatedComponentValues = Map<String, double>.from(componentValues)
        ..[event.parameterName] = event.value;

      final updatedValues = Map<String, Map<String, double>>.from(state.currentValues)
        ..[event.componentId] = updatedComponentValues;

      // Check thresholds
      final thresholds = state.thresholds[event.componentId]?[event.parameterName];
      if (thresholds != null) {
        final min = thresholds['min'] ?? double.negativeInfinity;
        final max = thresholds['max'] ?? double.infinity;

        if (event.value < min || event.value > max) {
          // Update violations map
          final componentViolations = state.violations[event.componentId] ?? {};
          final updatedViolations = Map<String, Map<String, bool>>.from(state.violations)
            ..[event.componentId] = {
              ...componentViolations,
              event.parameterName: true,
            };

          // Emit state update
          emit(state.copyWith(
            currentValues: updatedValues,
            violations: updatedViolations,
            lastUpdated: DateTime.now(),
          ));

          // Notify safety bloc after state update
          _checkThresholdViolation(event.componentId, event.parameterName, event.value);
        } else {
          emit(state.copyWith(
            currentValues: updatedValues,
            lastUpdated: DateTime.now(),
          ));
        }
      } else {
        emit(state.copyWith(
          currentValues: updatedValues,
          lastUpdated: DateTime.now(),
        ));
      }
    } catch (error) {
      emit(state.copyWith(error: BlocUtils.handleError(error)));
    }
  }

  Future<void> _onUpdateThresholds(
    UpdateParameterThresholds event,
    Emitter<ParameterMonitoringState> emit,
  ) async {
    try {
      final componentThresholds = state.thresholds[event.componentId] ?? {};
      final updatedComponentThresholds = Map<String, Map<String, double>>.from(componentThresholds)
        ..[event.parameterName] = {
          'min': event.minValue,
          'max': event.maxValue,
        };

      final updatedThresholds = Map<String, Map<String, Map<String, double>>>.from(state.thresholds)
        ..[event.componentId] = updatedComponentThresholds;

      emit(state.copyWith(thresholds: updatedThresholds));
    } catch (error) {
      emit(state.copyWith(error: BlocUtils.handleError(error)));
    }
  }

  void _checkThresholdViolation(String componentId, String parameterName, double value) {
    _safetyBloc.add(SafetyErrorDetected(
      SafetyError(
        id: '$componentId-$parameterName-${DateTime.now().millisecondsSinceEpoch}',
        description: 'Parameter $parameterName exceeded threshold: $value',
        severity: SafetyErrorSeverity.warning,
      ),
    ));
  }

  @override
  Future<void> close() {
    for (var subscription in _monitoringSubscriptions.values) {
      subscription.cancel();
    }
    _monitoringSubscriptions.clear();
    return super.close();
  }
}