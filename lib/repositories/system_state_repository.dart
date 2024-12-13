// lib/repositories/system_state_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../modules/system_operation_also_main_module/models/safety_error.dart';
import '../modules/system_operation_also_main_module/models/system_component.dart';
import '../modules/system_operation_also_main_module/models/system_log_entry.dart';
import '../blocs/system_state/models/system_state_data.dart';

class SystemStateRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _getUserCollection(String userId, String collectionName) {
    return _firestore.collection('users').doc(userId).collection(collectionName);
  }

  Future<void> saveComponentState(String userId, SystemComponent component) async {
    await _getUserCollection(userId, 'system_components').doc(component.name).set({
      ...component.toJson(),
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Save historical data
    await _getUserCollection(userId, 'system_components')
        .doc(component.name)
        .collection('history')
        .add({
      'timestamp': FieldValue.serverTimestamp(),
      'currentValues': component.currentValues,
      'setValues': component.setValues,
      'isActivated': component.isActivated,
    });
  }

  Future<void> saveSystemState(Map<String, dynamic> stateData) async {
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    await _firestore.collection('system_states').doc(id).set({
      ...stateData,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<SystemStateData?> getLatestState() async {
    final snapshot = await _firestore
        .collection('system_states')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return SystemStateData(
      id: doc.id,
      data: doc.data(),
      timestamp: (doc.data()['timestamp'] as Timestamp).toDate(),
    );
  }

  Stream<SystemStateData> watchSystemState() {
    return _firestore
        .collection('system_states')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      final doc = snapshot.docs.first;
      return SystemStateData(
        id: doc.id,
        data: doc.data(),
        timestamp: (doc.data()['timestamp'] as Timestamp).toDate(),
      );
    });
  }

  Future<SystemStateData?> getSystemState() async {
    final snapshot = await _firestore
        .collection('system_states')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return SystemStateData(
      id: doc.id,
      data: doc.data(),
      timestamp: (doc.data()['timestamp'] as Timestamp).toDate(),
    );
  }

  Stream<SystemStateData?> systemStateStream() {
    return _firestore
        .collection('system_states')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return SystemStateData(
        id: doc.id,
        data: doc.data(),
        timestamp: (doc.data()['timestamp'] as Timestamp).toDate(),
      );
    });
  }

  Future<void> addLogEntry(String userId, SystemLogEntry logEntry) async {
    await _getUserCollection(userId, 'system_logs').add(logEntry.toJson());
  }

  Future<List<SystemComponent>> getAllComponents(String userId) async {
    QuerySnapshot snapshot = await _getUserCollection(userId, 'system_components').get();
    return snapshot.docs
        .map((doc) => SystemComponent.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveComponent(String userId, SystemComponent component) async {
    await _getUserCollection(userId, 'system_components').doc(component.name).set(component.toJson());
  }

  Future<SystemComponent?> getComponentByName(String userId, String name) async {
    DocumentSnapshot doc = await _getUserCollection(userId, 'system_components').doc(name).get();
    if (doc.exists) {
      return SystemComponent.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<SystemLogEntry>> getAllLogs(String userId) async {
    QuerySnapshot snapshot = await _getUserCollection(userId, 'system_logs').get();
    return snapshot.docs
        .map((doc) => SystemLogEntry.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<SafetyError>> getAllSafetyErrors(String userId) async {
    QuerySnapshot snapshot = await _getUserCollection(userId, 'safety_errors').get();
    return snapshot.docs
        .map((doc) => SafetyError.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveSafetyError(String userId, SafetyError safetyError) async {
    await _getUserCollection(userId, 'safety_errors').doc(safetyError.id).set(safetyError.toJson());
  }

  Future<void> removeSafetyError(String userId, String id) async {
    await _getUserCollection(userId, 'safety_errors').doc(id).delete();
  }

  Future<List<Map<String, dynamic>>> getComponentHistory(String userId, String componentName, DateTime start, DateTime end) async {
    final snapshot = await _getUserCollection(userId, 'system_components')
        .doc(componentName)
        .collection('history')
        .where('timestamp', isGreaterThanOrEqualTo: start)
        .where('timestamp', isLessThanOrEqualTo: end)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<SystemLogEntry>> getSystemLog(String userId) async {
    QuerySnapshot snapshot = await _getUserCollection(userId, 'system_logs')
        .orderBy('timestamp', descending: true)
        .limit(100) // Limit to last 100 entries, adjust as needed
        .get();

    return snapshot.docs
        .map((doc) => SystemLogEntry.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}