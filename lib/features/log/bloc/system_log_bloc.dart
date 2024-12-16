import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:experiment_planner/features/auth/services/auth_service.dart';
import 'package:experiment_planner/features/log/repositories/system_log_entry_repository.dart';
import 'package:experiment_planner/features/log/models/system_log_entry.dart';
import 'package:experiment_planner/features/components/models/system_component.dart';
import 'system_log_event.dart';
import 'system_log_state.dart';

class SystemLogBloc extends Bloc<SystemLogEvent, SystemLogState> {
  final SystemLogEntryRepository _repository;
  final AuthService _authService;

  SystemLogBloc({
    required SystemLogEntryRepository repository,
    required AuthService authService,
  })  : _repository = repository,
        _authService = authService,
        super(SystemLogState.initial()) {
    on<LogEntryAdded>(_onLogEntryAdded);
    on<LogEntriesLoaded>(_onLogEntriesLoaded);
    on<LogEntriesFiltered>(_onLogEntriesFiltered);
  }

  Future<void> _onLogEntryAdded(
    LogEntryAdded event,
    Emitter<SystemLogState> emit,
  ) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      emit(state.copyWith(error: 'User not authenticated'));
      return;
    }

    try {
      await _repository.add(event.message, event.severity, userId: userId);
      final entries = [...state.entries];
      entries.insert(
        0,
        SystemLogEntry(
          timestamp: DateTime.now(),
          message: event.message,
          severity: event.severity,
        ),
      );
      emit(state.copyWith(entries: entries));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onLogEntriesLoaded(
    LogEntriesLoaded event,
    Emitter<SystemLogState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final entries = await _repository.getRecentEntries(
        _authService.currentUserId!,
        limit: event.limit,
      );
      emit(state.copyWith(
        entries: entries,
        isLoading: false,
        hasMoreEntries: entries.length >= event.limit,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> _onLogEntriesFiltered(
    LogEntriesFiltered event,
    Emitter<SystemLogState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final entries = await _repository.getEntriesByDateRange(
        _authService.currentUserId!,
        event.startDate,
        event.endDate,
      );
      emit(state.copyWith(
        entries: entries,
        isLoading: false,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }
}