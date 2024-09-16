// lib/repositories/recipe_repository.dart

import 'package:hive/hive.dart';

import '../modules/system_operation_also_main_module/models/recipe.dart';
import 'base_repository.dart';

class RecipeRepository extends BaseRepository<Recipe> {
  RecipeRepository() : super('recipes', 'recipes');
  final Box<Recipe> _recipeBox = Hive.box<Recipe>('recipes');

  Future<List<Recipe>> getAll() async {
    return _recipeBox.values.toList();
  }

  Future<void> add(String id, Recipe recipe) async {
    await _recipeBox.put(id, recipe);
  }

  Future<void> update(String id, Recipe recipe) async {
    await _recipeBox.put(id, recipe);
  }

  Future<void> remove(String id) async {
    await _recipeBox.delete(id);
  }

  @override
  Recipe fromJson(Map<String, dynamic> json) => Recipe.fromJson(json);
}