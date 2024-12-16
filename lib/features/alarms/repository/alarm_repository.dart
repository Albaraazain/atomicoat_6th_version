

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/alarms/models/alarm.dart';
import '../base_repository.dart';

class AlarmRepository extends BaseRepository<Alarm> {
  AlarmRepository() : super('alarms');

  Future<void> remove(String alarmId, {String? userId}) async {
    await delete(alarmId, userId: userId);
  }

  Future<void> clearAcknowledged(String userId) async {
    QuerySnapshot acknowledgedAlarms = await getUserCollection(userId)
        .where('acknowledged', isEqualTo: true)
        .get();

    for (var doc in acknowledgedAlarms.docs) {
      await doc.reference.delete();
    }
  }

  Future<List<Alarm>> getActiveAlarms(String userId) async {
    QuerySnapshot activeAlarms = await getUserCollection(userId)
        .where('acknowledged', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .get();

    return activeAlarms.docs
        .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<List<Alarm>> watchActiveAlarms(String userId) {
    return getUserCollection(userId)
        .where('acknowledged', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> acknowledgeAlarm(String alarmId, String userId) async {
    final alarm = await get(alarmId, userId: userId);
    if (alarm != null) {
      final updatedAlarm = alarm.copyWith(acknowledged: true);
      await update(alarmId, updatedAlarm, userId: userId);
    }
  }

  @override
  Alarm fromJson(Map<String, dynamic> json) => Alarm.fromJson(json);

  Future<void> createNewAlarm({
    required String id,
    required String message,
    required AlarmSeverity severity,
    bool isSafetyAlert = false,
    String? userId,
  }) async {
    final alarm = Alarm(
      id: id,
      message: message,
      severity: severity,
      timestamp: DateTime.now(),
      acknowledged: false,
      isSafetyAlert: isSafetyAlert,
    );

    await add(id, alarm, userId: userId);
  }
}