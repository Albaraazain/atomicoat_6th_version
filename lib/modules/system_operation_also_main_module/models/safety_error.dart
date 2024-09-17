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