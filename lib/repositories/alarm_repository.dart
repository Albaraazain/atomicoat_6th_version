import 'package:cloud_firestore/cloud_firestore.dart';

import '../modules/system_operation_also_main_module/models/alarm.dart';
import 'base_repository.dart';

class AlarmRepository extends BaseRepository<Alarm> {
  AlarmRepository() : super('alarms');

  Future<void> remove(String alarmId) async {
    await delete(alarmId);
  }

  Future<void> clearAcknowledged() async {
    QuerySnapshot acknowledgedAlarms = await collection
        .where('acknowledged', isEqualTo: true)
        .get();

    for (var doc in acknowledgedAlarms.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Alarm fromJson(Map<String, dynamic> json) => Alarm.fromJson(json);
}