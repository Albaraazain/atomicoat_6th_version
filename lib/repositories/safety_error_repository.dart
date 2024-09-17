// lib/repositories/safety_error_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../modules/system_operation_also_main_module/models/safety_error.dart';

class SafetyErrorRepository {
  final CollectionReference _safetyErrorsCollection = FirebaseFirestore.instance.collection('safety_errors');

  Future<List<SafetyError>> getAll() async {
    QuerySnapshot snapshot = await _safetyErrorsCollection.get();
    return snapshot.docs.map((doc) => SafetyError.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> add(String id, SafetyError safetyError) async {
    await _safetyErrorsCollection.doc(id).set(safetyError.toJson());
  }

  Future<void> update(String id, SafetyError safetyError) async {
    await _safetyErrorsCollection.doc(id).update(safetyError.toJson());
  }

  Future<void> delete(String id) async {
    await _safetyErrorsCollection.doc(id).delete();
  }

  Future<SafetyError?> getById(String id) async {
    DocumentSnapshot doc = await _safetyErrorsCollection.doc(id).get();
    if (doc.exists) {
      return SafetyError.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }
}