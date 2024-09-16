// lib/models/maintenance_procedure.dart
class MaintenanceStep {
  final String instruction;
  final List<String> tools;
  final List<String> safetyPrecautions;

  MaintenanceStep({
    required this.instruction,
    this.tools = const [],
    this.safetyPrecautions = const [],
  });

  Map<String, dynamic> toJson() => {
    'instruction': instruction,
    'tools': tools,
    'safetyPrecautions': safetyPrecautions,
  };

  factory MaintenanceStep.fromJson(Map<String, dynamic> json) => MaintenanceStep(
    instruction: json['instruction'],
    tools: List<String>.from(json['tools']),
    safetyPrecautions: List<String>.from(json['safetyPrecautions']),
  );
}

class MaintenanceProcedure {
  final String componentId;
  final String componentName;
  final String procedureType; // e.g., "Daily", "Weekly", "Monthly"
  final List<MaintenanceStep> steps;

  MaintenanceProcedure({
    required this.componentId,
    required this.componentName,
    required this.procedureType,
    required this.steps,
  });

  Map<String, dynamic> toJson() => {
    'componentId': componentId,
    'componentName': componentName,
    'procedureType': procedureType,
    'steps': steps.map((step) => step.toJson()).toList(),
  };

  factory MaintenanceProcedure.fromJson(Map<String, dynamic> json) => MaintenanceProcedure(
    componentId: json['componentId'],
    componentName: json['componentName'],
    procedureType: json['procedureType'],
    steps: (json['steps'] as List).map((step) => MaintenanceStep.fromJson(step)).toList(),
  );
}