// models/alarm.dart

enum AlarmSeverity { info, warning, critical }

class Alarm {
  final String id;
  final String message;
  final AlarmSeverity severity;
  final DateTime timestamp;
  bool acknowledged;
  final bool isSafetyAlert; // New flag

  Alarm({
    required this.id,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.acknowledged = false,
    this.isSafetyAlert = false, // Default to false
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'] as String,
      message: json['message'] as String,
      severity: AlarmSeverity.values.firstWhere((e) => e.toString() == 'AlarmSeverity.${json['severity']}'),
      timestamp: DateTime.parse(json['timestamp'] as String),
      acknowledged: json['acknowledged'] as bool? ?? false,
      isSafetyAlert: json['isSafetyAlert'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'message': message,
    'severity': severity.toString().split('.').last,
    'timestamp': timestamp.toIso8601String(),
    'acknowledged': acknowledged,
    'isSafetyAlert': isSafetyAlert,
  };
}
