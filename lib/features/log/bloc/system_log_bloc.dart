import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:experiment_planner/features/log/repositories/system_log_entry_repository.dart';
import 'package:experiment_planner/features/log/models/system_log_entry.dart';
import 'package:experiment_planner/features/components/models/system_component.dart';
import 'package:experiment_planner/features/auth/bloc/auth_bloc.dart';
import 'package:experiment_planner/features/auth/bloc/auth_state.dart';
import 'system_log_event.dart';
import 'system_log_state.dart';

class SystemLogBloc extends Bloc<SystemLogEvent, SystemLogState> {
  final SystemLogEntryRepository _repository;
  final AuthBloc _authBloc;
  StreamSubscription? _authSubscription;

  SystemLogBloc({
    required SystemLogEntryRepository repository,
    required AuthBloc authBloc,
  })  : _repository = repository,
        _authBloc = authBloc,
        super(SystemLogState.initial()) {
    on<LogEntryAdded>(_onLogEntryAdded);
    on<LogEntriesLoaded>(_onLogEntriesLoaded);
    on<LogEntriesFiltered>(_onLogEntriesFiltered);

    // Subscribe to auth state changes
    _authSubscription = _authBloc.stream.listen((authState) {
      if (authState.status == AuthStatus.authenticated) {
        add(LogEntriesLoaded(limit: 50)); // Load initial entries
      } else if (authState.status == AuthStatus.unauthenticated) {
        emit(SystemLogState.initial());
      }
    });
  }

  String? get _currentUserId => _authBloc.state.user?.id;

  Future<void> _onLogEntryAdded(
    LogEntryAdded event,
    Emitter<SystemLogState> emit,
  ) async {
    final userId = _currentUserId;
    if (userId == null) {
      emit(state.copyWith(error: 'User not authenticated'));
      return;
    }

    try {
      final logEntry = SystemLogEntry(
        timestamp: DateTime.now(),
        message: event.message,
        severity: event.severity,
      );

      // Generate a unique ID for the log entry
      final id = DateTime.now().millisecondsSinceEpoch.toString();

      await _repository.add(id, logEntry, userId: userId);

      final entries = [...state.entries];
      entries.insert(0, logEntry);
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

    final userId = _currentUserId;
    if (userId == null) {
      emit(state.copyWith(
        error: 'User not authenticated',
        isLoading: false,
      ));
      return;
    }

    try {
      final entries = await _repository.getRecentEntries(
        userId,
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

    final userId = _currentUserId;
    if (userId == null) {
      emit(state.copyWith(
        error: 'User not authenticated',
        isLoading: false,
      ));
      return;
    }

    try {
      final entries = await _repository.getEntriesByDateRange(
        userId,
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

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
