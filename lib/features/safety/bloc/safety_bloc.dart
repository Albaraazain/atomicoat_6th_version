import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:experiment_planner/core/utils/bloc_utils.dart';
import 'package:experiment_planner/features/alarms/bloc/alarm_bloc.dart';
import 'package:experiment_planner/features/alarms/bloc/alarm_event.dart';
import 'package:experiment_planner/features/alarms/models/alarm.dart';
import 'package:experiment_planner/features/auth/bloc/auth_bloc.dart';
import 'package:experiment_planner/features/auth/bloc/auth_state.dart';
import '../models/safety_error.dart';
import '../repository/safety_repository.dart';
import 'safety_event.dart';
import 'safety_state.dart';

class SafetyBloc extends Bloc<SafetyEvent, SafetyState> {
  final SafetyRepository _repository;
  final AlarmBloc _alarmBloc;
  final AuthBloc _authBloc;
  StreamSubscription? _errorSubscription;
  StreamSubscription? _authSubscription;

  SafetyBloc({
    required SafetyRepository repository,
    required AlarmBloc alarmBloc,
    required AuthBloc authBloc,
  })  : _repository = repository,
        _alarmBloc = alarmBloc,
        _authBloc = authBloc,
        super(SafetyState.initial()) {
    on<SafetyMonitoringStarted>(_onMonitoringStarted);
    on<SafetyMonitoringPaused>(_onMonitoringPaused);
    on<SafetyErrorDetected>(_onErrorDetected);
    on<SafetyErrorCleared>(_onErrorCleared);
    on<SafetyThresholdAdjusted>(_onThresholdAdjusted);

    _authSubscription = _authBloc.stream.listen((authState) {
      if (authState.status == AuthStatus.authenticated) {
        add(SafetyMonitoringStarted());
      } else if (authState.status == AuthStatus.unauthenticated) {
        add(SafetyMonitoringPaused());
      }
    });
  }

  String? get _currentUserId => _authBloc.state.user?.id;

  Future<void> _onMonitoringStarted(
    SafetyMonitoringStarted event,
    Emitter<SafetyState> emit,
  ) async {
    try {
      await _errorSubscription?.cancel();

      final userId = _currentUserId;
      if (userId == null) {
        emit(state.copyWith(
          error: 'User not authenticated',
          isMonitoringActive: false,
        ));
        return;
      }

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
  Future<void> close() async {
    await _errorSubscription?.cancel();
    await _authSubscription?.cancel();
    return super.close();
  }
}