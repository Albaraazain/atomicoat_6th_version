import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:experiment_planner/shared/base/base_repository.dart';
import '../models/system_log_entry.dart';
import '../../components/models/system_component.dart';

class SystemLogEntryRepository extends BaseRepository<SystemLogEntry> {
  static const int DEFAULT_LIMIT = 50;

  SystemLogEntryRepository() : super('logs');

  @override
  SystemLogEntry fromJson(Map<String, dynamic> json) =>
      SystemLogEntry.fromJson(json);

  Future<void> addLogEntry(
    String message,
    ComponentStatus severity,
    {required String userId}
  ) async {
    final logEntry = SystemLogEntry(
      timestamp: DateTime.now(),
      message: message,
      severity: severity,
    );

    await add(
      DateTime.now().millisecondsSinceEpoch.toString(),
      logEntry,
      userId: userId,
    );
  }

  Future<List<SystemLogEntry>> getRecentEntries(
    String userId,
    {int limit = DEFAULT_LIMIT}
  ) async {
    final snapshot = await getUserCollection(userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<SystemLogEntry>> getEntriesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await getUserCollection(userId)
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .where('timestamp', isLessThanOrEqualTo: endDate)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<List<SystemLogEntry>> watchRecentLogs(
    String userId,
    {int limit = DEFAULT_LIMIT}
  ) {
    return getUserCollection(userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }
}