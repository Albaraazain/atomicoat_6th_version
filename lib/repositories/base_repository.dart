import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseRepository<T> {
  final String collectionName;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BaseRepository(this.collectionName);

  CollectionReference get collection => _firestore.collection(collectionName);

  Future<void> add(String id, T item) async {
    await collection.doc(id).set((item as dynamic).toJson());
  }

  Future<T?> get(String id) async {
    DocumentSnapshot doc = await collection.doc(id).get();
    if (doc.exists) {
      return fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> update(String id, T item) async {
    await collection.doc(id).update((item as dynamic).toJson());
  }

  Future<void> delete(String id) async {
    await collection.doc(id).delete();
  }

  Future<List<T>> getAll() async {
    QuerySnapshot querySnapshot = await collection.get();
    return querySnapshot.docs
        .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  T fromJson(Map<String, dynamic> json);
}