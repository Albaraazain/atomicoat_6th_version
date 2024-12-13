// test/blocs/system_state/bloc/system_state_bloc_test.dart

import 'package:experiment_planner/blocs/system_state/bloc/system_state_bloc.dart';
import 'package:experiment_planner/blocs/system_state/bloc/system_state_event.dart';
import 'package:experiment_planner/blocs/system_state/bloc/system_state_state.dart';
import 'package:experiment_planner/blocs/system_state/models/system_state_data.dart';
import 'package:experiment_planner/repositories/system_state_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/system_state_test_helper.dart';

// Mock repository
class MockSystemStateRepository extends Mock implements SystemStateRepository {
  @override
  Future<SystemStateData?> getLatestState() {
    return Future.value(null);
  }

  @override
  Stream<SystemStateData> watchSystemState() {
    return Stream.empty();
  }

  @override
  Future<void> saveSystemState(Map<String, dynamic> stateData) async {}
}

void main() {
  late SystemStateBloc systemStateBloc;
  late MockSystemStateRepository mockRepository;

  // Test data
  final testSystemState = SystemStateData(
    id: 'test-id',
    data: {
      'components': {
        'component1': {
          'isActivated': true,
          'currentValues': {'temperature': 25.0},
          'setValues': {'temperature': 25.0},
          'minValues': {'temperature': 20.0},
          'maxValues': {'temperature': 30.0},
        },
      },
    },
    timestamp: DateTime.now(),
  );

  setUp(() {
    mockRepository = MockSystemStateRepository();
    systemStateBloc = SystemStateBloc(mockRepository);
  });

  tearDown(() {
    systemStateBloc.close();
  });

  group('SystemStateBloc', () {
    test('initial state is correct', () {
      expect(systemStateBloc.state.status, equals(SystemOperationalStatus.uninitialized));
      expect(systemStateBloc.state.isSystemRunning, isFalse);
      expect(systemStateBloc.state.systemIssues, isEmpty);
    });

    blocTest<SystemStateBloc, SystemStateState>(
      'emits [loading, ready] when InitializeSystem succeeds',
      build: () {
        when(() => mockRepository.getLatestState())
            .thenAnswer((_) async => testSystemState);
        when(() => mockRepository.watchSystemState())
            .thenAnswer((_) => Stream.value(testSystemState));
        return systemStateBloc;
      },
      act: (bloc) => bloc.add(InitializeSystem()),
      expect: () => [
        predicate<SystemStateState>(
          (state) => state.status == SystemOperationalStatus.initializing && state.isLoading,
        ),
        predicate<SystemStateState>(
          (state) =>
              state.status == SystemOperationalStatus.ready &&
              !state.isLoading &&
              state.currentSystemState == testSystemState.data,
        ),
      ],
    );

    // Add test for validation using helper
    test('validates system state correctly', () {
      final issues = SystemStateTestHelper.validateTestState(testSystemState.data);
      expect(issues, isEmpty);
    });

    blocTest<SystemStateBloc, SystemStateState>(
      'emits [loading, error] when InitializeSystem fails',
      build: () {
        when(() => mockRepository.getLatestState())
            .thenThrow(Exception('Failed to initialize'));
        return systemStateBloc;
      },
      act: (bloc) => bloc.add(InitializeSystem()),
      expect: () => [
        predicate<SystemStateState>(
          (state) => state.status == SystemOperationalStatus.initializing && state.isLoading,
        ),
        predicate<SystemStateState>(
          (state) =>
              state.status == SystemOperationalStatus.error &&
              !state.isLoading &&
              state.error != null,
        ),
      ],
    );

    blocTest<SystemStateBloc, SystemStateState>(
      'emits correct states when StartSystem succeeds',
      setUp: () {
        when(() => mockRepository.saveSystemState(any())).thenAnswer((_) async {});
      },
      build: () => systemStateBloc,
      seed: () => SystemStateState(
        status: SystemOperationalStatus.ready,
        isReadinessCheckPassed: true,
      ),
      act: (bloc) => bloc.add(StartSystem()),
      expect: () => [
        predicate<SystemStateState>(
          (state) => state.isLoading,
        ),
        predicate<SystemStateState>(
          (state) =>
              state.status == SystemOperationalStatus.running &&
              state.isSystemRunning &&
              !state.isLoading,
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.saveSystemState(any())).called(1);
      },
    );

    blocTest<SystemStateBloc, SystemStateState>(
      'emits correct states when StopSystem succeeds',
      setUp: () {
        when(() => mockRepository.saveSystemState(any())).thenAnswer((_) async {});
      },
      build: () => systemStateBloc,
      seed: () => SystemStateState(
        status: SystemOperationalStatus.running,
        isSystemRunning: true,
      ),
      act: (bloc) => bloc.add(StopSystem()),
      expect: () => [
        predicate<SystemStateState>(
          (state) => state.isLoading,
        ),
        predicate<SystemStateState>(
          (state) =>
              state.status == SystemOperationalStatus.ready &&
              !state.isSystemRunning &&
              !state.isLoading,
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.saveSystemState(any())).called(1);
      },
    );

    blocTest<SystemStateBloc, SystemStateState>(
      'emits correct states when EmergencyStop is triggered',
      setUp: () {
        when(() => mockRepository.saveSystemState(any())).thenAnswer((_) async {});
      },
      build: () => systemStateBloc,
      seed: () => SystemStateState(
        status: SystemOperationalStatus.running,
        isSystemRunning: true,
      ),
      act: (bloc) => bloc.add(EmergencyStop()),
      expect: () => [
        predicate<SystemStateState>(
          (state) => state.isLoading,
        ),
        predicate<SystemStateState>(
          (state) =>
              state.status == SystemOperationalStatus.emergencyStopped &&
              !state.isSystemRunning &&
              !state.isLoading,
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.saveSystemState(any())).called(1);
      },
    );

    blocTest<SystemStateBloc, SystemStateState>(
      'emits correct states when CheckSystemReadiness is called',
      build: () => systemStateBloc,
      seed: () => SystemStateState(
        currentSystemState: testSystemState.data,
      ),
      act: (bloc) => bloc.add(CheckSystemReadiness()),
      expect: () => [
        predicate<SystemStateState>(
          (state) => state.isLoading,
        ),
        predicate<SystemStateState>(
          (state) => !state.isLoading && state.systemIssues.isEmpty,
        ),
      ],
    );

    blocTest<SystemStateBloc, SystemStateState>(
      'emits correct states when UpdateSystemParameters succeeds',
      setUp: () {
        when(() => mockRepository.saveSystemState(any())).thenAnswer((_) async {});
      },
      build: () => systemStateBloc,
      seed: () => SystemStateState(
        currentSystemState: testSystemState.data,
      ),
      act: (bloc) => bloc.add(UpdateSystemParameters({
        'component1': {'temperature': 26.0},
      })),
      expect: () => [
        predicate<SystemStateState>(
          (state) => state.isLoading,
        ),
        predicate<SystemStateState>(
          (state) => !state.isLoading && state.lastStateUpdate != null,
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.saveSystemState(any())).called(1);
      },
    );
  });
}