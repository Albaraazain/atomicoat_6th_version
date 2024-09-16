// lib/modules/system_operation_also_main_module/models/system_log_entry.dart

import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'system_component.dart';

part 'system_log_entry.g.dart';

@HiveType(typeId: 11)
class SystemLogEntry {
  @HiveField(0)
  final DateTime timestamp;

  @HiveField(1)
  final String message;

  @HiveField(2)
  final ComponentStatus severity;

  SystemLogEntry({
    required this.timestamp,
    required this.message,
    required this.severity,
  });

  factory SystemLogEntry.fromJson(Map<String, dynamic> json) {
    return SystemLogEntry(
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      message: json['message'] as String,
      severity: ComponentStatus.values.firstWhere((e) => e.toString() == 'ComponentStatus.${json['severity']}'),
    );
  }

  Map<String, dynamic> toJson() => {
    'timestamp': Timestamp.fromDate(timestamp),
    'message': message,
    'severity': severity.toString().split('.').last,
  };
}