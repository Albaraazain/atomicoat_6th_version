// lib/repositories/system_component_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../modules/system_operation_also_main_module/models/system_component.dart';
import 'base_repository.dart';

class SystemComponentRepository extends BaseRepository<SystemComponent> {
  SystemComponentRepository() : super('system_components');

  Future<List<SystemComponent>> getAll(String userId) async {
    return await super.getAll(userId);
  }

  Future<void> add(String userId, String name, SystemComponent component) async {
    await super.add(userId, name, component);
  }

  Future<void> update(String userId, String name, SystemComponent component) async {
    await super.update(userId, name, component);
  }

  Future<void> delete(String userId, String name) async {
    await super.delete(userId, name);
  }

  Future<SystemComponent?> getByName(String userId, String name) async {
    return await super.get(userId, name);
  }

  Future<void> updateComponentState(String userId, String name, Map<String, double> newState) async {
    await getUserCollection(userId).doc(name).update({'currentValues': newState});
  }

  Future<List<SystemComponent>> getActiveComponents(String userId) async {
    QuerySnapshot activeComponents = await getUserCollection(userId)
        .where('isActivated', isEqualTo: true)
        .get();

    return activeComponents.docs
        .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  SystemComponent fromJson(Map<String, dynamic> json) => SystemComponent.fromJson(json);
}