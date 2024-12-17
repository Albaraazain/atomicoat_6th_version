// lib/features/system/repositories/user_system_state_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:experiment_planner/shared/base/base_repository.dart';
import '../models/system_state_data.dart';
import '../../components/models/system_component.dart';
import '../../log/models/system_log_entry.dart';

class UserSystemStateRepository extends BaseRepository<SystemStateData> {
  UserSystemStateRepository() : super('system_states');

  @override
  SystemStateData fromJson(Map<String, dynamic> json) => SystemStateData.fromJson(json);

  Future<void> saveComponentState(
    SystemComponent component,
    {required String userId}
  ) async {
    final collection = getUserCollection(userId).doc('components');

    await collection.set({
      component.name: {
        ...component.toJson(),
        'timestamp': FieldValue.serverTimestamp(),
      }
    }, SetOptions(merge: true));

    // Save history
    await collection
        .collection('history')
        .add({
          'componentId': component.name,
          'timestamp': FieldValue.serverTimestamp(),
          'currentValues': component.currentValues,
          'setValues': component.setValues,
          'isActivated': component.isActivated,
        });
  }

  Future<void> saveSystemState(SystemStateData state, {required String userId}) async {
    try {
      await getUserCollection(userId).doc(state.id).set(state.toJson());
    } catch (e) {
      throw Exception('Failed to save system state: ${e.toString()}');
    }
  }

  Future<List<SystemComponent>> getAllComponents({required String userId}) async {
    final doc = await getUserCollection(userId).doc('components').get();
    if (!doc.exists) return [];

    final data = doc.data() as Map<String, dynamic>;
    return data.entries.map((entry) =>
      SystemComponent.fromJson({
        ...entry.value as Map<String, dynamic>,
        'name': entry.key,
      })
    ).toList();
  }

  Future<SystemComponent?> getComponentByName(
    String name,
    {required String userId}
  ) async {
    final doc = await getUserCollection(userId).doc('components').get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;
    final componentData = data[name] as Map<String, dynamic>?;
    if (componentData == null) return null;

    return SystemComponent.fromJson({
      ...componentData,
      'name': name,
    });
  }

  Future<List<Map<String, dynamic>>> getComponentHistory(
    String componentName,
    DateTime start,
    DateTime end,
    {required String userId}
  ) async {
    final snapshot = await getUserCollection(userId)
        .doc('components')
        .collection('history')
        .where('componentId', isEqualTo: componentName)
        .where('timestamp', isGreaterThanOrEqualTo: start)
        .where('timestamp', isLessThanOrEqualTo: end)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => doc.data())
        .toList();
  }

  Future<void> addLogEntry(
    SystemLogEntry logEntry,
    {required String userId}
  ) async {
    await getUserCollection(userId)
        .doc('logs')
        .collection('entries')
        .add(logEntry.toJson());
  }

  Future<List<SystemLogEntry>> getSystemLogs({
    required String userId,
    int limit = 100
  }) async {
    final snapshot = await getUserCollection(userId)
        .doc('logs')
        .collection('entries')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => SystemLogEntry.fromJson(doc.data()))
        .toList();
  }
}