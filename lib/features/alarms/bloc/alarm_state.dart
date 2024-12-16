// lib/blocs/alarm/bloc/alarm_state.dart

import '../../../features/alarms/models/alarm.dart';
import '../../../shared/base/base_bloc_state.dart';

class AlarmState extends BaseBlocState {
  final List<Alarm> activeAlarms;
  final List<Alarm> acknowledgedAlarms;
  final bool isSubscribed;
  final DateTime? lastUpdate;

  AlarmState({
    this.activeAlarms = const [],
    this.acknowledgedAlarms = const [],
    this.isSubscribed = false,
    this.lastUpdate,
    super.isLoading = false,
    super.error,
  });

  AlarmState copyWith({
    List<Alarm>? activeAlarms,
    List<Alarm>? acknowledgedAlarms,
    bool? isSubscribed,
    DateTime? lastUpdate,
    bool? isLoading,
    String? error,
  }) {
    return AlarmState(
      activeAlarms: activeAlarms ?? this.activeAlarms,
      acknowledgedAlarms: acknowledgedAlarms ?? this.acknowledgedAlarms,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        activeAlarms,
        acknowledgedAlarms,
        isSubscribed,
        lastUpdate,
      ];

  bool get hasActiveAlarms => activeAlarms.isNotEmpty;
  bool get hasAcknowledgedAlarms => acknowledgedAlarms.isNotEmpty;

  List<Alarm> get criticalAlarms => activeAlarms
      .where((alarm) => alarm.severity == AlarmSeverity.critical)
      .toList();

  List<Alarm> get warningAlarms => activeAlarms
      .where((alarm) => alarm.severity == AlarmSeverity.warning)
      .toList();

  List<Alarm> get infoAlarms => activeAlarms
      .where((alarm) => alarm.severity == AlarmSeverity.info)
      .toList();

  bool get hasCriticalAlarms => criticalAlarms.isNotEmpty;
}