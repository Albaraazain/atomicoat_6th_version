import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:experiment_planner/core/utils/bloc_utils.dart';
import 'package:experiment_planner/features/components/models/system_component.dart';
import 'package:experiment_planner/features/components/repository/user_component_state_repository.dart';
import 'package:experiment_planner/features/safety/bloc/safety_bloc.dart';
import 'package:experiment_planner/features/safety/bloc/safety_event.dart';
import 'package:experiment_planner/features/safety/models/safety_error.dart';
import 'parameter_monitoring_event.dart';
import 'parameter_monitoring_state.dart';

class ParameterMonitoringBloc extends Bloc<ParameterMonitoringEvent, ParameterMonitoringState> {
  final UserComponentStateRepository _userRepository;
  final SafetyBloc _safetyBloc;
  final String userId;
  final Map<String, StreamSubscription> _monitors = {};

  ParameterMonitoringBloc({
    required SafetyBloc safetyBloc,
    required UserComponentStateRepository userRepository,
    required this.userId,
  }) : _safetyBloc = safetyBloc,
       _userRepository = userRepository,
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
    // Cancel existing monitor if any
    await _monitors[event.componentId]?.cancel();

    // Start new monitor
    _monitors[event.componentId] = _userRepository
        .watch(event.componentId, userId: userId)
        .listen((component) {
          if (component != null) {
            _checkParameters(component);
          }
        });

    emit(state.copyWith(
      monitoringStatus: {
        ...state.monitoringStatus,
        event.componentId: true
      }
    ));
  }

  Future<void> _onStopMonitoring(
    StopParameterMonitoring event,
    Emitter<ParameterMonitoringState> emit,
  ) async {
    try {
      await _monitors[event.componentId]?.cancel();
      _monitors.remove(event.componentId);

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

  void _checkThresholdViolation(
    String componentId,
    String parameterName,
    double value,
  ) {
    _safetyBloc.add(SafetyErrorDetected(
      SafetyError(
        id: '${componentId}_${parameterName}_${DateTime.now().millisecondsSinceEpoch}',
        description: '$parameterName out of range in $componentId',
        severity: SafetyErrorSeverity.warning,
      ),
    ));
  }

  void _checkParameters(SystemComponent component) {
    for (final entry in component.currentValues.entries) {
      final parameter = entry.key;
      final value = entry.value;
      final min = component.minValues[parameter];
      final max = component.maxValues[parameter];

      if (min != null && value < min ||
          max != null && value > max) {
        _safetyBloc.add(SafetyErrorDetected(
          SafetyError(
            id: '${component.id}_${parameter}_${DateTime.now().millisecondsSinceEpoch}',
            description: '$parameter out of range in ${component.name}',
            severity: SafetyErrorSeverity.warning,
          ),
        ));
      }
    }
  }

  @override
  Future<void> close() {
    for (var subscription in _monitors.values) {
      subscription.cancel();
    }
    _monitors.clear();
    return super.close();
  }
}