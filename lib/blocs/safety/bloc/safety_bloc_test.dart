import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:experiment_planner/blocs/alarm/bloc/alarm_bloc.dart';
import 'package:experiment_planner/blocs/alarm/bloc/alarm_event.dart';
import 'package:experiment_planner/blocs/safety/bloc/safety_bloc.dart';
import 'package:experiment_planner/blocs/safety/bloc/safety_event.dart';
import 'package:experiment_planner/blocs/safety/bloc/safety_state.dart';
import 'package:experiment_planner/blocs/safety/repository/safety_repository.dart';
import 'package:experiment_planner/modules/system_operation_also_main_module/models/alarm.dart';
import 'package:experiment_planner/modules/system_operation_also_main_module/models/safety_error.dart';
import 'package:experiment_planner/services/auth_service.dart';

class MockSafetyRepository extends Mock implements SafetyRepository {}
class MockAuthService extends Mock implements AuthService {}
class MockAlarmBloc extends Mock implements AlarmBloc {}

void main() {
  late SafetyBloc safetyBloc;
  late MockSafetyRepository repository;
  late MockAuthService authService;
  late MockAlarmBloc alarmBloc;

  setUpAll(() {
    registerFallbackValue( SafetyError(
      id: 'dummy',
      description: 'dummy',
      severity: SafetyErrorSeverity.warning,
    ));
    registerFallbackValue(AddAlarm(
      message: 'test',
      severity: AlarmSeverity.warning,
      isSafetyAlert: true,
    ));
  });

  setUp(() {
    repository = MockSafetyRepository();
    authService = MockAuthService();
    alarmBloc = MockAlarmBloc();
    when(() => repository.addSafetyError(any())).thenAnswer((_) async {});
    when(() => alarmBloc.add(any())).thenAnswer((_) async {});

    safetyBloc = SafetyBloc(
      repository: repository,
      authService: authService,
      alarmBloc: alarmBloc,
    );
  });

  tearDown(() {
    safetyBloc.close();
  });

  final testError = SafetyError(
    id: '1',
    description: 'Test error',
    severity: SafetyErrorSeverity.warning,
  );

  blocTest<SafetyBloc, SafetyState>(
    'initial test',
    build: () => safetyBloc,
    act: (bloc) => bloc.add(SafetyErrorDetected(testError)),
    expect: () => [],
  );

  blocTest<SafetyBloc, SafetyState>(
    'emits new state when error is detected',
    build: () => safetyBloc,
    act: (bloc) => bloc.add(SafetyErrorDetected(testError)),
    verify: (_) {
      verify(() => repository.addSafetyError(any())).called(1);
      verify(() => alarmBloc.add(any())).called(1);
    },
  );

  blocTest<SafetyBloc, SafetyState>(
    'emits error state when repository fails',
    build: () {
      when(() => repository.addSafetyError(testError))
          .thenThrow(Exception('Repository error'));
      return safetyBloc;
    },
    act: (bloc) => bloc.add(SafetyErrorDetected(testError)),
    expect: () => [
      predicate<SafetyState>((state) =>
        state.error?.contains('Repository error') ?? false
      ),
    ],

    verify: (_) {
      verify(() => repository.addSafetyError(testError)).called(1);
      verifyNever(() => alarmBloc.add(any()));
    },
  );
}