// lib/repositories/system_log_entry_repository.dart

import '../modules/system_operation_also_main_module/models/system_log_entry.dart';
import 'base_repository.dart';

class SystemLogEntryRepository extends BaseRepository<SystemLogEntry> {
  SystemLogEntryRepository() : super('system_logs', 'system_logs');

  @override
  SystemLogEntry fromJson(Map<String, dynamic> json) => SystemLogEntry.fromJson(json);
}