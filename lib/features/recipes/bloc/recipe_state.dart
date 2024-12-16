
import 'package:experiment_planner/blocs/base/base_bloc_state.dart';

import '../models/recipe.dart';

enum RecipeExecutionStatus {
  idle,
  running,
  paused,
  completed,
  error
}

class RecipeState extends BaseBlocState {
  final List<Recipe> recipes;
  final Recipe? activeRecipe;
  final int currentStepIndex;
  final RecipeExecutionStatus executionStatus;
  final Map<String, List<Recipe>> recipeVersions;
  final Map<String, dynamic>? versionComparison;
  final bool isExecutionReady;

  RecipeState({
    required super.isLoading,
    super.error,
    super.lastUpdated,
    required this.recipes,
    this.activeRecipe,
    this.currentStepIndex = 0,
    this.executionStatus = RecipeExecutionStatus.idle,
    this.recipeVersions = const {},
    this.versionComparison,
    this.isExecutionReady = false,
  });

  factory RecipeState.initial() {
    return RecipeState(
      isLoading: false,
      recipes: const [],
    );
  }

  RecipeState copyWith({
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
    List<Recipe>? recipes,
    Recipe? activeRecipe,
    int? currentStepIndex,
    RecipeExecutionStatus? executionStatus,
    Map<String, List<Recipe>>? recipeVersions,
    Map<String, dynamic>? versionComparison,
    bool? isExecutionReady,
  }) {
    return RecipeState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      recipes: recipes ?? this.recipes,
      activeRecipe: activeRecipe ?? this.activeRecipe,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      executionStatus: executionStatus ?? this.executionStatus,
      recipeVersions: recipeVersions ?? this.recipeVersions,
      versionComparison: versionComparison ?? this.versionComparison,
      isExecutionReady: isExecutionReady ?? this.isExecutionReady,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    recipes,
    activeRecipe,
    currentStepIndex,
    executionStatus,
    recipeVersions,
    versionComparison,
    isExecutionReady,
  ];
}