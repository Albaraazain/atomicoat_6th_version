class SafetyError {
  final String id;
  final String description;
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

enum SafetyErrorSeverity {
  warning,
  critical
}

/*

enum SafetyErrorSeverity { warning, critical }

class SafetyError {
    /// Unique identifier for the safety error
    final String id;
    /// Description of the safety issue
    final String description;
    /// Severity level of the safety error
    final SafetyErrorSeverity severity;

    /// Constructor for creating a new safety error
    SafetyError({
        required this.id,
        required this.description,
        required this.severity,
    });
}
 */