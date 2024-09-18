// lib/repositories/recipe_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../modules/system_operation_also_main_module/models/recipe.dart';
import 'base_repository.dart';

class RecipeRepository extends BaseRepository<Recipe> {
  RecipeRepository() : super('recipes');

  Future<List<Recipe>> getAll(String userId) async {
    return await super.getAll(userId);
  }

  Future<void> add(String userId, String id, Recipe recipe) async {
    await super.add(userId, id, recipe);
  }

  Future<void> update(String userId, String id, Recipe recipe) async {
    await super.update(userId, id, recipe);
  }

  Future<void> delete(String userId, String id) async {
    await super.delete(userId, id);
  }

  Future<Recipe?> getById(String userId, String id) async {
    return await super.get(userId, id);
  }

  @override
  Recipe fromJson(Map<String, dynamic> json) => Recipe.fromJson(json);
}