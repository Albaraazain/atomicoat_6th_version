// lib/blocs/alarm/bloc/alarm_bloc.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../../features/alarms/models/alarm.dart';
import '../repository/alarm_repository.dart';
import '../../utils/bloc_utils.dart';
import 'alarm_event.dart';
import 'alarm_state.dart';

class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  final AlarmRepository _repository;
  StreamSubscription? _alarmSubscription;

  AlarmBloc(this._repository) : super( AlarmState()) {
    on<LoadAlarms>(_onLoadAlarms);
    on<AddAlarm>(_onAddAlarm);
    on<AcknowledgeAlarm>(_onAcknowledgeAlarm);
    on<ClearAlarm>(_onClearAlarm);
    on<ClearAllAcknowledgedAlarms>(_onClearAllAcknowledgedAlarms);
    on<SubscribeToAlarms>(_onSubscribeToAlarms);
    on<UnsubscribeFromAlarms>(_onUnsubscribeFromAlarms);
  }

  Future<void> _onLoadAlarms(
    LoadAlarms event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final activeAlarms = await _repository.getActiveAlarms();
      final acknowledgedAlarms = await _repository.getAcknowledgedAlarms();

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
      final newAlarm = Alarm(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: event.message,
        severity: event.severity,
        timestamp: DateTime.now(),
        isSafetyAlert: event.isSafetyAlert,
      );

      await _repository.addAlarm(newAlarm);

      final updatedAlarms = [...state.activeAlarms, newAlarm];
      emit(state.copyWith(
        activeAlarms: updatedAlarms,
        lastUpdate: DateTime.now(),
      ));
    } catch (error) {
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
      ));
    }
  }

  Future<void> _onAcknowledgeAlarm(
    AcknowledgeAlarm event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      await _repository.acknowledgeAlarm(event.alarmId);

      final alarm = state.activeAlarms.firstWhere((a) => a.id == event.alarmId);
      final acknowledgedAlarm = alarm.copyWith(acknowledged: true);

      final updatedActive = state.activeAlarms
          .where((a) => a.id != event.alarmId)
          .toList();

      final updatedAcknowledged = [
        ...state.acknowledgedAlarms,
        acknowledgedAlarm,
      ];

      emit(state.copyWith(
        activeAlarms: updatedActive,
        acknowledgedAlarms: updatedAcknowledged,
        lastUpdate: DateTime.now(),
      ));
    } catch (error) {
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
      ));
    }
  }

  Future<void> _onClearAlarm(
    ClearAlarm event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      await _repository.clearAlarm(event.alarmId);

      final updatedActive = state.activeAlarms
          .where((a) => a.id != event.alarmId)
          .toList();

      final updatedAcknowledged = state.acknowledgedAlarms
          .where((a) => a.id != event.alarmId)
          .toList();

      emit(state.copyWith(
        activeAlarms: updatedActive,
        acknowledgedAlarms: updatedAcknowledged,
        lastUpdate: DateTime.now(),
      ));
    } catch (error) {
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
      ));
    }
  }

  Future<void> _onClearAllAcknowledgedAlarms(
    ClearAllAcknowledgedAlarms event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      await _repository.clearAllAcknowledgedAlarms();

      emit(state.copyWith(
        acknowledgedAlarms: [],
        lastUpdate: DateTime.now(),
      ));
    } catch (error) {
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
      ));
    }
  }

  Future<void> _onSubscribeToAlarms(
    SubscribeToAlarms event,
    Emitter<AlarmState> emit,
  ) async {
    await _alarmSubscription?.cancel();

    _alarmSubscription = _repository.watchAlarms().listen(
      (alarms) {
        final activeAlarms = alarms.where((a) => !a.acknowledged).toList();
        final acknowledgedAlarms = alarms.where((a) => a.acknowledged).toList();

        emit(state.copyWith(
          activeAlarms: activeAlarms,
          acknowledgedAlarms: acknowledgedAlarms,
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