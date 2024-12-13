import 'package:bloc_test/bloc_test.dart';
import 'package:experiment_planner/blocs/alarm/bloc/alarm_bloc.dart';
import 'package:experiment_planner/blocs/recipe/bloc/recipe_bloc.dart';
import 'package:experiment_planner/blocs/recipe/bloc/recipe_event.dart';
import 'package:experiment_planner/blocs/recipe/bloc/recipe_state.dart';
import 'package:experiment_planner/blocs/system_state/bloc/system_state_bloc.dart';
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

void main() {
  late RecipeBloc recipeBloc;
  late MockRecipeRepository repository;
  late MockAuthService authService;
  late MockSystemStateBloc systemStateBloc;
  late MockAlarmBloc alarmBloc;

  setUp(() {
    repository = MockRecipeRepository();
    authService = MockAuthService();
    systemStateBloc = MockSystemStateBloc();
    alarmBloc = MockAlarmBloc();

    when(() => authService.currentUserId).thenReturn('test-user');

    recipeBloc = RecipeBloc(
      repository: repository,
      authService: authService,
      systemStateBloc: systemStateBloc,
      alarmBloc: alarmBloc,
    );
  });

  group('Recipe Validation', () {
    blocTest<RecipeBloc, RecipeState>(
      'validates recipe with empty name',
      build: () {
        final invalidRecipe = Recipe(
          id: 'test-1',
          name: '',
          substrate: 'Silicon',
          steps: [
            RecipeStep(
              type: StepType.setParameter,
              parameters: {
                'component': 'Chamber',
                'parameter': 'temperature',
                'value': 150.0,
              },
            ),
          ],
        );

        when(() => repository.getAll(userId: any(named: 'userId')))
            .thenAnswer((_) async => [invalidRecipe]);
        when(() => systemStateBloc.state).thenReturn(
          SystemStateState(
            status: SystemOperationalStatus.ready,
            isReadinessCheckPassed: true,
          ),
        );

        return recipeBloc;
      },
      seed: () => RecipeState.initial(),
      act: (bloc) async {
        bloc.add(LoadRecipes());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(StartRecipeExecution('test-1'));
      },
      expect: () => [
        predicate<RecipeState>((state) => state.isLoading == true),
        predicate<RecipeState>((state) =>
          state.isLoading == false &&
          state.recipes.length == 1
        ),
        predicate<RecipeState>((state) =>
          state.error?.contains('Recipe name is required') == true &&
          state.executionStatus == RecipeExecutionStatus.error
        ),
      ],
      wait: const Duration(milliseconds: 100),
    );

    blocTest<RecipeBloc, RecipeState>(
      'validates recipe with missing step parameters',
      build: () {
        final invalidRecipe = Recipe(
          id: 'test-1',
          name: 'Test Recipe',
          substrate: 'Silicon',
          steps: [
            RecipeStep(
              type: StepType.valve,
              parameters: {},
            ),
          ],
        );

        when(() => repository.getAll(userId: any(named: 'userId')))
            .thenAnswer((_) async => [invalidRecipe]);
        when(() => systemStateBloc.state).thenReturn(
          SystemStateState(
            status: SystemOperationalStatus.ready,
            isReadinessCheckPassed: true,
          ),
        );

        return recipeBloc;
      },
      seed: () => RecipeState.initial(),
      act: (bloc) async {
        bloc.add(LoadRecipes());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(StartRecipeExecution('test-1'));
      },
      expect: () => [
        predicate<RecipeState>((state) => state.isLoading == true),
        predicate<RecipeState>((state) =>
          state.isLoading == false &&
          state.recipes.length == 1
        ),
        predicate<RecipeState>((state) =>
          state.error?.contains('Valve duration is required') == true &&
          state.executionStatus == RecipeExecutionStatus.error
        ),
      ],
      wait: const Duration(milliseconds: 100),
    );

    blocTest<RecipeBloc, RecipeState>(
      'validates loop step with no substeps',
      build: () {
        final invalidRecipe = Recipe(
          id: 'test-1',
          name: 'Test Recipe',
          substrate: 'Silicon',
          steps: [
            RecipeStep(
              type: StepType.loop,
              parameters: {'iterations': 5},
              subSteps: [],
            ),
          ],
        );

        when(() => repository.getAll(userId: any(named: 'userId')))
            .thenAnswer((_) async => [invalidRecipe]);
        when(() => systemStateBloc.state).thenReturn(
          SystemStateState(
            status: SystemOperationalStatus.ready,
            isReadinessCheckPassed: true,
          ),
        );

        return recipeBloc;
      },
      seed: () => RecipeState.initial(),
      act: (bloc) async {
        bloc.add(LoadRecipes());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(StartRecipeExecution('test-1'));
      },
      expect: () => [
        predicate<RecipeState>((state) => state.isLoading == true),
        predicate<RecipeState>((state) =>
          state.isLoading == false &&
          state.recipes.length == 1
        ),
        predicate<RecipeState>((state) =>
          state.error?.contains('Loop must contain substeps') == true &&
          state.executionStatus == RecipeExecutionStatus.error
        ),
      ],
      wait: const Duration(milliseconds: 100),
    );
  });
}
