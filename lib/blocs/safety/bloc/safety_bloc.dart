// lib/blocs/safety/bloc/safety_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:experiment_planner/blocs/alarm/bloc/alarm_bloc.dart';
import 'package:experiment_planner/blocs/alarm/bloc/alarm_event.dart';
import 'package:experiment_planner/modules/system_operation_also_main_module/models/alarm.dart';
import '../../../modules/system_operation_also_main_module/models/safety_error.dart';
import '../../../modules/system_operation_also_main_module/models/system_component.dart';
import '../../../services/auth_service.dart';
import '../../utils/bloc_utils.dart';
import '../repository/safety_repository.dart';
import 'safety_event.dart';
import 'safety_state.dart';

class SafetyBloc extends Bloc<SafetyEvent, SafetyState> {
  final SafetyRepository _repository;
  final AuthService _authService;
  final AlarmBloc _alarmBloc;
  StreamSubscription? _errorSubscription;

  SafetyBloc({
    required SafetyRepository repository,
    required AuthService authService,
    required AlarmBloc alarmBloc,
  })  : _repository = repository,
        _authService = authService,
        _alarmBloc = alarmBloc,
        super(SafetyState.initial()) {
    on<SafetyMonitoringStarted>(_onMonitoringStarted);
    on<SafetyMonitoringPaused>(_onMonitoringPaused);
    on<SafetyErrorDetected>(_onErrorDetected);
    on<SafetyErrorCleared>(_onErrorCleared);
    on<SafetyThresholdAdjusted>(_onThresholdAdjusted);
  }

  Future<void> _onMonitoringStarted(
    SafetyMonitoringStarted event,
    Emitter<SafetyState> emit,
  ) async {
    try {
      await _errorSubscription?.cancel();

      _errorSubscription = _repository.watchActiveErrors().listen(
        (errors) {
          emit(state.copyWith(
            isLoading: false,
            isMonitoringActive: true,
            activeErrors: errors,
          ));
        },
        onError: (error) {
          emit(state.copyWith(
            isLoading: false,
            error: BlocUtils.handleError(error),
          ));
        },
      );
    } catch (error) {
      emit(state.copyWith(
        isLoading: false,
        error: BlocUtils.handleError(error),
      ));
    }
  }

  Future<void> _onMonitoringPaused(
    SafetyMonitoringPaused event,
    Emitter<SafetyState> emit,
  ) async {
    await _errorSubscription?.cancel();
    _errorSubscription = null;
    emit(state.copyWith(isMonitoringActive: false));
  }

  Future<void> _onErrorDetected(
    SafetyErrorDetected event,
    Emitter<SafetyState> emit,
  ) async {
    try {
      await _repository.addSafetyError(event.error);

      // Add corresponding alarm using constructor
      _alarmBloc.add(AddAlarm(
        message: event.error.description,
        severity: _mapSafetyToAlarmSeverity(event.error.severity),
        isSafetyAlert: true,
      ));

    } catch (error) {
      emit(state.copyWith(error: BlocUtils.handleError(error)));
    }
  }

  Future<void> _onErrorCleared(
    SafetyErrorCleared event,
    Emitter<SafetyState> emit,
  ) async {
    try {
      await _repository.resolveError(event.errorId);
    } catch (error) {
      emit(state.copyWith(error: BlocUtils.handleError(error)));
    }
  }

  Future<void> _onThresholdAdjusted(
    SafetyThresholdAdjusted event,
    Emitter<SafetyState> emit,
  ) async {
    try {
      await _repository.updateThresholds(
        event.componentId,
        event.parameterName,
        event.minThreshold,
        event.maxThreshold,
      );
    } catch (error) {
      emit(state.copyWith(error: BlocUtils.handleError(error)));
    }
  }

  AlarmSeverity _mapSafetyToAlarmSeverity(SafetyErrorSeverity severity) {
    switch (severity) {
      case SafetyErrorSeverity.critical:
        return AlarmSeverity.critical;
      case SafetyErrorSeverity.warning:
        return AlarmSeverity.warning;
      default:
        return AlarmSeverity.info;
    }
  }

  @override
  Future<void> close() {
    _errorSubscription?.cancel();
    return super.close();
  }
}