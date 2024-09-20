// lib/modules/system_operation_also_main_module/providers/alarm_provider.dart

import 'package:flutter/foundation.dart';
import '../../../repositories/alarm_repository.dart';
import '../models/alarm.dart';
import '../../../services/auth_service.dart';

class AlarmProvider with ChangeNotifier {
  final AlarmRepository _alarmRepository = AlarmRepository();
  final AuthService _authService;
  List<Alarm> _activeAlarms = [];
  List<Alarm> _alarmHistory = [];

  List<Alarm> get activeAlarms => _activeAlarms;
  List<Alarm> get alarmHistory => _alarmHistory;
  List<Alarm> get criticalAlarms => _activeAlarms.where((alarm) => alarm.severity == AlarmSeverity.critical).toList();

  AlarmProvider(this._authService) {
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    String? userId = _authService.currentUserId;
    if (userId != null) {
      _alarmHistory = await _alarmRepository.getAll(userId: userId);
      _activeAlarms = await _alarmRepository.getActiveAlarms(userId);
      notifyListeners();
    }
  }

  Future<void> addAlarm(Alarm alarm) async {
    String? userId = _authService.currentUserId;
    if (userId != null) {
      await _alarmRepository.add(alarm.id, alarm, userId: userId);
      _activeAlarms.add(alarm);
      _alarmHistory.add(alarm);
      notifyListeners();
    }
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
    String? userId = _authService.currentUserId;
    if (userId != null) {
      final alarmIndex = _activeAlarms.indexWhere((alarm) => alarm.id == alarmId);
      if (alarmIndex != -1) {
        final updatedAlarm = _activeAlarms[alarmIndex].copyWith(acknowledged: true);
        await _alarmRepository.update(alarmId, updatedAlarm, userId: userId);
        _activeAlarms.removeAt(alarmIndex);
        final historyIndex = _alarmHistory.indexWhere((alarm) => alarm.id == alarmId);
        if (historyIndex != -1) {
          _alarmHistory[historyIndex] = updatedAlarm;
        }
        notifyListeners();
      }
    }
  }

  Future<void> clearAlarm(String alarmId) async {
    String? userId = _authService.currentUserId;
    if (userId != null) {
      await _alarmRepository.remove(alarmId, userId: userId);
      _activeAlarms.removeWhere((alarm) => alarm.id == alarmId);
      _alarmHistory.removeWhere((alarm) => alarm.id == alarmId);
      notifyListeners();
    }
  }

  Future<void> clearAllAcknowledgedAlarms() async {
    String? userId = _authService.currentUserId;
    if (userId != null) {
      await _alarmRepository.clearAcknowledged(userId);
      _alarmHistory.removeWhere((alarm) => alarm.acknowledged);
      notifyListeners();
    }
  }

  // The following methods work on the local lists

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

  Map<String, int> getAlarmStatistics() {
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