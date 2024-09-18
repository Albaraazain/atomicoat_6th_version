import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseRepository<T> {
  final String collectionName;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BaseRepository(this.collectionName);


  CollectionReference getUserCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection(collectionName);

  Future<void> add(String userId, String id, T item) async {
    await getUserCollection(userId).doc(id).set((item as dynamic).toJson());
  }


  Future<T?> get(String userId, String id) async {
    DocumentSnapshot doc = await getUserCollection(userId).doc(id).get();
    if (doc.exists) {
      return fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> update(String userId, String id, T item) async {
    await getUserCollection(userId).doc(id).update((item as dynamic).toJson());
  }

  Future<void> delete(String userId, String id) async {
    await getUserCollection(userId).doc(id).delete();
  }

  Future<List<T>> getAll(String userId) async {
    QuerySnapshot querySnapshot = await getUserCollection(userId).get();
    return querySnapshot.docs
        .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  T fromJson(Map<String, dynamic> json);
}