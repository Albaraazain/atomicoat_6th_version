// lib/providers/calibration_provider.dart

import 'package:flutter/foundation.dart';
import '../../system_operation_also_main_module/models/system_component.dart';
import '../../system_operation_also_main_module/providers/system_copmonent_provider.dart';
import '../models/calibration_record.dart';
import '../services/calibration_service.dart';
import '../models/calibration_procedure.dart';

class CalibrationProvider with ChangeNotifier {
  final CalibrationService _service = CalibrationService();
  final SystemComponentProvider _componentProvider;

  List<CalibrationRecord> _calibrationRecords = [];
  List<CalibrationProcedure> _calibrationProcedures = [];
  bool _isLoading = false;
  String? _error;

  CalibrationProvider(this._componentProvider);

  // Access components directly from SystemComponentProvider
  Map<String, SystemComponent> get components => _componentProvider.components;

  List<CalibrationRecord> get calibrationRecords => [..._calibrationRecords];
  List<CalibrationProcedure> get calibrationProcedures =>
      [..._calibrationProcedures];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCalibrationProcedures() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _calibrationProcedures = await _service.loadCalibrationProcedures();
    } catch (error) {
      _error =
      'Failed to fetch calibration procedures. Please try again later.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCalibrationRecords() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _calibrationRecords = await _service.loadCalibrationRecords();
    } catch (error) {
      _error =
      'Failed to fetch calibration records. Please try again later.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCalibrationRecord(CalibrationRecord record) async {
    try {
      await _service.saveCalibrationRecord(record);
      _calibrationRecords.add(record);
      notifyListeners();
    } catch (error) {
      _error = 'Failed to add calibration record. Please try again.';
      notifyListeners();
    }
  }

  Future<void> updateCalibrationRecord(CalibrationRecord record) async {
    try {
      await _service.updateCalibrationRecord(record);
      final index = _calibrationRecords.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _calibrationRecords[index] = record;
        notifyListeners();
      }
    } catch (error) {
      _error = 'Failed to update calibration record. Please try again.';
      notifyListeners();
    }
  }

  Future<void> deleteCalibrationRecord(String id) async {
    try {
      await _service.deleteCalibrationRecord(id);
      _calibrationRecords.removeWhere((record) => record.id == id);
      notifyListeners();
    } catch (error) {
      _error = 'Failed to delete calibration record. Please try again.';
      notifyListeners();
    }
  }

  CalibrationRecord? getLatestCalibrationForComponent(String componentName) {
    final componentRecords = _calibrationRecords
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

  // Calibrate component parameters
  void calibrateParameter(
      String componentName, String parameter, double minValue, double maxValue) {
    final component = _componentProvider.getComponent(componentName);
    if (component != null) {
      component.updateMinValues({parameter: minValue});
      component.updateMaxValues({parameter: maxValue});
      notifyListeners();
    } else {
      _error = 'Component not found.';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  getComponentName(String id) {
    return components[id]?.name;
  }

  void update(CalibrationProvider calibration) {
    _calibrationRecords = calibration.calibrationRecords;
    _calibrationProcedures = calibration.calibrationProcedures;
    _isLoading = calibration.isLoading;
    _error = calibration.error;
    notifyListeners();
  }

  fetchComponentNames() {
    return components.values.map((component) => component.name).toList();
  }

  getCalibrationRecordsForComponent(id) {
    return _calibrationRecords
        .where((record) => record.componentId == id)
        .toList();
  }
}
