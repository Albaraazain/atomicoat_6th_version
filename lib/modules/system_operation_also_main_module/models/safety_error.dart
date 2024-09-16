// models/safety_error.dart
enum SafetyErrorSeverity { warning, critical }

class SafetyError {
  final String id;
  final String description;
  final SafetyErrorSeverity severity;

  SafetyError({
    required this.id,
    required this.description,
    required this.severity,
  });
}
