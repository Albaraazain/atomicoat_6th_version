// test/blocs/recipe/recipe_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:experiment_planner/blocs/alarm/bloc/alarm_bloc.dart';
import 'package:experiment_planner/blocs/recipe/bloc/recipe_bloc.dart';
import 'package:experiment_planner/blocs/recipe/bloc/recipe_event.dart';
import 'package:experiment_planner/blocs/recipe/bloc/recipe_state.dart';
import 'package:experiment_planner/blocs/system_state/bloc/system_state_bloc.dart';
import 'package:experiment_planner/blocs/system_state/bloc/system_state_event.dart';
import 'package:experiment_planner/blocs/system_state/bloc/system_state_state.dart';
import 'package:experiment_planner/modules/system_operation_also_main_module/models/recipe.dart';
import 'package:experiment_planner/repositories/recipe_reposiory.dart';
import 'package:experiment_planner/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}
class MockAuthService extends Mock implements AuthService {}
class MockSystemStateBloc extends Mock implements SystemStateBloc {}
class MockAlarmBloc extends Mock implements AlarmBloc {}

// Add these classes for fallback registration
class FakeRecipe extends Fake implements Recipe {}
class FakeSystemStateEvent extends Fake implements SystemStateEvent {}

void main() {
  late RecipeBloc recipeBloc;
  late MockRecipeRepository repository;
  late MockAuthService authService;
  late MockSystemStateBloc systemStateBloc;
  late MockAlarmBloc alarmBloc;

  setUpAll(() {
    registerFallbackValue(FakeRecipe());
    registerFallbackValue(FakeSystemStateEvent());
  });

  final testRecipe = Recipe(
    id: 'test-1',
    name: 'Test Recipe',
    substrate: 'Silicon',
    steps: [
      RecipeStep(
        type: StepType.setParameter,
        parameters: {
          'component': 'Reaction Chamber',
          'parameter': 'temperature',
          'value': 150.0,
        },
      ),
      RecipeStep(
        type: StepType.purge,
        parameters: {
          'duration': 30,
          'gasFlow': 100.0,
        },
      ),
    ],
  );

  setUp(() {
    repository = MockRecipeRepository();
    authService = MockAuthService();
    systemStateBloc = MockSystemStateBloc();
    alarmBloc = MockAlarmBloc();

    // Fix auth mock setup
    when(() => authService.currentUserId).thenReturn('test-user');

    recipeBloc = RecipeBloc(
      repository: repository,
      authService: authService,
      systemStateBloc: systemStateBloc,
      alarmBloc: alarmBloc,
    );
  });

  tearDown(() {
    recipeBloc.close();
  });

  group('RecipeBloc', () {
    test('initial state is correct', () {
      final state = recipeBloc.state;
      expect(state.isLoading, false);
      expect(state.recipes, isEmpty);
      expect(state.executionStatus, RecipeExecutionStatus.idle);
    });

    group('LoadRecipes', () {
      blocTest<RecipeBloc, RecipeState>(
        'emits loaded state when recipes are successfully loaded',
        build: () {
          when(() => repository.getAll(userId: any(named: 'userId')))
              .thenAnswer((_) async => [testRecipe]);
          return recipeBloc;
        },
        act: (bloc) => bloc.add(LoadRecipes()),
        expect: () => [
          predicate<RecipeState>((state) => state.isLoading == true),
          predicate<RecipeState>((state) =>
            state.isLoading == false &&
            state.recipes.length == 1 &&
            state.recipes.first.id == testRecipe.id
          ),
        ],
      );

      blocTest<RecipeBloc, RecipeState>(
        'emits error when user is not authenticated',
        build: () {
          when(() => authService.currentUserId).thenReturn(null);
          return recipeBloc;
        },
        act: (bloc) => bloc.add(LoadRecipes()),
        expect: () => [
          predicate<RecipeState>((state) => state.isLoading == true),
          predicate<RecipeState>((state) =>
            state.isLoading == false &&
            state.error == 'User not authenticated'
          ),
        ],
      );
    });

    group('AddRecipe', () {
      blocTest<RecipeBloc, RecipeState>(
        'emits updated state when recipe is added',
        build: () {
          when(() => repository.add(any(), any(), userId: any(named: 'userId')))
              .thenAnswer((_) async {});
          return recipeBloc;
        },
        act: (bloc) => bloc.add(AddRecipe(testRecipe)),
        expect: () => [
          predicate<RecipeState>((state) => state.isLoading == true),
          predicate<RecipeState>((state) =>
            state.isLoading == false &&
            state.recipes.contains(testRecipe)
          ),
        ],
        verify: (_) {
          verify(() => repository.add(testRecipe.id, testRecipe, userId: 'test-user')).called(1);
        },
      );
    });

    group('StartRecipeExecution', () {
      blocTest<RecipeBloc, RecipeState>(
        'emits running state when recipe execution starts',
        build: () {
          when(() => systemStateBloc.state).thenReturn(
            SystemStateState(
              status: SystemOperationalStatus.ready,
              isReadinessCheckPassed: true,
              currentSystemState: {
                'components': {
                  'Reaction Chamber': {
                    'currentValues': {
                      'temperature': 150.0,
                    },
                  },
                  'Pressure Control System': {
                    'currentValues': {
                      'pressure': 1.0,
                    },
                  },
                },
              },
            ),
          );
          when(() => systemStateBloc.add(any())).thenAnswer((_) async {});
          return recipeBloc;
        },
        seed: () => RecipeState.initial().copyWith(recipes: [testRecipe]),
        act: (bloc) => bloc.add(StartRecipeExecution(testRecipe.id)),
        expect: () => [
          isA<RecipeState>()
            .having((s) => s.activeRecipe?.id, 'activeRecipe.id', testRecipe.id)
            .having((s) => s.executionStatus, 'executionStatus', RecipeExecutionStatus.running)
            .having((s) => s.currentStepIndex, 'currentStepIndex', 0),
        ],
        wait: const Duration(milliseconds: 100),
      );

      blocTest<RecipeBloc, RecipeState>(
        'emits error when recipe is not found',
        build: () => recipeBloc,
        act: (bloc) => bloc.add(StartRecipeExecution('non-existent')),
        expect: () => [
          predicate<RecipeState>((state) =>
            state.error != null &&
            state.error!.contains('Recipe not found') &&
            state.executionStatus == RecipeExecutionStatus.error
          ),
        ],
      );
    });

    group('StopRecipeExecution', () {
      blocTest<RecipeBloc, RecipeState>(
        'emits idle state when recipe execution is stopped',
        build: () {
          when(() => systemStateBloc.add(any())).thenAnswer((_) async {});
          when(() => systemStateBloc.state).thenReturn(
            SystemStateState(
              status: SystemOperationalStatus.ready,
            ),
          );
          return recipeBloc;
        },
        seed: () => RecipeState.initial().copyWith(
          activeRecipe: testRecipe,
          executionStatus: RecipeExecutionStatus.running,
        ),
        act: (bloc) => bloc.add(StopRecipeExecution()),
        expect: () => [
          isA<RecipeState>()
            .having((s) => s.executionStatus, 'executionStatus', RecipeExecutionStatus.idle)
            .having((s) => s.activeRecipe, 'activeRecipe', isNull)
            .having((s) => s.currentStepIndex, 'currentStepIndex', 0)
            .having((s) => s.recipes, 'recipes', isEmpty),
        ],
        verify: (_) {
          verify(() => systemStateBloc.add(any())).called(1);
        },
        wait: const Duration(milliseconds: 100),
      );
    });

    group('LoadRecipeVersions', () {
      blocTest<RecipeBloc, RecipeState>(
        'emits versions when loaded successfully',
        build: () {
          final versions = [
            testRecipe.copyWith(version: 1),
            testRecipe.copyWith(version: 2),
          ];
          when(() => repository.getAll(userId: any(named: 'userId')))
              .thenAnswer((_) async => versions);
          return recipeBloc;
        },
        act: (bloc) => bloc.add(LoadRecipeVersions(testRecipe.id)),
        expect: () => [
          predicate<RecipeState>((state) => state.isLoading == true),
          predicate<RecipeState>((state) =>
            state.isLoading == false &&
            state.recipeVersions[testRecipe.id]?.length == 2
          ),
        ],
      );
    });

    group('RecipeStepCompleted', () {
      blocTest<RecipeBloc, RecipeState>(
        'moves to next step when available',
        build: () => recipeBloc,
        seed: () => RecipeState.initial().copyWith(
          activeRecipe: testRecipe,
          executionStatus: RecipeExecutionStatus.running,
          currentStepIndex: 0,
        ),
        act: (bloc) => bloc.add(RecipeStepCompleted(0)),
        expect: () => [
          predicate<RecipeState>((state) =>
            state.currentStepIndex == 1 &&
            state.executionStatus == RecipeExecutionStatus.running
          ),
        ],
      );

      blocTest<RecipeBloc, RecipeState>(
        'completes recipe when no more steps',
        build: () {
          when(() => systemStateBloc.add(any())).thenAnswer((_) async {});
          return recipeBloc;
        },
        seed: () => RecipeState.initial().copyWith(
          activeRecipe: testRecipe,
          executionStatus: RecipeExecutionStatus.running,
          currentStepIndex: 1,
        ),
        act: (bloc) => bloc.add(RecipeStepCompleted(1)),
        expect: () => [
          predicate<RecipeState>((state) =>
            state.currentStepIndex == 0 &&
            state.executionStatus == RecipeExecutionStatus.completed
          ),
        ],
      );
    });
  });
}