import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:experiment_planner/core/utils/bloc_utils.dart';
import 'package:experiment_planner/features/alarms/bloc/alarm_bloc.dart';
import 'package:experiment_planner/features/alarms/bloc/alarm_event.dart';
import 'package:experiment_planner/features/alarms/models/alarm.dart';
import 'package:experiment_planner/features/auth/bloc/auth_bloc.dart';
import 'package:experiment_planner/features/auth/bloc/auth_state.dart';
import 'package:experiment_planner/features/recipes/models/recipe.dart';
import 'package:experiment_planner/features/recipes/repository/recipe_repository.dart';
import 'package:experiment_planner/features/recipes/utils/recipe_debug.dart';
import 'package:experiment_planner/features/system/bloc/system_state_event.dart';
import '../../system/bloc/system_state_bloc.dart';
import 'recipe_event.dart';
import 'recipe_state.dart';
import '../models/recipe_validation_result.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final RecipeRepository _repository;
  final AuthBloc _authBloc;
  final SystemStateBloc _systemStateBloc;
  final AlarmBloc _alarmBloc;
  Timer? _executionTimer;
  StreamSubscription? _authSubscription;

  RecipeBloc({
    required RecipeRepository repository,
    required AuthBloc authBloc,
    required SystemStateBloc systemStateBloc,
    required AlarmBloc alarmBloc,
  })  : _repository = repository,
        _authBloc = authBloc,
        _systemStateBloc = systemStateBloc,
        _alarmBloc = alarmBloc,
        super(RecipeState.initial()) {
    on<LoadRecipes>(_onLoadRecipes);
    on<AddRecipe>(_onAddRecipe);
    on<UpdateRecipe>(_onUpdateRecipe);
    on<DeleteRecipe>(_onDeleteRecipe);
    on<StartRecipeExecution>(_onStartRecipeExecution);
    on<PauseRecipeExecution>(_onPauseRecipeExecution);
    on<ResumeRecipeExecution>(_onResumeRecipeExecution);
    on<StopRecipeExecution>(_onStopRecipeExecution);
    on<RecipeStepCompleted>(_onRecipeStepCompleted);
    on<LoadRecipeVersions>(_onLoadRecipeVersions);
    on<CompareRecipeVersions>(_onCompareRecipeVersions);

    _authSubscription = _authBloc.stream.listen((authState) {
      if (authState.status == AuthStatus.authenticated) {
        add(LoadRecipes());
      } else if (authState.status == AuthStatus.unauthenticated) {
        emit(RecipeState.initial());
      }
    });
  }

  String? get _currentUserId => _authBloc.state.user?.id;

  RecipeValidationResult _validateRecipe(Recipe recipe) {
    final errors = <String>[];

    // Validate basic recipe properties
    if (recipe.name.isEmpty) {
      errors.add('Recipe name is required');
    }
    if (recipe.substrate.isEmpty) {
      errors.add('Substrate is required');
    }
    if (recipe.steps.isEmpty) {
      errors.add('Recipe must have at least one step');
    }

    // Validate each step
    for (int i = 0; i < recipe.steps.length; i++) {
      final stepErrors = _validateStep(recipe.steps[i], i);
      errors.addAll(stepErrors);
    }

    return RecipeValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  List<String> _validateStep(RecipeStep step, int index) {
    final errors = <String>[];
    final prefix = 'Step ${index + 1}';

    switch (step.type) {
      case StepType.valve:
        if (!step.parameters.containsKey('duration')) {
          errors.add('$prefix: Valve duration is required');
        } else if (step.parameters['duration'] <= 0) {
          errors.add('$prefix: Valve duration must be positive');
        }
        if (!step.parameters.containsKey('valveType')) {
          errors.add('$prefix: Valve type is required');
        }
        break;

      case StepType.purge:
        if (!step.parameters.containsKey('duration')) {
          errors.add('$prefix: Purge duration is required');
        } else if (step.parameters['duration'] <= 0) {
          errors.add('$prefix: Purge duration must be positive');
        }
        break;

      case StepType.loop:
        if (!step.parameters.containsKey('iterations')) {
          errors.add('$prefix: Loop iterations is required');
        } else if (step.parameters['iterations'] <= 0) {
          errors.add('$prefix: Loop iterations must be positive');
        }
        if (step.subSteps == null || step.subSteps!.isEmpty) {
          errors.add('$prefix: Loop must contain substeps');
        } else {
          for (int i = 0; i < step.subSteps!.length; i++) {
            final substepErrors = _validateStep(step.subSteps![i], i);
            errors.addAll(substepErrors.map((e) => '$prefix (Substep ${i + 1}): $e'));
          }
        }
        break;

      case StepType.setParameter:
        if (!step.parameters.containsKey('component')) {
          errors.add('$prefix: Component name is required');
        }
        if (!step.parameters.containsKey('parameter')) {
          errors.add('$prefix: Parameter name is required');
        }
        if (!step.parameters.containsKey('value')) {
          errors.add('$prefix: Parameter value is required');
        }
        break;
    }

    return errors;
  }

  Future<bool> _handleStepError(
    RecipeStep step,
    dynamic error,
    Emitter<RecipeState> emit,
  ) async {
    final errorMessage = error.toString();

    _alarmBloc.add(AddAlarm(
      message: 'Error executing step: $errorMessage',
      severity: AlarmSeverity.critical,
    ));

    switch (step.type) {
      case StepType.valve:
        return await _recoverValveError(step);
      case StepType.purge:
        return await _recoverPurgeError(step);
      case StepType.setParameter:
        return await _recoverParameterError(step);
      case StepType.loop:
        return false;
    }
  }

  Future<bool> _recoverValveError(RecipeStep step) async {
    try {
      _systemStateBloc.add(UpdateSystemParameters({
        'Valve 1': {'status': 0.0},
        'Valve 2': {'status': 0.0},
      }));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _recoverPurgeError(RecipeStep step) async {
    try {
      _systemStateBloc.add(UpdateSystemParameters({
        'MFC': {'flow_rate': 0.0},
        'Valve 1': {'status': 0.0},
        'Valve 2': {'status': 0.0},
      }));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _recoverParameterError(RecipeStep step) async {
    try {
      final componentName = step.parameters['component'] as String;
      final parameter = step.parameters['parameter'] as String;

      switch (parameter) {
        case 'temperature':
          _systemStateBloc.add(UpdateSystemParameters({
            componentName: {'temperature': 25.0},
          }));
          break;
        case 'pressure':
          _systemStateBloc.add(UpdateSystemParameters({
            componentName: {'pressure': 1.0},
          }));
          break;
        default:
          return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _onLoadRecipes(
    LoadRecipes event,
    Emitter<RecipeState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final userId = _currentUserId;
      if (userId == null) {
        emit(state.copyWith(
          error: 'User not authenticated',
          isLoading: false,
        ));
        return;
      }

      final recipes = await _repository.getAll(userId: userId);
      emit(state.copyWith(
        recipes: recipes,
        isLoading: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
        isLoading: false,
      ));
    }
  }

  Future<void> _onStartRecipeExecution(
    StartRecipeExecution event,
    Emitter<RecipeState> emit,
  ) async {
    try {
      final recipe = state.recipes.firstWhere(
        (r) => r.id == event.recipeId,
        orElse: () => throw Exception('Recipe not found'),
      );

      // Add validation
      final validation = _validateRecipe(recipe);
      if (!validation.isValid) {
        throw Exception('Invalid recipe: ${validation.errors.join(', ')}');
      }

      // Modified system readiness check
      final systemState = _systemStateBloc.state;
      if (!systemState.isReadinessCheckPassed) {
        // Request a fresh system check
        _systemStateBloc.add(CheckSystemReadiness());

        // Wait briefly for the check to complete
        await Future.delayed(Duration(milliseconds: 100));

        // Get updated state
        if (!_systemStateBloc.state.isReadinessCheckPassed) {
          throw Exception('System not ready: ${_systemStateBloc.state.systemIssues.join(", ")}');
        }
      }

      emit(state.copyWith(
        activeRecipe: recipe,
        currentStepIndex: 0,
        executionStatus: RecipeExecutionStatus.running,
        isExecutionReady: true,
      ));

      // Execute first step
      await _executeStep(recipe.steps[0], emit);
    } catch (error) {
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
        executionStatus: RecipeExecutionStatus.error,
        isExecutionReady: false,
      ));
    }
  }

  Future<void> _executeStep(RecipeStep step, Emitter<RecipeState> emit) async {
    try {
      switch (step.type) {
        case StepType.valve:
          await _executeValveStep(step);
          break;
        case StepType.purge:
          await _executePurgeStep(step);
          break;
        case StepType.loop:
          await _executeLoopStep(step, emit);
          break;
        case StepType.setParameter:
          await _executeSetParameterStep(step);
          break;
      }
    } catch (error) {
      // Add error recovery
      final recovered = await _handleStepError(step, error, emit);
      if (!recovered) {
        _alarmBloc.add(AddAlarm(
          message: 'Unrecoverable error in recipe execution: ${error.toString()}',
          severity: AlarmSeverity.critical,
        ));
        emit(state.copyWith(
          executionStatus: RecipeExecutionStatus.error,
          error: error.toString(),
        ));
        throw error;
      }
    }
  }

  Future<void> _executeValveStep(RecipeStep step) async {
    final componentName = step.parameters['valveType'] == ValveType.valveA
        ? 'Valve 1'
        : 'Valve 2';
    final duration = step.parameters['duration'] as int;

    _systemStateBloc.add(UpdateSystemParameters({
      componentName: {'status': 1.0},
    }));

    await Future.delayed(Duration(seconds: duration));

    _systemStateBloc.add(UpdateSystemParameters({
      componentName: {'status': 0.0},
    }));
  }

    Future<void> _executePurgeStep(RecipeStep step) async {
    final duration = step.parameters['duration'] as int;
    final gasFlow = step.parameters['gasFlow'] as double? ?? 100.0;

    try {
      // Close valves
      _systemStateBloc.add(UpdateSystemParameters({
        'Valve 1': {'status': 0.0},
        'Valve 2': {'status': 0.0},
      }));

      // Set MFC to purge flow rate
      _systemStateBloc.add(UpdateSystemParameters({
        'MFC': {'flow_rate': gasFlow},
      }));

      await Future.delayed(Duration(seconds: duration));

      // Reset MFC flow rate
      _systemStateBloc.add(UpdateSystemParameters({
        'MFC': {'flow_rate': 0.0},
      }));
    } catch (error) {
      _alarmBloc.add(AddAlarm(
        message: 'Error during purge step: ${error.toString()}',
        severity: AlarmSeverity.critical,
      ));
      throw error;
    }
  }

  Future<void> _executeLoopStep(RecipeStep step, Emitter<RecipeState> emit) async {
    final iterations = step.parameters['iterations'] as int;
    final temperature = step.parameters['temperature'] as double?;
    final pressure = step.parameters['pressure'] as double?;
    final subSteps = step.subSteps;

    if (subSteps == null || subSteps.isEmpty) {
      throw Exception('Loop step has no substeps');
    }

    try {
      // Set chamber parameters if specified
      if (temperature != null || pressure != null) {
        final updates = <String, Map<String, double>>{};

        if (temperature != null) {
          updates['Reaction Chamber'] = {'temperature': temperature};
          await _waitForTemperatureStabilization('Reaction Chamber', temperature);
        }

        if (pressure != null) {
          updates['Pressure Control System'] = {'pressure': pressure};
          await _waitForPressureStabilization(pressure);
        }

        if (updates.isNotEmpty) {
          _systemStateBloc.add(UpdateSystemParameters(updates));
        }
      }

      // Execute loop iterations
      for (int i = 0; i < iterations; i++) {
        if (state.executionStatus != RecipeExecutionStatus.running) {
          break;
        }

        emit(state.copyWith(
          currentStepIndex: state.currentStepIndex,
          executionStatus: RecipeExecutionStatus.running,
        ));

        for (final subStep in subSteps) {
          await _executeStep(subStep, emit);
        }
      }
    } catch (error) {
      _alarmBloc.add(AddAlarm(
        message: 'Error in loop execution: ${error.toString()}',
        severity: AlarmSeverity.critical,
      ));
      throw error;
    }
  }

  Future<void> _executeSetParameterStep(RecipeStep step) async {
    final componentName = step.parameters['component'] as String;
    final parameter = step.parameters['parameter'] as String;
    final value = step.parameters['value'] as double;

    try {
      _systemStateBloc.add(UpdateSystemParameters({
        componentName: {parameter: value},
      }));

      // Wait for parameter to stabilize
      await _waitForParameterStabilization(
        componentName,
        parameter,
        value,
      );
    } catch (error) {
      _alarmBloc.add(AddAlarm(
        message: 'Error setting parameter $parameter for $componentName: ${error.toString()}',
        severity: AlarmSeverity.critical,
      ));
      throw error;
    }
  }

  // Helper methods for parameter stabilization
  Future<void> _waitForTemperatureStabilization(
    String componentName,
    double targetTemperature,
  ) async {
    const tolerance = 2.0; // °C
    const timeout = Duration(minutes: 5);
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      final currentTemp = _getCurrentValue(componentName, 'temperature');
      if ((currentTemp - targetTemperature).abs() <= tolerance) {
        return;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    throw Exception('Temperature stabilization timeout');
  }

  Future<void> _waitForPressureStabilization(double targetPressure) async {
    const tolerance = 0.05; // atm
    const timeout = Duration(minutes: 2);
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      final currentPressure = _getCurrentValue('Pressure Control System', 'pressure');
      if ((currentPressure - targetPressure).abs() <= tolerance) {
        return;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    throw Exception('Pressure stabilization timeout');
  }

  Future<void> _waitForParameterStabilization(
    String componentName,
    String parameter,
    double targetValue,
  ) async {
    final tolerance = _getToleranceForParameter(parameter);
    const timeout = Duration(minutes: 2);
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      final currentValue = _getCurrentValue(componentName, parameter);
      if ((currentValue - targetValue).abs() <= tolerance) {
        return;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    throw Exception('Parameter stabilization timeout: $parameter');
  }

  double _getToleranceForParameter(String parameter) {
    switch (parameter) {
      case 'temperature': return 2.0;
      case 'pressure': return 0.05;
      case 'flow_rate': return 1.0;
      default: return 0.1;
    }
  }

  double _getCurrentValue(String componentName, String parameter) {
    // Get current value from system state
    final components = _systemStateBloc.state.currentSystemState['components']
        as Map<String, dynamic>?;

    if (components == null) {
      throw Exception('No components found in system state');
    }

    final component = components[componentName] as Map<String, dynamic>?;
    if (component == null) {
      throw Exception('Component not found: $componentName');
    }

    final currentValues = component['currentValues'] as Map<String, dynamic>?;
    if (currentValues == null) {
      throw Exception('No current values for component: $componentName');
    }

    final value = currentValues[parameter] as double?;
    if (value == null) {
      throw Exception('Parameter not found: $parameter');
    }

    return value;
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    _executionTimer?.cancel();
    return super.close();
  }
  Future<void> _onAddRecipe(
    AddRecipe event,
    Emitter<RecipeState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final userId = _currentUserId;
      if (userId == null) {
        emit(state.copyWith(
          error: 'User not authenticated',
          isLoading: false,
        ));
        return;
      }

      // Validate recipe before saving
      final validation = RecipeDebug.validateRecipeData(event.recipe);
      if (validation['critical']!.isNotEmpty) {
        throw Exception('Invalid recipe:\n${validation['critical']!.join('\n')}');
      }

      // Log warnings if any
      if (validation['warnings']!.isNotEmpty) {
        print('Recipe warnings:\n${validation['warnings']!.join('\n')}');
      }

      // Print recipe debug information
      print('Adding recipe:\n${RecipeDebug.prettyPrintRecipe(event.recipe)}');

      await _repository.add(event.recipe.id, event.recipe, userId: userId);

      final updatedRecipes = [...state.recipes, event.recipe];
      emit(state.copyWith(
        recipes: updatedRecipes,
        isLoading: false,
      ));

      print('Recipe added successfully');
    } catch (error) {
      print('Error adding recipe: $error');
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
        isLoading: false,
      ));
    }
  }

  Future<void> _onUpdateRecipe(
    UpdateRecipe event,
    Emitter<RecipeState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final userId = _currentUserId;
      if (userId == null) {
        emit(state.copyWith(
          error: 'User not authenticated',
          isLoading: false,
        ));
        return;
      }

      await _repository.update(event.recipe.id, event.recipe, userId: userId);

      final updatedRecipes = state.recipes.map((recipe) =>
        recipe.id == event.recipe.id ? event.recipe : recipe
      ).toList();

      emit(state.copyWith(
        recipes: updatedRecipes,
        isLoading: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
        isLoading: false,
      ));
    }
  }

  Future<void> _onDeleteRecipe(
    DeleteRecipe event,
    Emitter<RecipeState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final userId = _currentUserId;
      if (userId == null) {
        emit(state.copyWith(
          error: 'User not authenticated',
          isLoading: false,
        ));
        return;
      }

      await _repository.delete(event.recipeId, userId: userId);

      final updatedRecipes = state.recipes
          .where((recipe) => recipe.id != event.recipeId)
          .toList();

      emit(state.copyWith(
        recipes: updatedRecipes,
        isLoading: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
        isLoading: false,
      ));
    }
  }

  Future<void> _onPauseRecipeExecution(
    PauseRecipeExecution event,
    Emitter<RecipeState> emit,
  ) async {
    if (state.executionStatus != RecipeExecutionStatus.running) {
      return;
    }

    _executionTimer?.cancel();
    emit(state.copyWith(
      executionStatus: RecipeExecutionStatus.paused,
    ));
  }

  Future<void> _onResumeRecipeExecution(
    ResumeRecipeExecution event,
    Emitter<RecipeState> emit,
  ) async {
    if (state.executionStatus != RecipeExecutionStatus.paused) {
      return;
    }

    emit(state.copyWith(
      executionStatus: RecipeExecutionStatus.running,
    ));

    if (state.activeRecipe != null) {
      await _executeStep(
        state.activeRecipe!.steps[state.currentStepIndex],
        emit,
      );
    }
  }

  Future<void> _onStopRecipeExecution(
    StopRecipeExecution event,
    Emitter<RecipeState> emit,
  ) async {
    try {
      _executionTimer?.cancel();
      _executionTimer = null;

      _systemStateBloc.add(StopSystem());

      emit(RecipeState.initial()); // Reset to initial state instead of using copyWith
    } catch (error) {
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
      ));
    }
  }

  Future<void> _onRecipeStepCompleted(
    RecipeStepCompleted event,
    Emitter<RecipeState> emit,
  ) async {
    if (state.activeRecipe == null ||
        state.executionStatus != RecipeExecutionStatus.running) {
      return;
    }

    final nextStepIndex = event.stepIndex + 1;
    if (nextStepIndex >= state.activeRecipe!.steps.length) {
      // Recipe completed
      emit(state.copyWith(
        executionStatus: RecipeExecutionStatus.completed,
        currentStepIndex: 0,
      ));
      _systemStateBloc.add(StopSystem());
      return;
    }

    emit(state.copyWith(currentStepIndex: nextStepIndex));
    await _executeStep(
      state.activeRecipe!.steps[nextStepIndex],
      emit,
    );
  }

  Future<void> _onLoadRecipeVersions(
    LoadRecipeVersions event,
    Emitter<RecipeState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final userId = _currentUserId;
      if (userId == null) {
        emit(state.copyWith(
          error: 'User not authenticated',
          isLoading: false,
        ));
        return;
      }

      final versions = await _repository.getAll(userId: userId);
      final recipeVersions = versions
          .where((recipe) => recipe.id == event.recipeId)
          .toList()
        ..sort((a, b) => b.version.compareTo(a.version));

      emit(state.copyWith(
        recipeVersions: {
          ...state.recipeVersions,
          event.recipeId: recipeVersions,
        },
        isLoading: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
        isLoading: false,
      ));
    }
  }

  Future<void> _onCompareRecipeVersions(
    CompareRecipeVersions event,
    Emitter<RecipeState> emit,
  ) async {
    try {
      final versions = state.recipeVersions[event.recipeId] ?? [];
      final versionA = versions.firstWhere((r) => r.version == event.versionA);
      final versionB = versions.firstWhere((r) => r.version == event.versionB);

      final comparison = _compareRecipes(versionA, versionB);

      emit(state.copyWith(
        versionComparison: comparison,
      ));
    } catch (error) {
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
      ));
    }
  }

  Map<String, dynamic> _compareRecipes(Recipe oldVersion, Recipe newVersion) {
    final differences = <String, dynamic>{};

    if (oldVersion.name != newVersion.name) {
      differences['name'] = {
        'old': oldVersion.name,
        'new': newVersion.name,
      };
    }

    if (oldVersion.substrate != newVersion.substrate) {
      differences['substrate'] = {
        'old': oldVersion.substrate,
        'new': newVersion.substrate,
      };
    }

    differences['steps'] = _compareSteps(oldVersion.steps, newVersion.steps);
    return differences;
  }

  List<Map<String, dynamic>> _compareSteps(
    List<RecipeStep> oldSteps,
    List<RecipeStep> newSteps,
  ) {
    final differences = <Map<String, dynamic>>[];
    final maxLength = oldSteps.length > newSteps.length
        ? oldSteps.length
        : newSteps.length;

    for (var i = 0; i < maxLength; i++) {
      if (i < oldSteps.length && i < newSteps.length) {
        if (!_areStepsEqual(oldSteps[i], newSteps[i])) {
          differences.add({
            'index': i,
            'old': _stepToString(oldSteps[i]),
            'new': _stepToString(newSteps[i]),
          });
        }
      } else if (i < oldSteps.length) {
        differences.add({
          'index': i,
          'old': _stepToString(oldSteps[i]),
          'new': null,
        });
      } else {
        differences.add({
          'index': i,
          'old': null,
          'new': _stepToString(newSteps[i]),
        });
      }
    }

    return differences;
  }

  bool _areStepsEqual(RecipeStep step1, RecipeStep step2) {
    return step1.type == step2.type &&
           _areParametersEqual(step1.parameters, step2.parameters);
  }

  bool _areParametersEqual(
    Map<String, dynamic> params1,
    Map<String, dynamic> params2,
  ) {
    return params1.length == params2.length &&
           params1.entries.every((entry) =>
             params2.containsKey(entry.key) &&
             params2[entry.key] == entry.value);
  }

  String _stepToString(RecipeStep step) {
    switch (step.type) {
      case StepType.loop:
        return 'Loop ${step.parameters['iterations']} times';
      case StepType.valve:
        return '${step.parameters['valveType'] == ValveType.valveA ? 'Valve A' : 'Valve B'} '
               'for ${step.parameters['duration']}s';
      case StepType.purge:
        return 'Purge for ${step.parameters['duration']}s';
      case StepType.setParameter:
        return 'Set ${step.parameters['component']} ${step.parameters['parameter']} '
               'to ${step.parameters['value']}';
    }
  }
}