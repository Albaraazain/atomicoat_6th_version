// This file contains the base repository class that will be used to create repositories for different models.
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseRepository<T> {
  final String collectionName;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BaseRepository(this.collectionName);

  // Get the collection reference for the collection name provided in the constructor of the repository. for example, if the collection name is 'users', the collection reference will be 'users'.
  CollectionReference getCollection() => _firestore.collection(collectionName);

  CollectionReference getUserCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection(collectionName);

  Future<void> add(String id, T item, {String? userId}) async {
    if (userId != null) {
      await getUserCollection(userId).doc(id).set((item as dynamic).toJson());
    } else {
      await getCollection().doc(id).set((item as dynamic).toJson());
    }
  }

  Future<T?> get(String id, {String? userId}) async {
    DocumentSnapshot doc = userId != null
        ? await getUserCollection(userId).doc(id).get()
        : await getCollection().doc(id).get();
    if (doc.exists) {
      return fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> update(String id, T item, {String? userId}) async {
    if (userId != null) {
      await getUserCollection(userId).doc(id).update((item as dynamic).toJson());
    } else {
      await getCollection().doc(id).update((item as dynamic).toJson());
    }
  }

  Future<void> delete(String id, {String? userId}) async {
    if (userId != null) {
      await getUserCollection(userId).doc(id).delete();
    } else {
      await getCollection().doc(id).delete();
    }
  }

  Future<List<T>> getAll({String? userId}) async {
    QuerySnapshot querySnapshot = userId != null
        ? await getUserCollection(userId).get()
        : await getCollection().get();
    return querySnapshot.docs
        .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  T fromJson(Map<String, dynamic> json);
}