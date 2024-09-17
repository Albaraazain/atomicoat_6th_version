// lib/repositories/system_state_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../modules/system_operation_also_main_module/models/safety_error.dart';
import '../modules/system_operation_also_main_module/models/system_component.dart';
import '../modules/system_operation_also_main_module/models/system_log_entry.dart';

class SystemStateRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _componentsCollection => _firestore.collection('system_components');
  CollectionReference get _logCollection => _firestore.collection('system_logs');
  CollectionReference get _safetyErrorCollection => _firestore.collection('safety_errors');
  CollectionReference get _systemStateCollection => _firestore.collection('system_states');

  Future<void> saveComponentState(SystemComponent component) async {
    await _componentsCollection.doc(component.name).set({
      ...component.toJson(),
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Save historical data
    await _componentsCollection
        .doc(component.name)
        .collection('history')
        .add({
      'timestamp': FieldValue.serverTimestamp(),
      'currentValues': component.currentValues,
      'setValues': component.setValues,
      'isActivated': component.isActivated,
    });
  }

  Future<void> saveSystemState(Map<String, dynamic> systemState) async {
    await _systemStateCollection.add({
      ...systemState,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addLogEntry(SystemLogEntry logEntry) async {
    await _logCollection.add(logEntry.toJson());
  }

  // Fetch all system components
  Future<List<SystemComponent>> getAllComponents() async {
    QuerySnapshot snapshot = await _componentsCollection.get();
    return snapshot.docs
        .map((doc) => SystemComponent.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Add or update a system component
  Future<void> saveComponent(SystemComponent component) async {
    await _componentsCollection.doc(component.name).set(component.toJson());
  }

  // Fetch a single system component by name
  Future<SystemComponent?> getComponentByName(String name) async {
    DocumentSnapshot doc = await _componentsCollection.doc(name).get();
    if (doc.exists) {
      return SystemComponent.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Fetch all system log entries
  Future<List<SystemLogEntry>> getAllLogs() async {
    QuerySnapshot snapshot = await _logCollection.get();
    return snapshot.docs
        .map((doc) => SystemLogEntry.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Fetch all safety errors
  Future<List<SafetyError>> getAllSafetyErrors() async {
    QuerySnapshot snapshot = await _safetyErrorCollection.get();
    return snapshot.docs
        .map((doc) => SafetyError.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Add or update a safety error
  Future<void> saveSafetyError(SafetyError safetyError) async {
    await _safetyErrorCollection.doc(safetyError.id).set(safetyError.toJson());
  }

  // Remove a safety error by ID
  Future<void> removeSafetyError(String id) async {
    await _safetyErrorCollection.doc(id).delete();
  }

  Future<List<Map<String, dynamic>>> getComponentHistory(String componentName, DateTime start, DateTime end) async {
    final snapshot = await _componentsCollection
        .doc(componentName)
        .collection('history')
        .where('timestamp', isGreaterThanOrEqualTo: start)
        .where('timestamp', isLessThanOrEqualTo: end)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }


}