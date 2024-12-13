import 'package:equatable/equatable.dart';
import 'package:experiment_planner/modules/system_operation_also_main_module/models/system_log_entry.dart';

class SystemLogState extends Equatable {
  final bool isLoading;
  final List<SystemLogEntry> entries;
  final String? error;
  final bool hasMoreEntries;
  final DateTime? startDate;
  final DateTime? endDate;

  const SystemLogState({
    required this.isLoading,
    required this.entries,
    this.error,
    required this.hasMoreEntries,
    this.startDate,
    this.endDate,
  });

  factory SystemLogState.initial() {
    return const SystemLogState(
      isLoading: false,
      entries: [],
      hasMoreEntries: false,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        entries,
        error,
        hasMoreEntries,
        startDate,
        endDate,
      ];

  SystemLogState copyWith({
    bool? isLoading,
    List<SystemLogEntry>? entries,
    String? error,
    bool? hasMoreEntries,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return SystemLogState(
      isLoading: isLoading ?? this.isLoading,
      entries: entries ?? this.entries,
      error: error ?? this.error,
      hasMoreEntries: hasMoreEntries ?? this.hasMoreEntries,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}