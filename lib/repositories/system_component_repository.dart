// lib/repositories/system_component_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../modules/system_operation_also_main_module/models/system_component.dart';
import 'base_repository.dart';

class SystemComponentRepository extends BaseRepository<SystemComponent> {
  SystemComponentRepository() : super('system_components');

  @override
  Future<List<SystemComponent>> getAll({String? userId}) async {
    return await super.getAll(userId: userId);
  }

  @override
  Future<void> add(String id, SystemComponent component, {String? userId}) async {
    await super.add(id, component, userId: userId);
  }

  @override
  Future<void> update(String id, SystemComponent component, {String? userId}) async {
    await super.update(id, component, userId: userId);
  }

  @override
  Future<void> delete(String id, {String? userId}) async {
    await super.delete(id, userId: userId);
  }

  Future<SystemComponent?> getById(String id, {String? userId}) async {
    return await super.get(id, userId: userId);
  }

  Future<void> updateComponentState(String id, Map<String, double> newState, {required String userId}) async {
    await getUserCollection(userId).doc(id).update({'currentValues': newState});
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