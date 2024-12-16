import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:experiment_planner/core/exceptions/bloc_exception.dart';
import 'package:experiment_planner/features/recipes/models/recipe.dart';

class RecipeRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'recipes';

  RecipeRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Add this new method after the constructor
  Stream<List<Recipe>> watchUserRecipes(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('lastModified', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Recipe.fromJson(doc.data()))
            .toList());
  }

  // Replace existing getAll method
  Future<List<Recipe>> getAll({
    required String userId,
    String? substrate,
    DateTime? modifiedAfter,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId);

      if (substrate != null) {
        query = query.where('substrate', isEqualTo: substrate);
      }

      if (modifiedAfter != null) {
        query = query.where('lastModified',
            isGreaterThan: Timestamp.fromDate(modifiedAfter));
      }

      final querySnapshot = await query
          .orderBy('lastModified', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Recipe.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw BlocException(
        'Failed to fetch recipes: ${e.toString()}',
      );
    }
  }

  // Add a new recipe
  Future<void> add(String id, Recipe recipe, {required String userId}) async {
    try {
      final data = recipe.toJson();
      data['userId'] = userId;

      await _firestore.collection(_collection).doc(id).set(data);
    } catch (e) {
      throw BlocException(
        'Failed to add recipe: ${e.toString()}',
      );
    }
  }

  // Update an existing recipe
  Future<void> update(String id, Recipe recipe,
      {required String userId}) async {
    try {
      final docRef = _firestore.collection(_collection).doc(id);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw BlocException('Recipe not found');
      }

      final existingData = doc.data();
      if (existingData?['userId'] != userId) {
        throw BlocException('Unauthorized to update this recipe');
      }

      final data = recipe.toJson();
      data['userId'] = userId;
      data['lastModified'] = Timestamp.now();

      await docRef.update(data);
    } catch (e) {
      throw BlocException(
        'Failed to update recipe: ${e.toString()}',
      );
    }
  }

  // Delete a recipe
  Future<void> delete(String id, {required String userId}) async {
    try {
      final docRef = _firestore.collection(_collection).doc(id);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw BlocException('Recipe not found');
      }

      final data = doc.data();
      if (data?['userId'] != userId) {
        throw BlocException('Unauthorized to delete this recipe');
      }

      await docRef.delete();
    } catch (e) {
      throw BlocException(
        'Failed to delete recipe: ${e.toString()}',
      );
    }
  }

  // Get a specific recipe by ID
  Future<Recipe?> getById(String id, {required String userId}) async {
    try {
      final docSnapshot =
          await _firestore.collection(_collection).doc(id).get();

      if (!docSnapshot.exists) {
        return null;
      }

      final data = docSnapshot.data()!;
      if (data['userId'] != userId) {
        throw BlocException('Unauthorized to access this recipe');
      }

      return Recipe.fromJson(data);
    } catch (e) {
      throw BlocException(
        'Failed to fetch recipe: ${e.toString()}',
      );
    }
  }

  // Get recipes by substrate type
  Future<List<Recipe>> getBySubstrate(String substrate,
      {required String userId}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('substrate', isEqualTo: substrate)
          .orderBy('lastModified', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Recipe.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw BlocException(
        'Failed to fetch recipes by substrate: ${e.toString()}',
      );
    }
  }

  // Stream of recipe updates
  Stream<Recipe> watchRecipe(String id, {required String userId}) {
    return _firestore
        .collection(_collection)
        .doc(id)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        throw BlocException('Recipe not found');
      }

      final data = snapshot.data()!;
      if (data['userId'] != userId) {
        throw BlocException('Unauthorized to access this recipe');
      }

      return Recipe.fromJson(data);
    });
  }

  // Duplicate a recipe
  Future<void> duplicate(String sourceId, String newId, String newName,
      {required String userId}) async {
    try {
      final sourceRecipe = await getById(sourceId, userId: userId);
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
}
