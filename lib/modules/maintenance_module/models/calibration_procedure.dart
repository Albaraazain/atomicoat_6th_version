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

/*
dart
Copy
class CalibrationStep {
    /// Instruction text for this calibration step
    final String instruction;
    /// Expected measurement value
    final String? expectedValue;
    /// Unit of measurement
    final String? unit;

    /// Constructor for creating a calibration step
    /// @param instruction: Step instruction text
    /// @param expectedValue: Optional expected measurement
    /// @param unit: Optional unit of measurement
    CalibrationStep({
        required this.instruction,
        this.expectedValue,
        this.unit,
    });
}

class CalibrationProcedure {
    /// ID of component to calibrate
    final String componentId;
    /// Name of component to calibrate
    final String componentName;
    /// Ordered list of calibration steps
    final List<CalibrationStep> steps;

    /// Constructor for creating a calibration procedure
    /// @param componentId: Component to calibrate
    /// @param componentName: Name of component
    /// @param steps: Ordered list of calibration steps
    CalibrationProcedure({
        required this.componentId,
        required this.componentName,
        required this.steps,
    });
}
*/