// lib/repositories/safety_error_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../modules/system_operation_also_main_module/models/safety_error.dart';
import 'base_repository.dart';

class SafetyErrorRepository extends BaseRepository<SafetyError> {
  SafetyErrorRepository() : super('safety_errors');

  Future<List<SafetyError>> getAll(String userId) async {
    return await super.getAll(userId);
  }

  Future<void> add(String userId, String id, SafetyError safetyError) async {
    await super.add(userId, id, safetyError);
  }

  Future<void> update(String userId, String id, SafetyError safetyError) async {
    await super.update(userId, id, safetyError);
  }

  Future<void> delete(String userId, String id) async {
    await super.delete(userId, id);
  }

  Future<SafetyError?> getById(String userId, String id) async {
    return await super.get(userId, id);
  }

  Future<List<SafetyError>> getActiveSafetyErrors(String userId) async {
    QuerySnapshot activeErrors = await getUserCollection(userId)
        .where('resolved', isEqualTo: false)
        .get();

    return activeErrors.docs
        .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  SafetyError fromJson(Map<String, dynamic> json) => SafetyError.fromJson(json);
}