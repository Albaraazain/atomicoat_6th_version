// lib/repositories/alarm_repository.dart

// a repository is basic

import 'package:hive/hive.dart';

import '../modules/system_operation_also_main_module/models/alarm.dart';
import 'base_repository.dart';

class AlarmRepository extends BaseRepository<Alarm> {
  AlarmRepository() : super('alarms', 'alarms');
  final Box<Alarm> alarmBox = Hive.box<Alarm>('alarms');


  // Method to remove an alarm by id
  Future<void> remove(String alarmId) async {
    await alarmBox.delete(alarmId);
  }

  // Method to clear all acknowledged alarms
  Future<void> clearAcknowledged() async {
    final acknowledgedAlarms = alarmBox.values.where((alarm) => alarm.acknowledged).toList();
    for (var alarm in acknowledgedAlarms) {
      await alarmBox.delete(alarm.id);
    }
  }

  @override
  Alarm fromJson(Map<String, dynamic> json) => Alarm.fromJson(json);
}