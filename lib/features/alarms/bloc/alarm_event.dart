// lib/blocs/alarm/bloc/alarm_event.dart

import '../../../features/alarms/models/alarm.dart';
import '../../../shared/base/base_bloc_event.dart';

abstract class AlarmEvent extends BaseBlocEvent {}

class LoadAlarms extends AlarmEvent {
  final String? userId;
  LoadAlarms({this.userId});
}

class AddAlarm extends AlarmEvent {
  final String message;
  final AlarmSeverity severity;
  final bool isSafetyAlert;

  AddAlarm({
    required this.message,
    required this.severity,
    this.isSafetyAlert = false,
  });
}

class AcknowledgeAlarm extends AlarmEvent {
  final String alarmId;
  AcknowledgeAlarm(this.alarmId);
}

class ClearAlarm extends AlarmEvent {
  final String alarmId;
  ClearAlarm(this.alarmId);
}

class ClearAllAcknowledgedAlarms extends AlarmEvent {}

class SubscribeToAlarms extends AlarmEvent {
  final String? userId;
  SubscribeToAlarms({this.userId});
}

class UnsubscribeFromAlarms extends AlarmEvent {}