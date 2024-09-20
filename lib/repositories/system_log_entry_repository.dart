// lib/repositories/system_log_entry_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../modules/system_operation_also_main_module/models/system_log_entry.dart';
import 'base_repository.dart';

class SystemLogEntryRepository extends BaseRepository<SystemLogEntry> {
  SystemLogEntryRepository() : super('system_log_entries');

  @override
  Future<List<SystemLogEntry>> getAll({String? userId}) async {
    return await super.getAll(userId: userId);
  }

  @override
  Future<void> add(String id, SystemLogEntry item, {String? userId}) async {
    if (userId == null) {
      throw ArgumentError('userId is required for adding system log entries');
    }
    await getUserCollection(userId).add(item.toJson());
  }

  Future<List<SystemLogEntry>> getRecentEntries(String userId, {int limit = 1000}) async {
    QuerySnapshot snapshot = await getUserCollection(userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<List<SystemLogEntry>> getEntriesByDateRange(String userId, DateTime start, DateTime end) async {
    QuerySnapshot snapshot = await getUserCollection(userId)
        .where('timestamp', isGreaterThanOrEqualTo: start)
        .where('timestamp', isLessThanOrEqualTo: end)
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs.map((doc) => fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  @override
  SystemLogEntry fromJson(Map<String, dynamic> json) => SystemLogEntry.fromJson(json);
}