// lib/repositories/system_log_entry_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../modules/system_operation_also_main_module/models/system_log_entry.dart';

class SystemLogEntryRepository {
  final CollectionReference _logEntriesCollection = FirebaseFirestore.instance.collection('system_log_entries');

  Future<List<SystemLogEntry>> getAll() async {
    QuerySnapshot snapshot = await _logEntriesCollection.get();
    return snapshot.docs.map((doc) => SystemLogEntry.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> add(SystemLogEntry logEntry) async {
    await _logEntriesCollection.add(logEntry.toJson());
  }

  Future<List<SystemLogEntry>> getRecentEntries({int limit = 1000}) async {
    QuerySnapshot snapshot = await _logEntriesCollection
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => SystemLogEntry.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }
}