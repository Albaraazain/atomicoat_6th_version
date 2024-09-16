import 'package:flutter/foundation.dart';
import '../../../repositories/recipe_reposiory.dart';
import '../models/recipe.dart';

class RecipeProvider with ChangeNotifier {
  final RecipeRepository _recipeRepository = RecipeRepository();

  List<Recipe> _recipes = [];

  List<Recipe> get recipes => _recipes;

  RecipeProvider() {
    loadRecipes();
  }

  // Load recipes from the repository
  Future<void> loadRecipes() async {
    _recipes = await _recipeRepository.getAll();
    notifyListeners();
  }

  // Add a new recipe
  Future<void> addRecipe(Recipe recipe) async {
    await _recipeRepository.add(recipe.id, recipe);
    _recipes.add(recipe);
    notifyListeners();
  }

  // Update an existing recipe
  Future<void> updateRecipe(Recipe updatedRecipe) async {
    int index = _recipes.indexWhere((recipe) => recipe.id == updatedRecipe.id);
    if (index != -1) {
      _recipes[index] = updatedRecipe;
      await _recipeRepository.update(updatedRecipe.id, updatedRecipe);
      notifyListeners();
    } else {
      throw Exception('Recipe not found for update');
    }
  }

  // Delete a recipe
  Future<void> deleteRecipe(String id) async {
    _recipes.removeWhere((recipe) => recipe.id == id);
    await _recipeRepository.remove(id);
    notifyListeners();
  }

  // Get a specific recipe by ID
  Recipe getRecipeById(String id) {
    return _recipes.firstWhere((recipe) => recipe.id == id, orElse: () => throw Exception('Recipe not found'));
  }

  // Get all versions of a recipe by ID
  List<Recipe> getRecipeVersions(String id) {
    return _recipes.where((recipe) => recipe.id == id).toList();
  }

  // Get the previous version of a recipe
  Recipe? getPreviousVersion(String id, int currentVersion) {
    List<Recipe> versions = getRecipeVersions(id);
    versions.sort((a, b) => b.version.compareTo(a.version));
    int index = versions.indexWhere((recipe) => recipe.version == currentVersion);
    if (index > 0 && index < versions.length) {
      return versions[index + 1];
    }
    return null;
  }

  // Compare two versions of a recipe
  Map<String, dynamic> compareRecipeVersions(Recipe oldVersion, Recipe newVersion) {
    Map<String, dynamic> differences = {};

    if (oldVersion.name != newVersion.name) {
      differences['name'] = {'old': oldVersion.name, 'new': newVersion.name};
    }

    if (oldVersion.substrate != newVersion.substrate) {
      differences['substrate'] = {'old': oldVersion.substrate, 'new': newVersion.substrate};
    }

    if (oldVersion.chamberTemperatureSetPoint != newVersion.chamberTemperatureSetPoint) {
      differences['chamberTemperatureSetPoint'] = {
        'old': oldVersion.chamberTemperatureSetPoint,
        'new': newVersion.chamberTemperatureSetPoint
      };
    }

    if (oldVersion.pressureSetPoint != newVersion.pressureSetPoint) {
      differences['pressureSetPoint'] = {'old': oldVersion.pressureSetPoint, 'new': newVersion.pressureSetPoint};
    }

    differences['steps'] = _compareSteps(oldVersion.steps, newVersion.steps);

    return differences;
  }

  List<Map<String, dynamic>> _compareSteps(List<RecipeStep> oldSteps, List<RecipeStep> newSteps) {
    List<Map<String, dynamic>> stepDifferences = [];

    int maxLength = oldSteps.length > newSteps.length ? oldSteps.length : newSteps.length;

    for (int i = 0; i < maxLength; i++) {
      if (i < oldSteps.length && i < newSteps.length) {
        // Both versions have this step
        if (oldSteps[i].type != newSteps[i].type || !_areParametersEqual(oldSteps[i].parameters, newSteps[i].parameters)) {
          stepDifferences.add({
            'index': i,
            'old': _stepToString(oldSteps[i]),
            'new': _stepToString(newSteps[i]),
          });
        }
        if (oldSteps[i].type == StepType.loop && newSteps[i].type == StepType.loop) {
          var subStepDifferences = _compareSteps(oldSteps[i].subSteps ?? [], newSteps[i].subSteps ?? []);
          if (subStepDifferences.isNotEmpty) {
            stepDifferences.add({
              'index': i,
              'subSteps': subStepDifferences,
            });
          }
        }
      } else if (i < oldSteps.length) {
        // Step removed in new version
        stepDifferences.add({
          'index': i,
          'old': _stepToString(oldSteps[i]),
          'new': null,
        });
      } else {
        // Step added in new version
        stepDifferences.add({
          'index': i,
          'old': null,
          'new': _stepToString(newSteps[i]),
        });
      }
    }

    return stepDifferences;
  }

  bool _areParametersEqual(Map<String, dynamic> params1, Map<String, dynamic> params2) {
    if (params1.length != params2.length) return false;
    return params1.keys.every((key) => params1[key] == params2[key]);
  }

  String _stepToString(RecipeStep step) {
    switch (step.type) {
      case StepType.loop:
        return 'Loop ${step.parameters['iterations']} times' +
            (step.parameters['temperature'] != null ? ' (T: ${step.parameters['temperature']}°C)' : '') +
            (step.parameters['pressure'] != null ? ' (P: ${step.parameters['pressure']} atm)' : '');
      case StepType.valve:
        return '${step.parameters['valveType'] == ValveType.valveA ? 'Valve A' : 'Valve B'} for ${step.parameters['duration']}s' +
            (step.parameters['gasFlow'] != null ? ' (Flow: ${step.parameters['gasFlow']} sccm)' : '');
      case StepType.purge:
        return 'Purge for ${step.parameters['duration']}s' +
            (step.parameters['gasFlow'] != null ? ' (Flow: ${step.parameters['gasFlow']} sccm)' : '');
      case StepType.setParameter:
        return 'Set ${step.parameters['component']} ${step.parameters['parameter']} to ${step.parameters['value']}';
      default:
        return 'Unknown Step';
    }
  }
}
