// lib/modules/system_operation_also_main_module/models/alarm.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Alarm {
  final String id;
  final String message;
  final AlarmSeverity severity;
  final DateTime timestamp;
  bool acknowledged;
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

  Alarm copyWith({
    String? id,
    String? message,
    AlarmSeverity? severity,
    DateTime? timestamp,
    bool? acknowledged,
    bool? isSafetyAlert,
  }) {
    return Alarm(
      id: id ?? this.id,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      timestamp: timestamp ?? this.timestamp,
      acknowledged: acknowledged ?? this.acknowledged,
      isSafetyAlert: isSafetyAlert ?? this.isSafetyAlert,
    );
  }
}

enum AlarmSeverity {
  info,
  warning,
  critical
}