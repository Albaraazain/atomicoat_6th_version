// lib/blocs/base/base_repository.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Base repository class that provides common Firestore operations
abstract class BlocRepository<T> {
  final String collectionName;
  final FirebaseFirestore _firestore;
  final String? userId;

  BlocRepository({
    required this.collectionName,
    FirebaseFirestore? firestore,
    this.userId,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get userCollection =>
    userId != null
      ? _firestore.collection('users').doc(userId).collection(collectionName)
      : _firestore.collection(collectionName);

  /// Save an item to Firestore
  Future<void> save(String id, Map<String, dynamic> data) async {
    await userCollection.doc(id).set(
      {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Get an item from Firestore
  Future<Map<String, dynamic>?> get(String id) async {
    final doc = await userCollection.doc(id).get();
    return doc.exists ? doc.data() as Map<String, dynamic> : null;
  }

  /// Listen to real-time updates for an item
  Stream<T?> watch(String id) {
    return userCollection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return fromJson(doc.data() as Map<String, dynamic>);
    });
  }

  /// Convert Firestore data to model object
  T fromJson(Map<String, dynamic> json);

  /// Convert model object to Firestore data
  Map<String, dynamic> toJson(T item);
}