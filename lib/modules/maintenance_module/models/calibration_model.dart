// lib/models/calibration_record.dart
import 'package:flutter/foundation.dart';

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

  @override
  String toString() {
    return 'CalibrationRecord(id: $id, componentId: $componentId, calibrationDate: $calibrationDate, performedBy: $performedBy, calibrationData: $calibrationData, notes: $notes)';
  }
}