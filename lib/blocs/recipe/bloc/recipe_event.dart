// lib/blocs/recipe/bloc/recipe_event.dart
import 'package:experiment_planner/blocs/base/base_bloc_event.dart';

import '../../../../modules/system_operation_also_main_module/models/recipe.dart';

sealed class RecipeEvent extends BaseBlocEvent {
  RecipeEvent() : super();
}

// Management Events
class LoadRecipes extends RecipeEvent {}

class AddRecipe extends RecipeEvent {
  final Recipe recipe;
  AddRecipe(this.recipe);
}

class UpdateRecipe extends RecipeEvent {
  final Recipe recipe;
  UpdateRecipe(this.recipe);
}

class DeleteRecipe extends RecipeEvent {
  final String recipeId;
  DeleteRecipe(this.recipeId);
}

// Execution Events
class StartRecipeExecution extends RecipeEvent {
  final String recipeId;
  StartRecipeExecution(this.recipeId);
}

class PauseRecipeExecution extends RecipeEvent {}

class ResumeRecipeExecution extends RecipeEvent {}

class StopRecipeExecution extends RecipeEvent {}

class RecipeStepCompleted extends RecipeEvent {
  final int stepIndex;
  RecipeStepCompleted(this.stepIndex);
}

// Version Control Events
class LoadRecipeVersions extends RecipeEvent {
  final String recipeId;
  LoadRecipeVersions(this.recipeId);
}

class CompareRecipeVersions extends RecipeEvent {
  final String recipeId;
  final int versionA;
  final int versionB;

  CompareRecipeVersions({
    required this.recipeId,
    required this.versionA,
    required this.versionB,
  });
}