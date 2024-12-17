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
import '../services/monitoring_service.dart';

class SafetyBloc extends Bloc<SafetyEvent, SafetyState> {
  final SafetyRepository _repository;
  final AlarmBloc _alarmBloc;
  final AuthBloc _authBloc;
  final MonitoringService _monitoringService;
  StreamSubscription? _errorSubscription;
  StreamSubscription? _authSubscription;
  StreamSubscription<MonitoringStatus>? _monitoringSubscription;

  SafetyBloc({
    required SafetyRepository repository,
    required AlarmBloc alarmBloc,
    required AuthBloc authBloc,
    required MonitoringService monitoringService,
  })  : _repository = repository,
        _alarmBloc = alarmBloc,
        _authBloc = authBloc,
        _monitoringService = monitoringService,
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
      final userId = _currentUserId;
      if (userId == null) {
        emit(state.copyWith(
          error: 'User not authenticated',
          isMonitoringActive: false,
        ));
        return;
      }

      // Cancel existing subscription
      await _errorSubscription?.cancel();

      // Start monitoring service
      _monitoringSubscription?.cancel();
      _monitoringSubscription = _monitoringService.startMonitoring().listen(
        (status) {
          if (!isClosed) {
            // Handle monitoring status updates
            emit(state.copyWith(
              isMonitoringActive: true,
              lastStatus: status,
              error: null,
            ));
          }
        },
        onError: (error) {
          if (!isClosed) {
            add(SafetyErrorDetected(
              SafetyError(
                id: DateTime.now().millisecondsSinceEpoch.toString(), // Add unique ID
                description: 'Monitoring error: ${error.toString()}',
                severity: SafetyErrorSeverity.warning,
              ),
            ));
          }
        },
      );

      // Set up error subscription
      emit(state.copyWith(isLoading: true));

      await emit.forEach(
        _repository.watchActiveErrors(userId: userId),
        onData: (List<SafetyError> errors) => state.copyWith(
          isLoading: false,
          isMonitoringActive: true,
          activeErrors: errors,
        ),
        onError: (error, stack) => state.copyWith(
          isLoading: false,
          error: BlocUtils.handleError(error),
        ),
      );
    } catch (error) {
      if (!emit.isDone) {
        emit(state.copyWith(
          isLoading: false,
          error: BlocUtils.handleError(error),
        ));
      }
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
      final userId = _currentUserId;
      if (userId == null) return;

      await _repository.addSafetyError(event.error, userId: userId);

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
      final userId = _currentUserId;
      if (userId == null) return;

      await _repository.resolveError(event.errorId, userId: userId);
    } catch (error) {
      emit(state.copyWith(error: BlocUtils.handleError(error)));
    }
  }

  Future<void> _onThresholdAdjusted(
    SafetyThresholdAdjusted event,
    Emitter<SafetyState> emit,
  ) async {
    try {
      final userId = _currentUserId;
      if (userId == null) return;

      await _repository.updateThresholds(
        event.componentId,
        event.parameterName,
        event.minThreshold,
        event.maxThreshold,
        userId: userId,
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
    await _monitoringSubscription?.cancel();
    _monitoringService.dispose();
    return super.close();
  }
}