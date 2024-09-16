// lib/models/calibration_procedure.dart
class CalibrationStep {
  final String instruction;
  final String? expectedValue;
  final String? unit;

  CalibrationStep({
    required this.instruction,
    this.expectedValue,
    this.unit,
  });

  Map<String, dynamic> toJson() => {
    'instruction': instruction,
    'expectedValue': expectedValue,
    'unit': unit,
  };

  factory CalibrationStep.fromJson(Map<String, dynamic> json) => CalibrationStep(
    instruction: json['instruction'],
    expectedValue: json['expectedValue'],
    unit: json['unit'],
  );
}

class CalibrationProcedure {
  final String componentId;
  final String componentName;
  final List<CalibrationStep> steps;

  CalibrationProcedure({
    required this.componentId,
    required this.componentName,
    required this.steps,
  });

  Map<String, dynamic> toJson() => {
    'componentId': componentId,
    'componentName': componentName,
    'steps': steps.map((step) => step.toJson()).toList(),
  };

  factory CalibrationProcedure.fromJson(Map<String, dynamic> json) => CalibrationProcedure(
    componentId: json['componentId'],
    componentName: json['componentName'],
    steps: (json['steps'] as List).map((step) => CalibrationStep.fromJson(step)).toList(),
  );
}