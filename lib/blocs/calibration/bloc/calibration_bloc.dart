//lib/blocs/calibration/bloc/calibration_bloc.dart

import 'package:bloc/bloc.dart';
import '../../../modules/maintenance_module/services/calibration_service.dart';
import '../../../blocs/component/repository/component_repository.dart';
import 'calibration_event.dart';
import 'calibration_state.dart';

class CalibrationBloc extends Bloc<CalibrationEvent, CalibrationState> {
  final CalibrationService _calibrationService;
  final ComponentRepository _componentRepository;

  CalibrationBloc(
    this._calibrationService,
    this._componentRepository,
  ) : super(const CalibrationState()) {
    on<LoadCalibrationRecords>(_onLoadCalibrationRecords);
    on<LoadCalibrationProcedures>(_onLoadCalibrationProcedures);
    on<AddCalibrationRecord>(_onAddCalibrationRecord);
    on<UpdateCalibrationRecord>(_onUpdateCalibrationRecord);
    on<DeleteCalibrationRecord>(_onDeleteCalibrationRecord);
    on<CalibrateComponentParameter>(_onCalibrateComponentParameter);
    on<ClearCalibrationError>(_onClearCalibrationError);
  }

  Future<void> _onLoadCalibrationRecords(
    LoadCalibrationRecords event,
    Emitter<CalibrationState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));
      final records = await _calibrationService.loadCalibrationRecords();
      emit(state.copyWith(
        calibrationRecords: records,
        isLoading: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        error: 'Failed to load calibration records: $error',
        isLoading: false,
      ));
    }
  }

  Future<void> _onLoadCalibrationProcedures(
    LoadCalibrationProcedures event,
    Emitter<CalibrationState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));
      final procedures = await _calibrationService.loadCalibrationProcedures();
      emit(state.copyWith(
        calibrationProcedures: procedures,
        isLoading: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        error: 'Failed to load calibration procedures: $error',
        isLoading: false,
      ));
    }
  }

  Future<void> _onAddCalibrationRecord(
    AddCalibrationRecord event,
    Emitter<CalibrationState> emit,
  ) async {
    try {
      await _calibrationService.saveCalibrationRecord(event.record);
      final updatedRecords = [...state.calibrationRecords, event.record];
      emit(state.copyWith(
        calibrationRecords: updatedRecords,
      ));
    } catch (error) {
      emit(state.copyWith(
        error: 'Failed to add calibration record: $error',
      ));
    }
  }

  Future<void> _onUpdateCalibrationRecord(
    UpdateCalibrationRecord event,
    Emitter<CalibrationState> emit,
  ) async {
    try {
      await _calibrationService.updateCalibrationRecord(event.record);
      final updatedRecords = state.calibrationRecords.map((record) {
        return record.id == event.record.id ? event.record : record;
      }).toList();
      emit(state.copyWith(
        calibrationRecords: updatedRecords,
      ));
    } catch (error) {
      emit(state.copyWith(
        error: 'Failed to update calibration record: $error',
      ));
    }
  }

  Future<void> _onDeleteCalibrationRecord(
    DeleteCalibrationRecord event,
    Emitter<CalibrationState> emit,
  ) async {
    try {
      await _calibrationService.deleteCalibrationRecord(event.id);
      final updatedRecords = state.calibrationRecords
          .where((record) => record.id != event.id)
          .toList();
      emit(state.copyWith(
        calibrationRecords: updatedRecords,
      ));
    } catch (error) {
      emit(state.copyWith(
        error: 'Failed to delete calibration record: $error',
      ));
    }
  }

  Future<void> _onCalibrateComponentParameter(
    CalibrateComponentParameter event,
    Emitter<CalibrationState> emit,
  ) async {
    try {
      final component = await _componentRepository.getComponent(event.componentName);
      if (component == null) {
        emit(state.copyWith(error: 'Component not found'));
        return;
      }

      component.updateMinValues({event.parameter: event.minValue});
      component.updateMaxValues({event.parameter: event.maxValue});

      // Fix: Use the correct save method
      await _componentRepository.update(component.id, component);

      // No state change needed for the calibration bloc as this affects component state
    } catch (error) {
      emit(state.copyWith(
        error: 'Failed to calibrate parameter: $error',
      ));
    }
  }

  void _onClearCalibrationError(
    ClearCalibrationError event,
    Emitter<CalibrationState> emit,
  ) {
    emit(state.copyWith(error: null));
  }

  @override
  Future<void> close() {
    // Clean up any resources if needed
    return super.close();
  }
}