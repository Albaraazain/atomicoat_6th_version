// lib/blocs/alarm/repository/alarm_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../modules/system_operation_also_main_module/models/alarm.dart';
import '../../base/base_repository.dart';
import '../../utils/bloc_exception.dart';

class AlarmRepository extends BlocRepository<Alarm> {
  AlarmRepository({
    FirebaseFirestore? firestore,
    String? userId,
  }) : super(
          collectionName: 'alarms',
          firestore: firestore,
          userId: userId,
        );

  @override
  Alarm fromJson(Map<String, dynamic> json) => Alarm.fromJson(json);

  @override
  Map<String, dynamic> toJson(Alarm alarm) => alarm.toJson();

  Future<List<Alarm>> getActiveAlarms() async {
    try {
      final snapshot = await userCollection
          .where('acknowledged', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw BlocException('Failed to get active alarms: $e');
    }
  }

  Future<List<Alarm>> getAcknowledgedAlarms() async {
    try {
      final snapshot = await userCollection
          .where('acknowledged', isEqualTo: true)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw BlocException('Failed to get acknowledged alarms: $e');
    }
  }

  Future<void> addAlarm(Alarm alarm) async {
    try {
      await save(alarm.id, toJson(alarm));
    } catch (e) {
      throw BlocException('Failed to add alarm: $e');
    }
  }

  Future<void> acknowledgeAlarm(String alarmId) async {
    try {
      await userCollection.doc(alarmId).update({'acknowledged': true});
    } catch (e) {
      throw BlocException('Failed to acknowledge alarm: $e');
    }
  }

  Future<void> clearAlarm(String alarmId) async {
    try {
      await userCollection.doc(alarmId).delete();
    } catch (e) {
      throw BlocException('Failed to clear alarm: $e');
    }
  }

  Future<void> clearAllAcknowledgedAlarms() async {
    try {
      final batch = userCollection.firestore.batch();
      final snapshots = await userCollection
          .where('acknowledged', isEqualTo: true)
          .get();

      for (var doc in snapshots.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw BlocException('Failed to clear acknowledged alarms: $e');
    }
  }

  Stream<List<Alarm>> watchAlarms() {
    return userCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }
}