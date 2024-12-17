^// *(lib|path)// lib/blocs/system_state/bloc/system_state_bloc.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:experiment_planner/core/utils/bloc_utils.dart';
import 'package:experiment_planner/features/system/repositories/system_state_repository.dart';
import '../models/system_state_data.dart';
import 'system_state_event.dart';
import 'system_state_state.dart';

class SystemStateBloc extends Bloc<SystemStateEvent, SystemStateState> {
  final SystemStateRepository _repository;
  StreamSubscription? _stateSubscription;

  SystemStateBloc(this._repository) : super(SystemStateState()) {
    on<InitializeSystem>(_onInitializeSystem);
    on<StartSystem>(_onStartSystem);
    on<StopSystem>(_onStopSystem);
    on<EmergencyStop>(_onEmergencyStop);
    on<CheckSystemReadiness>(_onCheckSystemReadiness);
    on<SaveSystemState>(_onSaveSystemState);
    on<ValidateSystemState>(_onValidateSystemState);
    on<UpdateSystemParameters>(_onUpdateSystemParameters);
  }

  Future<void> _onInitializeSystem(
    InitializeSystem event,
    Emitter<SystemStateState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: SystemOperationalStatus.initializing,
        isLoading: true,
      ));

      // Load the latest state
      final latestState = await _repository.getSystemState();

      if (latestState != null) {
        emit(state.copyWith(
          status: SystemOperationalStatus.ready,
          currentSystemState: latestState.data,
          lastStateUpdate: latestState.timestamp,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(
          status: SystemOperationalStatus.ready,
          isLoading: false,
        ));
      }

      // Setup state subscription
      await _stateSubscription?.cancel();
      _stateSubscription = _repository.systemStateStream().listen(
        (systemState) {
          if (systemState != null) {
            add(SaveSystemState(systemState.data));
          }
        },
        onError: (error) {
          add(SaveSystemState({'error': error.toString()}));
        },
      );
    } catch (error) {
      emit(state.copyWith(
        status: SystemOperationalStatus.error,
        error: BlocUtils.handleError(error),
        isLoading: false,
      ));
    }
  }

  Future<void> _onStartSystem(
    StartSystem event,
    Emitter<SystemStateState> emit,
  ) async {
    if (!state.canStart) {
      emit(state.copyWith(
        error: 'System cannot be started in current state',
      ));
      return;
    }

    try {
      emit(state.copyWith(isLoading: true));

      await _repository.saveSystemState({
        'status': 'running',
        'isSystemRunning': true,
        'timestamp': DateTime.now().toIso8601String(),
      });

      emit(state.copyWith(
        status: SystemOperationalStatus.running,
        isSystemRunning: true,
        isLoading: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
        isLoading: false,
      ));
    }
  }

  Future<void> _onStopSystem(
    StopSystem event,
    Emitter<SystemStateState> emit,
  ) async {
    if (!state.canStop) {
      emit(state.copyWith(
        error: 'System is not running',
      ));
      return;
    }

    try {
      emit(state.copyWith(isLoading: true));

      await _repository.saveSystemState({
        'status': 'ready',
        'isSystemRunning': false,
        'timestamp': DateTime.now().toIso8601String(),
      });

      emit(state.copyWith(
        status: SystemOperationalStatus.ready,
        isSystemRunning: false,
        isLoading: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
        isLoading: false,
      ));
    }
  }

  Future<void> _onEmergencyStop(
    EmergencyStop event,
    Emitter<SystemStateState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      await _repository.saveSystemState({
        ...state.currentSystemState,
        'isRunning': false,
        'emergencyStoppedAt': DateTime.now().toIso8601String(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      emit(state.copyWith(
        status: SystemOperationalStatus.emergencyStopped,
        isSystemRunning: false,
        isLoading: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
        isLoading: false,
      ));
    }
  }

  Future<void> _onCheckSystemReadiness(
    CheckSystemReadiness event,
    Emitter<SystemStateState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      // Implement system readiness checks here
      final issues = _checkSystemIssues();

      emit(state.copyWith(
        systemIssues: issues,
        isReadinessCheckPassed: issues.isEmpty,
        isLoading: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
        isLoading: false,
      ));
    }
  }

  Future<void> _onSaveSystemState(
    SaveSystemState event,
    Emitter<SystemStateState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      await _repository.saveSystemState({
        ...event.state,
        'timestamp': DateTime.now().toIso8601String(),
      });

      emit(state.copyWith(
        currentSystemState: event.state,
        lastStateUpdate: DateTime.now(),
        isLoading: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
        isLoading: false,
      ));
    }
  }

  Future<void> _onValidateSystemState(
    ValidateSystemState event,
    Emitter<SystemStateState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      // Implement state validation logic here
      final issues = _validateCurrentState();

      emit(state.copyWith(
        systemIssues: issues,
        isLoading: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
        isLoading: false,
      ));
    }
  }

  Future<void> _onUpdateSystemParameters(
    UpdateSystemParameters event,
    Emitter<SystemStateState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final updatedState = Map<String, dynamic>.from(state.currentSystemState);
      event.updates.forEach((component, values) {
        if (updatedState.containsKey('components')) {
          final components = updatedState['components'] as Map<String, dynamic>;
          if (components.containsKey(component)) {
            final componentData = components[component] as Map<String, dynamic>;
            componentData['currentValues'] = values;
          }
        }
      });

      await _repository.saveSystemState(updatedState);

      emit(state.copyWith(
        currentSystemState: updatedState,
        lastStateUpdate: DateTime.now(),
        isLoading: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
        isLoading: false,
      ));
    }
  }

  List<String> _checkSystemIssues() {
    final issues = <String>[];

    final components = state.currentSystemState['components'] as Map<String, dynamic>?;

    if (components == null || components.isEmpty) {
      issues.add('No components found in system');
      return issues;
    }

    components.forEach((componentName, componentData) {
      final data = componentData as Map<String, dynamic>;
      final isActivated = data['isActivated'] as bool? ?? false;
      final currentValues = data['currentValues'] as Map<String, dynamic>?;
      final setValues = data['setValues'] as Map<String, dynamic>?;

      if (!isActivated) {
        issues.add('$componentName is not activated');
      }

      if (currentValues != null && setValues != null) {
        currentValues.forEach((parameter, value) {
          final setValue = setValues[parameter];
          if (setValue != null && (value as num).abs() - (setValue as num).abs() > 0.1) {
            issues.add('$componentName: $parameter mismatch (current: $value, set: $setValue)');
          }
        });
      }
    });

    return issues;
  }

  List<String> _validateCurrentState() {
    final issues = <String>[];

    if (!state.isSystemRunning && state.status == SystemOperationalStatus.running) {
      issues.add('System status inconsistency detected');
    }

    final components = state.currentSystemState['components'] as Map<String, dynamic>?;
    if (components != null) {
      components.forEach((componentName, componentData) {
        final data = componentData as Map<String, dynamic>;
        final currentValues = data['currentValues'] as Map<String, dynamic>?;
        final minValues = data['minValues'] as Map<String, dynamic>?;
        final maxValues = data['maxValues'] as Map<String, dynamic>?;

        if (currentValues != null && minValues != null && maxValues != null) {
          currentValues.forEach((parameter, value) {
            final min = minValues[parameter] as num?;
            final max = maxValues[parameter] as num?;
            final current = value as num;

            if (min != null && current < min) {
              issues.add('$componentName: $parameter below minimum ($current < $min)');
            }
            if (max != null && current > max) {
              issues.add('$componentName: $parameter above maximum ($current > $max)');
            }
          });
        }
      });
    }

    return issues;
  }

  @override
  Future<void> close() {
    _stateSubscription?.cancel();
    return super.close();
  }
}