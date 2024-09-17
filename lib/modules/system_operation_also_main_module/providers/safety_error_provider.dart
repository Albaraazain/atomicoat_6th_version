// lib/modules/system_operation_also_main_module/providers/safety_error_provider.dart

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

  Future<void> loadRecipes() async {
    try {
      _recipes = await _recipeRepository.getAll();
      notifyListeners();
    } catch (e) {
      print('Error loading recipes: $e');
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    try {
      await _recipeRepository.add(recipe.id, recipe);
      _recipes.add(recipe);
      notifyListeners();
    } catch (e) {
      print('Error adding recipe: $e');
      rethrow; // Rethrow the error so it can be handled in the UI
    }
  }

  Future<void> updateRecipe(Recipe updatedRecipe) async {
    try {
      await _recipeRepository.update(updatedRecipe.id, updatedRecipe);
      int index = _recipes.indexWhere((recipe) => recipe.id == updatedRecipe.id);
      if (index != -1) {
        _recipes[index] = updatedRecipe;
        notifyListeners();
      } else {
        throw Exception('Recipe not found for update');
      }
    } catch (e) {
      print('Error updating recipe: $e');
      rethrow;
    }
  }

  Future<void> deleteRecipe(String id) async {
    try {
      await _recipeRepository.delete(id);
      _recipes.removeWhere((recipe) => recipe.id == id);
      notifyListeners();
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

}