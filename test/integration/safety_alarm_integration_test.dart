import 'package:experiment_planner/blocs/alarm/bloc/alarm_bloc.dart';
import 'package:experiment_planner/blocs/alarm/bloc/alarm_event.dart';
import 'package:experiment_planner/blocs/alarm/repository/alarm_repository.dart';
import 'package:experiment_planner/blocs/safety/bloc/safety_bloc.dart';
import 'package:experiment_planner/blocs/safety/bloc/safety_event.dart';
import 'package:experiment_planner/blocs/safety/repository/safety_repository.dart';
import 'package:experiment_planner/features/safety/models/safety_error.dart';
import 'package:experiment_planner/features/alarms/models/alarm.dart';
import 'package:experiment_planner/features/auth/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSafetyRepository extends Mock implements SafetyRepository {}
class MockAlarmRepository extends Mock implements AlarmRepository {}
class MockAuthService extends Mock implements AuthService {}

void main() {
  late SafetyBloc safetyBloc;
  late AlarmBloc alarmBloc;
  late MockSafetyRepository safetyRepository;
  late MockAlarmRepository alarmRepository;
  late MockAuthService authService;

  setUpAll(() {
    registerFallbackValue(SafetyError(
      id: 'dummy',
      description: 'dummy',
      severity: SafetyErrorSeverity.warning,
    ));
    registerFallbackValue(Alarm(
      id: 'dummy',
      message: 'dummy',
      severity: AlarmSeverity.info,
      timestamp: DateTime.now(),
    ));
  });

  setUp(() {
    safetyRepository = MockSafetyRepository();
    alarmRepository = MockAlarmRepository();
    authService = MockAuthService();

    alarmBloc = AlarmBloc(alarmRepository);
    safetyBloc = SafetyBloc(
      repository: safetyRepository,
      authService: authService,
      alarmBloc: alarmBloc,
    );
  });

  tearDown(() {
    safetyBloc.close();
    alarmBloc.close();
  });

  test('Safety error triggers alarm creation', () async {
    // Arrange
    final safetyError = SafetyError(
      id: 'test-1',
      description: 'Critical temperature',
      severity: SafetyErrorSeverity.critical,
    );

    when(() => safetyRepository.addSafetyError(any()))
        .thenAnswer((_) async {});
    when(() => alarmRepository.addAlarm(any()))
        .thenAnswer((_) async {});

    // Act
    safetyBloc.add(SafetyErrorDetected(safetyError));

    // Wait for processing
    await Future.delayed(const Duration(milliseconds: 100));

    // Assert
    verify(() => safetyRepository.addSafetyError(any())).called(1);
    verify(() => alarmRepository.addAlarm(any())).called(1);
  });
}