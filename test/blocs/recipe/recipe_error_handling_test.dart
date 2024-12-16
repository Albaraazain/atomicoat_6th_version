import 'package:experiment_planner/blocs/alarm/bloc/alarm_bloc.dart';
import 'package:experiment_planner/blocs/alarm/bloc/alarm_event.dart';
import 'package:experiment_planner/blocs/recipe/bloc/recipe_bloc.dart';
import 'package:experiment_planner/blocs/recipe/bloc/recipe_event.dart';
import 'package:experiment_planner/blocs/system_state/bloc/system_state_bloc.dart';
import 'package:experiment_planner/blocs/system_state/bloc/system_state_event.dart';
import 'package:experiment_planner/blocs/system_state/bloc/system_state_state.dart';
import 'package:experiment_planner/features/alarms/models/alarm.dart';
import 'package:experiment_planner/features/recipes/models/recipe.dart';
import 'package:experiment_planner/repositories/recipe_reposiory.dart';
import 'package:experiment_planner/features/auth/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockRecipeRepository extends Mock implements RecipeRepository {}
class MockAuthService extends Mock implements AuthService {}
class MockSystemStateBloc extends Mock implements SystemStateBloc {}
class MockAlarmBloc extends Mock implements AlarmBloc {}

// Fake classes for fallback values
class FakeRecipe extends Fake implements Recipe {}
class FakeSystemStateEvent extends Fake implements SystemStateEvent {}
class FakeUpdateSystemParameters extends Fake implements UpdateSystemParameters {}
class FakeAddAlarm extends Fake implements AddAlarm {}

void main() {
  late RecipeBloc recipeBloc;
  late MockRecipeRepository repository;
  late MockAuthService authService;
  late MockSystemStateBloc systemStateBloc;
  late MockAlarmBloc alarmBloc;

  setUpAll(() {
    registerFallbackValue(FakeRecipe());
    registerFallbackValue(FakeSystemStateEvent());
    registerFallbackValue(FakeUpdateSystemParameters());
    registerFallbackValue(FakeAddAlarm());
  });

  setUp(() {
    repository = MockRecipeRepository();
    authService = MockAuthService();
    systemStateBloc = MockSystemStateBloc();
    alarmBloc = MockAlarmBloc();

    when(() => authService.currentUserId).thenReturn('test-user');
    when(() => systemStateBloc.state).thenReturn(
      SystemStateState(
        status: SystemOperationalStatus.ready,
        isReadinessCheckPassed: true,
        currentSystemState: {
          'components': {
            'Chamber': {
              'currentValues': {'temperature': 25.0},
            },
            'Valve 1': {
              'currentValues': {'status': 0.0},
            },
            'Valve 2': {
              'currentValues': {'status': 0.0},
            },
          },
        },
      ),
    );

    recipeBloc = RecipeBloc(
      repository: repository,
      authService: authService,
      systemStateBloc: systemStateBloc,
      alarmBloc: alarmBloc,
    );
  });

  group('Recipe Error Handling', () {
    test('handles valve error by closing all valves', () async {
      final recipe = Recipe(
        id: 'test-1',
        name: 'Test Recipe',
        substrate: 'Silicon',
        steps: [
          RecipeStep(
            type: StepType.valve,
            parameters: {
              'valveType': ValveType.valveA,
              'duration': 30,
            },
          ),
        ],
      );

      // Add recipe to bloc's state
      when(() => repository.getAll(userId: any(named: 'userId')))
          .thenAnswer((_) async => [recipe]);
      recipeBloc.add(LoadRecipes());
      await Future.delayed(const Duration(milliseconds: 100));

      // Mock system state to throw error
      when(() => systemStateBloc.add(any(that: isA<UpdateSystemParameters>()))).thenThrow(Exception('Valve error'));

      // Start recipe execution
      recipeBloc.add(StartRecipeExecution(recipe.id));
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify error handling
      verifyInOrder([
        () => alarmBloc.add(any(
          that: isA<AddAlarm>()
            .having((a) => a.severity, 'severity', AlarmSeverity.critical)
            .having((a) => a.message, 'message', contains('Valve error')),
        )),
        () => systemStateBloc.add(any(
          that: isA<UpdateSystemParameters>(),
        )),
      ]);
    });

    test('handles parameter error with safe value recovery', () async {
      final recipe = Recipe(
        id: 'test-1',
        name: 'Test Recipe',
        substrate: 'Silicon',
        steps: [
          RecipeStep(
            type: StepType.setParameter,
            parameters: {
              'component': 'Chamber',
              'parameter': 'temperature',
              'value': 500.0,
            },
          ),
        ],
      );

      // Add recipe to bloc's state
      when(() => repository.getAll(userId: any(named: 'userId')))
          .thenAnswer((_) async => [recipe]);
      recipeBloc.add(LoadRecipes());
      await Future.delayed(const Duration(milliseconds: 100));

      // Mock system state to throw error
      when(() => systemStateBloc.add(any(that: isA<UpdateSystemParameters>()))).thenThrow(Exception('Temperature too high'));

      // Start recipe execution
      recipeBloc.add(StartRecipeExecution(recipe.id));
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify error handling
      verifyInOrder([
        () => alarmBloc.add(any(
          that: isA<AddAlarm>()
            .having((a) => a.severity, 'severity', AlarmSeverity.critical),
        )),
        () => systemStateBloc.add(any(
          that: isA<UpdateSystemParameters>(),
        )),
      ]);
    });
  });
}
