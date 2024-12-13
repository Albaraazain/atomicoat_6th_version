//lib/blocs/calibration/bloc/calibration_event.dart

import 'package:equatable/equatable.dart';
import '../../../modules/maintenance_module/models/calibration_record.dart';
import '../../../modules/maintenance_module/models/calibration_procedure.dart';

abstract class CalibrationEvent extends Equatable {
  const CalibrationEvent();

  @override
  List<Object?> get props => [];
}

class LoadCalibrationRecords extends CalibrationEvent {}

class LoadCalibrationProcedures extends CalibrationEvent {}

class AddCalibrationRecord extends CalibrationEvent {
  final CalibrationRecord record;

  const AddCalibrationRecord(this.record);

  @override
  List<Object> get props => [record];
}

class UpdateCalibrationRecord extends CalibrationEvent {
  final CalibrationRecord record;

  const UpdateCalibrationRecord(this.record);

  @override
  List<Object> get props => [record];
}

class DeleteCalibrationRecord extends CalibrationEvent {
  final String id;

  const DeleteCalibrationRecord(this.id);

  @override
  List<Object> get props => [id];
}

class CalibrateComponentParameter extends CalibrationEvent {
  final String componentName;
  final String parameter;
  final double minValue;
  final double maxValue;

  const CalibrateComponentParameter({
    required this.componentName,
    required this.parameter,
    required this.minValue,
    required this.maxValue,
  });

  @override
  List<Object> get props => [componentName, parameter, minValue, maxValue];
}

class ClearCalibrationError extends CalibrationEvent {}