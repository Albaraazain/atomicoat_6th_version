// lib/repositories/recipe_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../modules/system_operation_also_main_module/models/recipe.dart';
import 'base_repository.dart';

class RecipeRepository extends BaseRepository<Recipe> {
  RecipeRepository() : super('recipes');

  @override
  Future<List<Recipe>> getAll({String? userId}) async {
    return await super.getAll(userId: userId);
  }

  @override
  Future<void> add(String id, Recipe recipe, {String? userId}) async {
    await super.add(id, recipe, userId: userId);
  }

  @override
  Future<void> update(String id, Recipe recipe, {String? userId}) async {
    await super.update(id, recipe, userId: userId);
  }

  @override
  Future<void> delete(String id, {String? userId}) async {
    await super.delete(id, userId: userId);
  }

  Future<Recipe?> getById(String id, {String? userId}) async {
    return await super.get(id, userId: userId);
  }

  @override
  Recipe fromJson(Map<String, dynamic> json) => Recipe.fromJson(json);
}