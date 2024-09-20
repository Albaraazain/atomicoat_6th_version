// lib/modules/system_operation_also_main_module/providers/recipe_provider.dart

import 'package:flutter/foundation.dart';
import '../../../repositories/recipe_reposiory.dart';
import '../../../services/auth_service.dart';
import '../models/recipe.dart';

class RecipeProvider with ChangeNotifier {
  final RecipeRepository _recipeRepository = RecipeRepository();
  final AuthService _authService;
  List<Recipe> _recipes = [];

  List<Recipe> get recipes => _recipes;

  RecipeProvider(this._authService) {
    loadRecipes();
  }

  Future<void> loadRecipes() async {
    try {
      String? userId = _authService.currentUser?.uid;
      if (userId != null) {
        _recipes = await _recipeRepository.getAll(userId: userId);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading recipes: $e');
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    try {
      String? userId = _authService.currentUser?.uid;
      if (userId != null) {
        await _recipeRepository.add(recipe.id, recipe, userId: userId);
        _recipes.add(recipe);
        notifyListeners();
      }
    } catch (e) {
      print('Error adding recipe: $e');
      rethrow;
    }
  }

  Future<void> updateRecipe(Recipe updatedRecipe) async {
    try {
      String? userId = _authService.currentUser?.uid;
      if (userId != null) {
        await _recipeRepository.update(updatedRecipe.id, updatedRecipe, userId: userId);
        int index = _recipes.indexWhere((recipe) => recipe.id == updatedRecipe.id);
        if (index != -1) {
          _recipes[index] = updatedRecipe;
          notifyListeners();
        } else {
          throw Exception('Recipe not found for update');
        }
      }
    } catch (e) {
      print('Error updating recipe: $e');
      rethrow;
    }
  }


  Future<void> deleteRecipe(String id) async {
    try {
      String? userId = _authService.currentUser?.uid;
      if (userId != null) {
        await _recipeRepository.delete(id, userId: userId);
        _recipes.removeWhere((recipe) => recipe.id == id);
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting recipe: $e');
      rethrow;
    }
  }

  Recipe? getRecipeById(String id) {
    try {
      return _recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      print('Recipe not found: $e');
      return null;
    }
  }



  List<Recipe> getRecipeVersions(String id) {
    return _recipes.where((recipe) => recipe.id == id).toList();
  }

  Recipe? getPreviousVersion(String id, int currentVersion) {
    List<Recipe> versions = getRecipeVersions(id);
    versions.sort((a, b) => b.version.compareTo(a.version));
    int index = versions.indexWhere((recipe) => recipe.version == currentVersion);
    if (index > 0 && index < versions.length) {
      return versions[index + 1];
    }
    return null;
  }

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
        stepDifferences.add({
          'index': i,
          'old': _stepToString(oldSteps[i]),
          'new': null,
        });
      } else {
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