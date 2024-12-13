// test/blocs/log/system_log_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:experiment_planner/blocs/log/bloc/system_log_bloc.dart';
import 'package:experiment_planner/blocs/log/bloc/system_log_event.dart';
import 'package:experiment_planner/blocs/log/bloc/system_log_state.dart';
import 'package:experiment_planner/modules/system_operation_also_main_module/models/system_log_entry.dart';
import 'package:experiment_planner/modules/system_operation_also_main_module/models/system_component.dart';
import 'package:experiment_planner/services/auth_service.dart';
import 'package:experiment_planner/repositories/system_log_entry_repository.dart';

// Mock implementations
class MockSystemLogEntryRepository extends Mock implements SystemLogEntryRepository {}
class MockAuthService extends Mock implements AuthService {}
class FakeSystemLogEntry extends Fake implements SystemLogEntry {}

void main() {
  setUpAll(() {
    registerFallbackValue(ComponentStatus.normal);
    registerFallbackValue(FakeSystemLogEntry());
  });

  late SystemLogBloc logBloc;
  late MockSystemLogEntryRepository repository;
  late MockAuthService authService;

  setUp(() {
    repository = MockSystemLogEntryRepository();
    authService = MockAuthService();
    logBloc = SystemLogBloc(
      repository: repository,
      authService: authService,
    );

    // Set up default auth mock
    when(() => authService.currentUserId).thenReturn('test-user');
  });

  tearDown(() {
    logBloc.close();
  });

  final testEntry = SystemLogEntry(
    timestamp: DateTime.now(),
    message: 'Test message',
    severity: ComponentStatus.normal,
  );

  test('initial state is correct', () {
    expect(logBloc.state, equals(SystemLogState.initial()));
  });

  group('LogEntryAdded', () {
    blocTest<SystemLogBloc, SystemLogState>(
      'emits updated state when log entry is added',
      build: () {
        when(() => repository.add(any(), any(), userId: any(named: 'userId')))
            .thenAnswer((_) async {});
        return logBloc;
      },
      act: (bloc) => bloc.add(LogEntryAdded(
        message: 'Test message',
        severity: ComponentStatus.normal,
      )),
      expect: () => [
        predicate<SystemLogState>((state) =>
          state.entries.length == 1 &&
          state.entries.first.message == 'Test message' &&
          state.entries.first.severity == ComponentStatus.normal
        ),
      ],
      verify: (_) {
        verify(() => repository.add(any(), any(), userId: 'test-user')).called(1);
      },
    );

    blocTest<SystemLogBloc, SystemLogState>(
      'emits error when user is not authenticated',
      build: () {
        when(() => authService.currentUserId).thenReturn(null);
        return logBloc;
      },
      act: (bloc) => bloc.add(LogEntryAdded(
        message: 'Test message',
        severity: ComponentStatus.normal,
      )),
      expect: () => [
        predicate<SystemLogState>((state) =>
          state.error == 'User not authenticated'
        ),
      ],
    );
  });

  group('LogEntriesLoaded', () {
    final testEntries = [
      testEntry,
      SystemLogEntry(
        timestamp: DateTime.now().subtract(Duration(minutes: 1)),
        message: 'Previous message',
        severity: ComponentStatus.warning,
      ),
    ];

    blocTest<SystemLogBloc, SystemLogState>(
      'emits loaded entries',
      build: () {
        when(() => repository.getRecentEntries(any(), limit: any(named: 'limit')))
            .thenAnswer((_) async => testEntries);
        return logBloc;
      },
      act: (bloc) => bloc.add(LogEntriesLoaded(limit: 10)),
      expect: () => [
        predicate<SystemLogState>((state) => state.isLoading == true),
        predicate<SystemLogState>((state) =>
          state.isLoading == false &&
          state.entries.length == 2 &&
          state.hasMoreEntries == false
        ),
      ],
    );
  });

  group('LogEntriesFiltered', () {
    final startDate = DateTime.now().subtract(Duration(days: 1));
    final endDate = DateTime.now();

    blocTest<SystemLogBloc, SystemLogState>(
      'emits filtered entries',
      build: () {
        when(() => repository.getEntriesByDateRange(any(), any(), any()))
            .thenAnswer((_) async => [testEntry]);
        return logBloc;
      },
      act: (bloc) => bloc.add(LogEntriesFiltered(
        startDate: startDate,
        endDate: endDate,
        severityFilter: ComponentStatus.normal,
      )),
      expect: () => [
        predicate<SystemLogState>((state) => state.isLoading == true),
        predicate<SystemLogState>((state) =>
          state.isLoading == false &&
          state.entries.length == 1 &&
          state.startDate == startDate &&
          state.endDate == endDate
        ),
      ],
    );
  });
}