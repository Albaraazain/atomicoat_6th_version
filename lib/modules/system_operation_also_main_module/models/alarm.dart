// lib/modules/system_operation_also_main_module/models/alarm.dart

import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'alarm.g.dart';

@HiveType(typeId: 0)
class Alarm {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String message;

  @HiveField(2)
  final AlarmSeverity severity;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  bool acknowledged;

  @HiveField(5)
  final bool isSafetyAlert;

  Alarm({
    required this.id,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.acknowledged = false,
    this.isSafetyAlert = false,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'] as String,
      message: json['message'] as String,
      severity: AlarmSeverity.values.firstWhere((e) => e.toString() == 'AlarmSeverity.${json['severity']}'),
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      acknowledged: json['acknowledged'] as bool? ?? false,
      isSafetyAlert: json['isSafetyAlert'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'message': message,
    'severity': severity.toString().split('.').last,
    'timestamp': Timestamp.fromDate(timestamp),
    'acknowledged': acknowledged,
    'isSafetyAlert': isSafetyAlert,
  };
}

@HiveType(typeId: 1)
enum AlarmSeverity {
  @HiveField(0)
  info,
  @HiveField(1)
  warning,
  @HiveField(2)
  critical
}