// lib/models/calibration_record.dart

class CalibrationRecord {
  final String id;
  final String componentId;
  final DateTime calibrationDate;
  final String performedBy;
  final Map<String, dynamic> calibrationData;
  final String notes;

  CalibrationRecord({
    required this.id,
    required this.componentId,
    required this.calibrationDate,
    required this.performedBy,
    required this.calibrationData,
    this.notes = '',
  });

  CalibrationRecord copyWith({
    String? id,
    String? componentId,
    DateTime? calibrationDate,
    String? performedBy,
    Map<String, dynamic>? calibrationData,
    String? notes,
  }) {
    return CalibrationRecord(
      id: id ?? this.id,
      componentId: componentId ?? this.componentId,
      calibrationDate: calibrationDate ?? this.calibrationDate,
      performedBy: performedBy ?? this.performedBy,
      calibrationData: calibrationData ?? this.calibrationData,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'componentId': componentId,
      'calibrationDate': calibrationDate.toIso8601String(),
      'performedBy': performedBy,
      'calibrationData': calibrationData,
      'notes': notes,
    };
  }

  factory CalibrationRecord.fromJson(Map<String, dynamic> json) {
    return CalibrationRecord(
      id: json['id'],
      componentId: json['componentId'],
      calibrationDate: DateTime.parse(json['calibrationDate']),
      performedBy: json['performedBy'],
      calibrationData: json['calibrationData'],
      notes: json['notes'],
    );
  }

  get componentName => id.toString();

  @override
  String toString() {
    return 'CalibrationRecord(id: $id, componentId: $componentId, calibrationDate: $calibrationDate, performedBy: $performedBy, calibrationData: $calibrationData, notes: $notes)';
  }
}


/*

class CalibrationRecord {
    /// Unique identifier for the calibration record
    final String id;
    /// ID of the component being calibrated
    final String componentId;
    /// Date and time of calibration
    final DateTime calibrationDate;
    /// User who performed the calibration
    final String performedBy;
    /// Measured calibration values and parameters
    final Map<String, dynamic> calibrationData;
    /// Additional notes about the calibration
    final String notes;

    /// Constructor for creating a new calibration record
    /// @param id: Unique identifier
    /// @param componentId: Component being calibrated
    /// @param calibrationDate: When calibration was performed
    /// @param performedBy: User performing calibration
    /// @param calibrationData: Measured values and parameters
    /// @param notes: Optional notes about the calibration
    CalibrationRecord({
        required this.id,
        required this.componentId,
        required this.calibrationDate,
        required this.performedBy,
        required this.calibrationData,
        this.notes = '',
    });

    /// Creates a copy of the record with optional parameter updates
    CalibrationRecord copyWith({...});

    /// Returns the name of the component associated with this record
    String get componentName => id.toString();
}

 */