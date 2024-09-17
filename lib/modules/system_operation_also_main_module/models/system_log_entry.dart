import 'package:cloud_firestore/cloud_firestore.dart';
import 'system_component.dart';

class SystemLogEntry {
  final DateTime timestamp;
  final String message;
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

