// lib/repositories/system_component_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../modules/system_operation_also_main_module/models/system_component.dart';

class SystemComponentRepository {
  final CollectionReference _componentsCollection = FirebaseFirestore.instance.collection('system_components');

  Future<List<SystemComponent>> getAll() async {
    QuerySnapshot snapshot = await _componentsCollection.get();
    return snapshot.docs.map((doc) => SystemComponent.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> add(String name, SystemComponent component) async {
    await _componentsCollection.doc(name).set(component.toJson());
  }

  Future<void> update(String name, SystemComponent component) async {
    await _componentsCollection.doc(name).update(component.toJson());
  }

  Future<void> delete(String name) async {
    await _componentsCollection.doc(name).delete();
  }

  Future<SystemComponent?> getByName(String name) async {
    DocumentSnapshot doc = await _componentsCollection.doc(name).get();
    if (doc.exists) {
      return SystemComponent.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateComponentState(String name, Map<String, double> newState) async {
    await _componentsCollection.doc(name).update({'currentValues': newState});
  }
}