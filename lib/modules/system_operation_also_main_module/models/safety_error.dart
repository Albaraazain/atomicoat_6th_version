// lib/modules/system_operation_also_main_module/models/safety_error.dart

import 'package:hive/hive.dart';

part 'safety_error.g.dart';

@HiveType(typeId: 9)
class SafetyError {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final SafetyErrorSeverity severity;

  SafetyError({
    required this.id,
    required this.description,
    required this.severity,
  });

  factory SafetyError.fromJson(Map<String, dynamic> json) {
    return SafetyError(
      id: json['id'] as String,
      description: json['description'] as String,
      severity: SafetyErrorSeverity.values.firstWhere((e) => e.toString() == 'SafetyErrorSeverity.${json['severity']}'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'severity': severity.toString().split('.').last,
  };
}

@HiveType(typeId: 10)
enum SafetyErrorSeverity {
  @HiveField(0)
  warning,
  @HiveField(1)
  critical
}