// test/blocs/system_state/system_state_bloc_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:experiment_planner/features/system/repositories/system_state_repository.dart';
import 'package:experiment_planner/blocs/system_state/bloc/system_state_bloc.dart';
import 'package:experiment_planner/blocs/system_state/bloc/system_state_event.dart';
import 'package:experiment_planner/blocs/system_state/bloc/system_state_state.dart';
import 'package:experiment_planner/blocs/system_state/models/system_state_data.dart';

// Create a test repository implementation
class TestSystemStateRepository extends SystemStateRepository {
  SystemStateData? _mockState;

  void setMockState(SystemStateData state) {
    _mockState = state;
  }

  @override
  Future<SystemStateData?> getSystemState() async {
    return _mockState;
  }

  @override
  Stream<SystemStateData?> systemStateStream() {
    return Stream.value(_mockState);
  }

  @override
  Future<void> saveSystemState(Map<String, dynamic> stateData) async {
    // Mock implementation
  }
}

void main() {
  late SystemStateBloc bloc;
  late TestSystemStateRepository repository;

  setUp(() {
    repository = TestSystemStateRepository();
    bloc = SystemStateBloc(repository);
  });

  tearDown(() {
    bloc.close();
  });

  group('SystemStateBloc Tests', () {
    test('initial state is correct', () {
      expect(bloc.state.status, equals(SystemOperationalStatus.uninitialized));
      expect(bloc.state.isSystemRunning, isFalse);
      expect(bloc.state.systemIssues, isEmpty);
      expect(bloc.state.currentSystemState, isEmpty);
      expect(bloc.state.lastStateUpdate, isNull);
      expect(bloc.state.isReadinessCheckPassed, isFalse);
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.error, isNull);
    });

    blocTest<SystemStateBloc, SystemStateState>(
      'initializes with existing state',
      build: () {
        final mockState = SystemStateData(
          id: '1',
          data: {
            'components': {
              'component1': {
                'isActivated': true,
                'currentValues': {'temp': 25.0},
                'setValues': {'temp': 25.0},
              }
            }
          },
          timestamp: DateTime.now(),
        );

        repository.setMockState(mockState);
        return bloc;
      },
      act: (bloc) => bloc.add(InitializeSystem()),
      expect: () => [
        predicate<SystemStateState>((state) =>
            state.status == SystemOperationalStatus.initializing &&
            state.isLoading == true),
        predicate<SystemStateState>((state) =>
            state.status == SystemOperationalStatus.ready &&
            state.isLoading == false),
      ],
    );

    blocTest<SystemStateBloc, SystemStateState>(
      'handles start system when ready',
      build: () => bloc,
      seed: () => SystemStateState(
        status: SystemOperationalStatus.ready,
        isSystemRunning: false,
        systemIssues: [],
      ),
      act: (bloc) => bloc.add(StartSystem()),
      expect: () => [
        predicate<SystemStateState>((state) =>
            state.isLoading == true),
        predicate<SystemStateState>((state) =>
            state.status == SystemOperationalStatus.running &&
            state.isSystemRunning == true &&
            state.isLoading == false),
      ],
    );

    blocTest<SystemStateBloc, SystemStateState>(
      'handles emergency stop from any state',
      build: () => bloc,
      act: (bloc) => bloc.add(EmergencyStop()),
      expect: () => [
        predicate<SystemStateState>((state) =>
            state.isLoading == true),
        predicate<SystemStateState>((state) =>
            state.status == SystemOperationalStatus.emergencyStopped &&
            state.isSystemRunning == false &&
            state.isLoading == false),
      ],
    );
  });
}