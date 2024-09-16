// lib/repositories/base_repository.dart

import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseRepository<T> {
  final String boxName;
  final String collectionName;

  BaseRepository(this.boxName, this.collectionName);

  Box<T> get _box => Hive.box<T>(boxName);
  CollectionReference get _collection => FirebaseFirestore.instance.collection(collectionName);

  Future<void> add(String id, T item) async {
    await _box.put(id, item);
    await _collection.doc(id).set((item as dynamic).toJson());
  }

  Future<T?> get(String id) async {
    T? localItem = _box.get(id);
    if (localItem == null) {
      DocumentSnapshot doc = await _collection.doc(id).get();
      if (doc.exists) {
        localItem = fromJson(doc.data() as Map<String, dynamic>);
        await _box.put(id, localItem as T);
      }
    }
    return localItem;
  }

  Future<void> update(String id, T item) async {
    await _box.put(id, item);
    await _collection.doc(id).update((item as dynamic).toJson());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    await _collection.doc(id).delete();
  }

  Future<List<T>> getAll() async {
    QuerySnapshot querySnapshot = await _collection.get();
    List<T> items = querySnapshot.docs.map((doc) => fromJson(doc.data() as Map<String, dynamic>)).toList();
    for (var item in items) {
      await _box.put((item as dynamic).id, item);
    }
    return items;
  }

  T fromJson(Map<String, dynamic> json);
}