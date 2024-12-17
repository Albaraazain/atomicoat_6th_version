// lib/blocs/alarm/bloc/alarm_bloc.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:experiment_planner/core/utils/bloc_utils.dart';
import 'package:experiment_planner/features/auth/bloc/auth_bloc.dart';
import '../../../features/alarms/models/alarm.dart';
import '../repository/alarm_repository.dart';
import 'alarm_event.dart';
import 'alarm_state.dart';

class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  final AlarmRepository _repository;
  final AuthBloc _authBloc; // Add this
  StreamSubscription? _alarmSubscription;

  AlarmBloc(this._repository, this._authBloc) : super(AlarmState()) {
    on<LoadAlarms>(_onLoadAlarms);
    on<AddAlarm>(_onAddAlarm);
    on<AcknowledgeAlarm>(_onAcknowledgeAlarm);
    on<ClearAlarm>(_onClearAlarm);
    on<ClearAllAcknowledgedAlarms>(_onClearAllAcknowledgedAlarms);
    on<SubscribeToAlarms>(_onSubscribeToAlarms);
    on<UnsubscribeFromAlarms>(_onUnsubscribeFromAlarms);
  }

  String? get _currentUserId => _authBloc.state.user?.id; // Add helper method

  Future<void> _onLoadAlarms(
    LoadAlarms event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final userId = _currentUserId;
      if (userId == null) {
        emit(state.copyWith(
          error: 'User not authenticated',
          isLoading: false,
        ));
        return;
      }

      final activeAlarms = await _repository.getActiveAlarms(userId);
      final acknowledgedAlarms = await _repository
          .getAll(userId: userId)
          .then((alarms) => alarms.where((a) => a.acknowledged).toList());

      emit(state.copyWith(
        activeAlarms: activeAlarms,
        acknowledgedAlarms: acknowledgedAlarms,
        isLoading: false,
        lastUpdate: DateTime.now(),
      ));
    } catch (error) {
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
        isLoading: false,
      ));
    }
  }

  Future<void> _onAddAlarm(
    AddAlarm event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      final userId = _currentUserId;
      if (userId == null) return;

      final id = DateTime.now().millisecondsSinceEpoch.toString();
      await _repository.createNewAlarm(
        id: id,
        message: event.message,
        severity: event.severity,
        isSafetyAlert: event.isSafetyAlert,
        userId: userId,
      );

      if (!emit.isDone) {
        await _onLoadAlarms(LoadAlarms(), emit);
      }
    } catch (error) {
      emit(state.copyWith(error: BlocUtils.handleError(error)));
    }
  }

  Future<void> _onAcknowledgeAlarm(
    AcknowledgeAlarm event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      final userId = _currentUserId;
      if (userId == null) return;

      await _repository.acknowledgeAlarm(event.alarmId, userId);
      await _onLoadAlarms(LoadAlarms(), emit);
    } catch (error) {
      emit(state.copyWith(error: BlocUtils.handleError(error)));
    }
  }

  Future<void> _onClearAlarm(
    ClearAlarm event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      final userId = _currentUserId;
      if (userId == null) return;

      await _repository.remove(event.alarmId, userId: userId);
      await _onLoadAlarms(LoadAlarms(), emit);
    } catch (error) {
      emit(state.copyWith(error: BlocUtils.handleError(error)));
    }
  }

  Future<void> _onClearAllAcknowledgedAlarms(
    ClearAllAcknowledgedAlarms event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      final userId = _currentUserId;
      if (userId == null) return;

      await _repository.clearAcknowledged(userId);
      await _onLoadAlarms(LoadAlarms(), emit);
    } catch (error) {
      emit(state.copyWith(error: BlocUtils.handleError(error)));
    }
  }

  Future<void> _onSubscribeToAlarms(
    SubscribeToAlarms event,
    Emitter<AlarmState> emit,
  ) async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _alarmSubscription?.cancel();
    _alarmSubscription = _repository.watchActiveAlarms(userId).listen(
      (activeAlarms) {
        emit(state.copyWith(
          activeAlarms: activeAlarms,
          isSubscribed: true,
          lastUpdate: DateTime.now(),
        ));
      },
      onError: (error) {
        emit(state.copyWith(
          error: BlocUtils.handleError(error),
          isSubscribed: false,
        ));
      },
    );
  }

  Future<void> _onUnsubscribeFromAlarms(
    UnsubscribeFromAlarms event,
    Emitter<AlarmState> emit,
  ) async {
    await _alarmSubscription?.cancel();
    _alarmSubscription = null;
    emit(state.copyWith(isSubscribed: false));
  }

  @override
  Future<void> close() {
    _alarmSubscription?.cancel();
    return super.close();
  }
}
