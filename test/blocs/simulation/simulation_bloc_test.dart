// test/blocs/simulation/simulation_bloc_test.dart
import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:experiment_planner/blocs/alarm/bloc/alarm_bloc.dart';
import 'package:experiment_planner/blocs/alarm/bloc/alarm_event.dart';
import 'package:experiment_planner/blocs/component/bloc/component_bloc.dart';
import 'package:experiment_planner/blocs/component/bloc/component_event.dart';
import 'package:experiment_planner/blocs/component/bloc/component_state.dart';
import 'package:experiment_planner/blocs/safety/bloc/safety_bloc.dart';
import 'package:experiment_planner/blocs/simulation/bloc/simulation_bloc.dart';
import 'package:experiment_planner/blocs/simulation/bloc/simulation_event.dart';
import 'package:experiment_planner/blocs/simulation/bloc/simulation_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:experiment_planner/modules/system_operation_also_main_module/models/system_component.dart';
import 'package:experiment_planner/blocs/safety/bloc/safety_event.dart';

class MockComponentBloc extends Mock implements ComponentBloc {}

class MockAlarmBloc extends Mock implements AlarmBloc {}

class MockSafetyBloc extends Mock implements SafetyBloc {}

// Add mock event classes
class MockAlarmEvent extends Fake implements AlarmEvent {}

class MockComponentEvent extends Fake implements ComponentEvent {}
// Remove TestSafetyEvent class

void main() {
  late SimulationBloc simulationBloc;
  late MockComponentBloc componentBloc;
  late MockAlarmBloc alarmBloc;
  late MockSafetyBloc safetyBloc;

  setUpAll(() {
    registerFallbackValue(MockAlarmEvent());
    registerFallbackValue(MockComponentEvent());
    registerFallbackValue(
        SafetyMonitoringStarted()); // Use concrete implementation
  });

  setUp(() {
    componentBloc = MockComponentBloc();
    alarmBloc = MockAlarmBloc();
    safetyBloc = MockSafetyBloc();
    simulationBloc = SimulationBloc(
      componentBloc: componentBloc,
      alarmBloc: alarmBloc,
      safetyBloc: safetyBloc,
    );
  });

  tearDown(() {
    simulationBloc.close();
  });

  group('SimulationBloc', () {
    test('initial state is correct', () {
      final state = simulationBloc.state;
      expect(state.status, equals(SimulationStatus.idle));
      expect(state.tickCount, equals(0));
      // Remove lastUpdateTime check for now
    });

    blocTest<SimulationBloc, SimulationState>(
      'emits idle state when simulation stops',
      build: () {
        when(() => alarmBloc.add(any())).thenAnswer((_) async {});
        return simulationBloc;
      },
      seed: () => SimulationState.initial().copyWith(
        status: SimulationStatus.running,
        tickCount: 10,
      ),
      act: (bloc) => bloc.add(StopSimulation()),
      expect: () => [
        predicate<SimulationState>((state) =>
                state.status == SimulationStatus.idle &&
                state.tickCount == 10 &&
                state.lastUpdated != null // Check lastUpdated is set
            ),
      ],
    );

    blocTest<SimulationBloc, SimulationState>(
      'updates component values on simulation tick',
      build: () {
        when(() => componentBloc.add(any())).thenAnswer((_) async {});
        return simulationBloc;
      },
      seed: () => SimulationState.initial().copyWith(
        status: SimulationStatus.running,
      ),
      act: (bloc) => bloc.add(SimulationTick()),
      verify: (_) {
        verify(() => componentBloc.add(any())).called(greaterThan(0));
      },
    );

    blocTest<SimulationBloc, SimulationState>(
      'handles component dependencies correctly',
      build: () {
        when(() => componentBloc.add(any())).thenAnswer((_) async {});
        return simulationBloc;
      },
      act: (bloc) => bloc.add(UpdateComponentValues({
        'MFC': {'flow_rate': 50.0},
      })),
      verify: (_) {
        // Should update both MFC and dependent components
        verify(() => componentBloc.add(any())).called(greaterThan(1));
      },
    );

    blocTest<SimulationBloc, SimulationState>(
      'generates random errors with proper notifications',
      build: () {
        when(() => componentBloc.add(any())).thenAnswer((_) async {});
        when(() => safetyBloc.add(any())).thenAnswer((_) async {});
        return SimulationBloc(
          componentBloc: componentBloc,
          alarmBloc: alarmBloc,
          safetyBloc: safetyBloc,
          random: Random(42), // Fixed seed for deterministic tests
        );
      },
      act: (bloc) => bloc.add(GenerateRandomError()),
      expect: () => [
        predicate<SimulationState>(
            (state) => state.lastUpdated != null // Just check state was updated
            ),
      ],
      verify: (_) {
        // Verify either component or safety bloc was called
        final componentCalls = verify(() => componentBloc.add(any())).callCount;
        final safetyCalls = verify(() => safetyBloc.add(any())).callCount;
        expect(componentCalls + safetyCalls, equals(2));
      },
    );

    blocTest<SimulationBloc, SimulationState>(
      'performs safety checks correctly',
      build: () {
        when(() => componentBloc.add(any())).thenAnswer((_) async {});
        return simulationBloc;
      },
      act: (bloc) => bloc.add(CheckSafetyConditions()),
      verify: (_) {
        verify(() => componentBloc.add(any())).called(greaterThan(0));
      },
    );
  });

  group('Component Behavior Integration', () {
    blocTest<SimulationBloc, SimulationState>(
      'generates values using component behaviors',
      build: () {
        when(() => componentBloc.add(any())).thenAnswer((_) async {});
        when(() => componentBloc.state).thenReturn(
          ComponentState.loaded(SystemComponent(
            name: 'Reaction Chamber',
            description: 'Test chamber',
            currentValues: {
              'temperature': 150.0,
              'pressure': 1.0,
            },
            setValues: {
              'temperature': 150.0,
              'pressure': 1.0,
            },
            isActivated: true,
          )),
        );
        return simulationBloc;
      },
      act: (bloc) => bloc.add(SimulationTick()),
      verify: (_) {
        final captured = verify(() => componentBloc.add(captureAny())).captured;
        expect(
          captured.whereType<ComponentValueUpdated>(),
          hasLength(greaterThan(0)),
        );
      },
    );

    blocTest<SimulationBloc, SimulationState>(
      'validates values before updating components',
      build: () {
        when(() => componentBloc.add(any())).thenAnswer((_) async {});
        when(() => componentBloc.state).thenReturn(
          ComponentState.loaded(SystemComponent(
            name: 'Reaction Chamber',
            description: 'Test chamber',
            currentValues: {
              'temperature': 350.0, // Invalid temperature
              'pressure': 1.0,
            },
            setValues: {
              'temperature': 350.0,
              'pressure': 1.0,
            },
            isActivated: true,
          )),
        );
        return simulationBloc;
      },
      act: (bloc) => bloc.add(SimulationTick()),
      verify: (_) {
        verify(() => safetyBloc.add(any())).called(greaterThan(0));
      },
    );

    blocTest<SimulationBloc, SimulationState>(
      'processes component dependencies correctly',
      build: () {
        // Setup component state
        when(() => componentBloc.state).thenReturn(
          ComponentState.loaded(SystemComponent(
            name: 'MFC',
            description: 'Test MFC',
            currentValues: {'flow_rate': 50.0},
            setValues: {'flow_rate': 50.0},
            isActivated: true,
          )),
        );
        when(() => componentBloc.add(any())).thenAnswer((_) async {});
        return simulationBloc;
      },
      act: (bloc) => bloc.add(UpdateComponentValues({
        'MFC': {'flow_rate': 50.0},
      })),
      expect: () => [
        predicate<SimulationState>(
            (state) => state.lastComponentUpdates.containsKey('MFC')),
      ],
      verify: (_) {
        verify(() => componentBloc.add(any())).called(2);
      },
    );
  });

  blocTest<SimulationBloc, SimulationState>(
    'generates values using component behaviors',
    build: () {
      // Setup component state and behavior
      when(() => componentBloc.state).thenReturn(
        ComponentState.loaded(SystemComponent(
          name: 'Reaction Chamber',
          description: 'Test chamber',
          currentValues: {
            'temperature': 150.0,
            'pressure': 1.0,
          },
          setValues: {
            'temperature': 150.0,
            'pressure': 1.0,
          },
          isActivated: true,
        )),
      );
      when(() => componentBloc.add(any())).thenAnswer((_) async {});
      return simulationBloc;
    },
    seed: () => SimulationState.initial().copyWith(
      status: SimulationStatus.running,
    ),
    act: (bloc) => bloc.add(SimulationTick()),
    expect: () => [
      predicate<SimulationState>(
          (state) => state.tickCount == 1),
    ],
    verify: (_) {
      // Verify component updates were triggered
      final calls = verify(() => componentBloc.add(any())).captured;
      expect(
        calls.whereType<ComponentValueUpdated>().length,
        greaterThan(0),
        reason: 'Should have at least one ComponentValueUpdated event',
      );
    },
  );
}
