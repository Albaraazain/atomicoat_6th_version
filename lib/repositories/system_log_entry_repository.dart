// lib/repositories/system_log_entry_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../modules/system_operation_also_main_module/models/system_log_entry.dart';
import '../modules/system_operation_also_main_module/models/system_component.dart';

class SystemLogEntryRepository {
  final FirebaseFirestore _firestore;

  SystemLogEntryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> add(String message, ComponentStatus severity, {required String userId}) async {
    await _firestore.collection('users/$userId/logs').add({
      'timestamp': FieldValue.serverTimestamp(),
      'message': message,
      'severity': severity.toString().split('.').last,
    });
  }

  Future<List<SystemLogEntry>> getRecentEntries(String userId, {int limit = 50}) async {
    final snapshot = await _firestore
        .collection('users/$userId/logs')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => SystemLogEntry.fromJson(doc.data())).toList();
  }

  Future<List<SystemLogEntry>> getEntriesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _firestore
        .collection('users/$userId/logs')
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .where('timestamp', isLessThanOrEqualTo: endDate)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => SystemLogEntry.fromJson(doc.data())).toList();
  }
}