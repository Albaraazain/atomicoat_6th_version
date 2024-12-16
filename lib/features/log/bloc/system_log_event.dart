import 'package:equatable/equatable.dart';
import 'package:experiment_planner/features/components/models/system_component.dart';

abstract class SystemLogEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LogEntryAdded extends SystemLogEvent {
  final String message;
  final ComponentStatus severity;

  LogEntryAdded({
    required this.message,
    required this.severity,
  });

  @override
  List<Object> get props => [message, severity];
}

class LogEntriesLoaded extends SystemLogEvent {
  final int limit;

  LogEntriesLoaded({this.limit = 50});

  @override
  List<Object> get props => [limit];
}

class LogEntriesFiltered extends SystemLogEvent {
  final DateTime startDate;
  final DateTime endDate;
  final ComponentStatus? severityFilter;

  LogEntriesFiltered({
    required this.startDate,
    required this.endDate,
    this.severityFilter,
  });

  @override
  List<Object?> get props => [startDate, endDate, severityFilter];
}

class LogStreamStarted extends SystemLogEvent {}

class LogStreamStopped extends SystemLogEvent {}