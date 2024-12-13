//lib/blocs/calibration/bloc/calibration_state.dart

import 'package:equatable/equatable.dart';
import '../../../modules/maintenance_module/models/calibration_record.dart';
import '../../../modules/maintenance_module/models/calibration_procedure.dart';

class CalibrationState extends Equatable {
  final List<CalibrationRecord> calibrationRecords;
  final List<CalibrationProcedure> calibrationProcedures;
  final bool isLoading;
  final String? error;

  const CalibrationState({
    this.calibrationRecords = const [],
    this.calibrationProcedures = const [],
    this.isLoading = false,
    this.error,
  });

  CalibrationState copyWith({
    List<CalibrationRecord>? calibrationRecords,
    List<CalibrationProcedure>? calibrationProcedures,
    bool? isLoading,
    String? error,
  }) {
    return CalibrationState(
      calibrationRecords: calibrationRecords ?? this.calibrationRecords,
      calibrationProcedures: calibrationProcedures ?? this.calibrationProcedures,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        calibrationRecords,
        calibrationProcedures,
        isLoading,
        error,
      ];

  CalibrationRecord? getLatestCalibrationForComponent(String componentName) {
    final componentRecords = calibrationRecords
        .where((record) => record.componentName == componentName)
        .toList();
    if (componentRecords.isEmpty) return null;
    return componentRecords.reduce(
        (a, b) => a.calibrationDate.isAfter(b.calibrationDate) ? a : b);
  }

  bool isCalibrationDue(String componentName, Duration calibrationInterval) {
    final latestCalibration = getLatestCalibrationForComponent(componentName);
    if (latestCalibration == null) return true;
    return DateTime.now().difference(latestCalibration.calibrationDate) >=
        calibrationInterval;
  }

  List<CalibrationRecord> getCalibrationRecordsForComponent(String componentId) {
    return calibrationRecords
        .where((record) => record.componentId == componentId)
        .toList();
  }
}