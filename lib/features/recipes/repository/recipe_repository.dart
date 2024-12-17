import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:experiment_planner/core/exceptions/bloc_exception.dart';
import 'package:experiment_planner/features/recipes/utils/recipe_debug.dart';
import 'package:experiment_planner/shared/base/base_repository.dart';
import 'package:experiment_planner/features/recipes/models/recipe.dart';

class RecipeRepository extends BaseRepository<Recipe> {
  RecipeRepository() : super('recipes');

  @override
  Recipe fromJson(Map<String, dynamic> json) => Recipe.fromJson(json);

  Stream<List<Recipe>> watchUserRecipes(String userId) {
    return getUserCollection(userId)
        .orderBy('lastModified', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<List<Recipe>> getByFilters({
    required String userId,
    String? substrate,
    DateTime? modifiedAfter,
  }) async {
    try {
      var query = getUserCollection(userId).orderBy('lastModified', descending: true);

      if (substrate != null) {
        query = query.where('substrate', isEqualTo: substrate);
      }

      if (modifiedAfter != null) {
        query = query.where('lastModified',
            isGreaterThan: Timestamp.fromDate(modifiedAfter));
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw BlocException(
        'Failed to fetch recipes: ${e.toString()}',
      );
    }
  }

  // Modified to match base class signature
  @override
  Future<void> add(String id, Recipe recipe, {String? userId}) async {
    try {
      if (userId == null) {
        throw BlocException('UserId is required for adding recipes');
      }

      // Debug print before saving
      print('Saving recipe:\n${RecipeDebug.prettyPrintRecipe(recipe)}');

      final validation = RecipeDebug.validateRecipeData(recipe);
      if (validation['critical']!.isNotEmpty) {
        throw BlocException(
          'Recipe validation failed:\n${validation['critical']!.join('\n')}',
        );
      }

      if (validation['warnings']!.isNotEmpty) {
        print('Recipe warnings:\n${validation['warnings']!.join('\n')}');
      }

      // Convert to JSON and verify data
      final json = recipe.toJson();
      print('Recipe JSON:\n$json');

      await getUserCollection(userId).doc(id).set(json);

      // Verify save
      final savedDoc = await getUserCollection(userId).doc(id).get();
      if (!savedDoc.exists) {
        throw BlocException('Recipe was not saved properly');
      }

      final savedRecipe = Recipe.fromJson(savedDoc.data() as Map<String, dynamic>);
      print('Recipe saved and retrieved successfully:\n${RecipeDebug.prettyPrintRecipe(savedRecipe)}');
    } catch (e) {
      throw BlocException(
        'Failed to add recipe: ${e.toString()}',
      );
    }
  }

  Future<void> duplicate(
    String sourceId,
    String newId,
    String newName,
    {required String userId}
  ) async {
    try {
      final sourceRecipe = await get(sourceId, userId: userId);
      if (sourceRecipe == null) {
        throw BlocException('Source recipe not found');
      }

      final newRecipe = sourceRecipe.copyWith(
        id: newId,
        name: newName,
        version: 1,
        lastModified: DateTime.now(),
      );

      await add(newId, newRecipe, userId: userId);
    } catch (e) {
      throw BlocException(
        'Failed to duplicate recipe: ${e.toString()}',
      );
    }
  }

  Stream<Recipe> watchRecipe(String id, {required String userId}) {
    return getUserCollection(userId)
        .doc(id)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) {
            throw BlocException('Recipe not found');
          }

          return fromJson(snapshot.data() as Map<String, dynamic>);
        });
  }

  Future<List<Recipe>> getBySubstrate(
    String substrate,
    {required String userId}
  ) async {
    try {
      final snapshot = await getUserCollection(userId)
          .where('substrate', isEqualTo: substrate)
          .orderBy('lastModified', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw BlocException(
        'Failed to fetch recipes by substrate: ${e.toString()}',
      );
    }
  }
}