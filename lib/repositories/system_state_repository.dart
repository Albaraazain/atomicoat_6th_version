// lib/repositories/system_state_repository.dart

import 'package:hive/hive.dart';
import '../modules/system_operation_also_main_module/models/safety_error.dart';
import '../modules/system_operation_also_main_module/models/system_component.dart';
import '../modules/system_operation_also_main_module/models/system_log_entry.dart';

class SystemStateRepository {
  final Box<SystemComponent> _componentsBox = Hive.box<SystemComponent>('system_components');
  final Box<SystemLogEntry> _logBox = Hive.box<SystemLogEntry>('system_logs');
  final Box<SafetyError> _safetyErrorBox = Hive.box<SafetyError>('safety_errors');

  // Fetch all system components
  Future<List<SystemComponent>> getAllComponents() async {
    return _componentsBox.values.toList();
  }

  // Add or update a system component
  Future<void> saveComponent(SystemComponent component) async {
    await _componentsBox.put(component.name, component);
  }

  // Fetch a single system component by name
  Future<SystemComponent?> getComponentByName(String name) async {
    return _componentsBox.get(name);
  }

  // Fetch all system log entries
  Future<List<SystemLogEntry>> getAllLogs() async {
    return _logBox.values.toList();
  }

  // Add a log entry
  Future<void> addLogEntry(SystemLogEntry logEntry) async {
    await _logBox.add(logEntry);
  }

  // Fetch all safety errors
  Future<List<SafetyError>> getAllSafetyErrors() async {
    return _safetyErrorBox.values.toList();
  }

  // Add or update a safety error
  Future<void> saveSafetyError(SafetyError safetyError) async {
    await _safetyErrorBox.put(safetyError.id, safetyError);
  }

  // Remove a safety error by ID
  Future<void> removeSafetyError(String id) async {
    await _safetyErrorBox.delete(id);
  }
}
