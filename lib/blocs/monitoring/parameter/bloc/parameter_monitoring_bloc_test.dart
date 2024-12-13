// lib/blocs/monitoring/parameter/bloc/parameter_monitoring_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:experiment_planner/blocs/safety/bloc/safety_bloc.dart';
import 'package:experiment_planner/blocs/safety/bloc/safety_event.dart';
import 'package:experiment_planner/modules/system_operation_also_main_module/models/safety_error.dart';
import 'parameter_monitoring_bloc.dart';
import 'parameter_monitoring_event.dart';
import 'parameter_monitoring_state.dart';

class MockSafetyBloc extends Mock implements SafetyBloc {}

void main() {
  late ParameterMonitoringBloc monitoringBloc;
  late MockSafetyBloc safetyBloc;

  setUpAll(() {
    registerFallbackValue(SafetyError(
      id: 'dummy',
      description: 'dummy',
      severity: SafetyErrorSeverity.warning,
    ));
    registerFallbackValue(SafetyErrorDetected(
      SafetyError(
        id: 'dummy',
        description: 'dummy',
        severity: SafetyErrorSeverity.warning,
      ),
    ));
  });

  setUp(() {
    safetyBloc = MockSafetyBloc();
    when(() => safetyBloc.add(any())).thenAnswer((_) async {});
    monitoringBloc = ParameterMonitoringBloc(safetyBloc: safetyBloc);
  });

  tearDown(() {
    monitoringBloc.close();
  });

  group('ParameterMonitoringBloc', () {
    final testThresholds = {
      'temperature': {'min': 20.0, 'max': 30.0},
      'pressure': {'min': 1.0, 'max': 2.0},
    };

    test('initial state is correct', () {
      final state = monitoringBloc.state;
      expect(state.isLoading, false);
      expect(state.error, null);
      expect(state.monitoringStatus, isEmpty);
      expect(state.currentValues, isEmpty);
      expect(state.thresholds, isEmpty);
      expect(state.violations, isEmpty);
    });

    blocTest<ParameterMonitoringBloc, ParameterMonitoringState>(
      'starts monitoring with thresholds',
      build: () => monitoringBloc,
      act: (bloc) => bloc.add(StartParameterMonitoring(
        componentId: 'test-component',
        thresholds: testThresholds,
      )),
      expect: () => [
        isA<ParameterMonitoringState>()
          .having((s) => s.monitoringStatus['test-component'], 'monitoring active', true)
          .having((s) => s.thresholds['test-component'], 'thresholds set', testThresholds),
      ],
    );

    blocTest<ParameterMonitoringBloc, ParameterMonitoringState>(
      'detects threshold violations',
      build: () => monitoringBloc,
      seed: () => ParameterMonitoringState(
        isLoading: false,
        error: null,
        lastUpdated: DateTime.now(),
        monitoringStatus: {'test-component': true},
        currentValues: const {},
        thresholds: {'test-component': testThresholds},
        violations: const {},
      ),
      wait: const Duration(milliseconds: 100),
      act: (bloc) => bloc.add(ParameterValueUpdated(
        componentId: 'test-component',
        parameterName: 'temperature',
        value: 35.0, // Above max threshold
      )),
      expect: () => [
        isA<ParameterMonitoringState>()
          .having(
            (s) => s.violations['test-component']?['temperature'],
            'temperature violation',
            true,
          )
          .having(
            (s) => s.currentValues['test-component']?['temperature'],
            'temperature value',
            35.0,
          ),
      ],
      verify: (_) {
        verify(() => safetyBloc.add(any())).called(1);
      },
    );
  });
}