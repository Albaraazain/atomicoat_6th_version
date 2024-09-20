// lib/repositories/safety_error_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../modules/system_operation_also_main_module/models/safety_error.dart';
import 'base_repository.dart';

class SafetyErrorRepository extends BaseRepository<SafetyError> {
  SafetyErrorRepository() : super('safety_errors');

  @override
  Future<List<SafetyError>> getAll({String? userId}) async {
    return await super.getAll(userId: userId);
  }

  @override
  Future<void> add(String id, SafetyError safetyError, {String? userId}) async {
    await super.add(id, safetyError, userId: userId);
  }

  @override
  Future<void> update(String id, SafetyError safetyError, {String? userId}) async {
    await super.update(id, safetyError, userId: userId);
  }

  @override
  Future<void> delete(String id, {String? userId}) async {
    await super.delete(id, userId: userId);
  }

  Future<SafetyError?> getById(String id, {String? userId}) async {
    return await super.get(id, userId: userId);
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