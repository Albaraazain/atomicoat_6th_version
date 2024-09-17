// lib/modules/system_operation_also_main_module/providers/alarm_provider.dart

import 'package:flutter/foundation.dart';
import '../../../repositories/alarm_repository.dart';
import '../models/alarm.dart';

class AlarmProvider with ChangeNotifier {
  final AlarmRepository _alarmRepository = AlarmRepository();
  List<Alarm> _activeAlarms = [];
  List<Alarm> _alarmHistory = [];

  List<Alarm> get activeAlarms => _activeAlarms;
  List<Alarm> get alarmHistory => _alarmHistory;
  List<Alarm> get criticalAlarms => _activeAlarms.where((alarm) => alarm.severity == AlarmSeverity.critical).toList();

  AlarmProvider() {
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    _alarmHistory = await _alarmRepository.getAll();
    _activeAlarms = _alarmHistory.where((alarm) => !alarm.acknowledged).toList();
    notifyListeners();
  }

  Future<void> addAlarm(Alarm alarm) async {
    await _alarmRepository.add(alarm.id, alarm);
    _activeAlarms.add(alarm);
    _alarmHistory.add(alarm);
    notifyListeners();
  }

  Future<void> addSafetyAlarm(String id, String message, AlarmSeverity severity) async {
    final newAlarm = Alarm(
      id: id,
      message: message,
      severity: severity,
      timestamp: DateTime.now(),
      isSafetyAlert: true,
    );
    await addAlarm(newAlarm);
  }

  Future<void> acknowledgeAlarm(String alarmId) async {
    final alarmIndex = _activeAlarms.indexWhere((alarm) => alarm.id == alarmId);
    if (alarmIndex != -1) {
      _activeAlarms[alarmIndex].acknowledged = true;
      await _alarmRepository.update(alarmId, _activeAlarms[alarmIndex]);
      _activeAlarms.removeAt(alarmIndex);
      notifyListeners();
    }
  }

  Future<void> clearAlarm(String alarmId) async {
    await _alarmRepository.remove(alarmId);
    _activeAlarms.removeWhere((alarm) => alarm.id == alarmId);
    _alarmHistory.removeWhere((alarm) => alarm.id == alarmId);
    notifyListeners();
  }

  Future<void> clearAllAcknowledgedAlarms() async {
    await _alarmRepository.clearAcknowledged();
    _alarmHistory.removeWhere((alarm) => alarm.acknowledged);
    notifyListeners();
  }

  List<Alarm> getAlarmsBySeverity(AlarmSeverity severity) {
    return _activeAlarms.where((alarm) => alarm.severity == severity).toList();
  }

  bool get hasActiveAlarms => _activeAlarms.isNotEmpty;

  bool get hasCriticalAlarm => _activeAlarms.any((alarm) => alarm.severity == AlarmSeverity.critical);

  List<Alarm> getRecentAlarms({int count = 5}) {
    return _alarmHistory.reversed.take(count).toList();
  }

  Future<String> exportAlarmHistory() async {
    return _alarmHistory
        .map((alarm) =>
    '${alarm.timestamp.toIso8601String()},${alarm.severity.toString().split('.').last},${alarm.message},${alarm.acknowledged}')
        .join('\n');
  }

  Future<Map<String, int>> getAlarmStatistics() async {
    return {
      'total': _alarmHistory.length,
      'critical': _alarmHistory
          .where((a) => a.severity == AlarmSeverity.critical)
          .length,
      'warning': _alarmHistory.where((a) => a.severity == AlarmSeverity.warning).length,
      'info': _alarmHistory.where((a) => a.severity == AlarmSeverity.info).length,
      'acknowledged': _alarmHistory.where((a) => a.acknowledged).length,
      'unacknowledged': _alarmHistory.where((a) => !a.acknowledged).length,
    };
  }
}