// lib/repositories/recipe_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../modules/system_operation_also_main_module/models/recipe.dart';

class RecipeRepository {
  final CollectionReference _recipesCollection = FirebaseFirestore.instance.collection('recipes');

  Future<List<Recipe>> getAll() async {
    QuerySnapshot snapshot = await _recipesCollection.get();
    return snapshot.docs.map((doc) => Recipe.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> add(String id, Recipe recipe) async {
    await _recipesCollection.doc(id).set(recipe.toJson());
  }

  Future<void> update(String id, Recipe recipe) async {
    await _recipesCollection.doc(id).update(recipe.toJson());
  }

  Future<void> delete(String id) async {
    await _recipesCollection.doc(id).delete();
  }

  Future<Recipe?> getById(String id) async {
    DocumentSnapshot doc = await _recipesCollection.doc(id).get();
    if (doc.exists) {
      return Recipe.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }
}