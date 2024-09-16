// lib/providers/calibration_provider.dart
import 'package:flutter/foundation.dart';
import '../models/calibration_record.dart';
import '../services/calibration_service.dart';
import '../models/calibration_procedure.dart';

class CalibrationProvider with ChangeNotifier {
  final CalibrationService _service = CalibrationService();
  List<CalibrationRecord> _calibrationRecords = [];
  List<CalibrationProcedure> _calibrationProcedures = [];
  Map<String, String> _componentNames = {};
  bool _isLoading = false;
  String? _error;

  List<CalibrationRecord> get calibrationRecords => [..._calibrationRecords];
  List<CalibrationProcedure> get calibrationProcedures => [..._calibrationProcedures];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCalibrationProcedures() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _calibrationProcedures = await _service.loadCalibrationProcedures();
    } catch (error) {
      _error = 'Failed to fetch calibration procedures. Please try again later.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchComponentNames() async {
    try {
      _componentNames = await _service.getComponentNames();
      notifyListeners();
    } catch (error) {
      _error = 'Failed to fetch component names. Please try again later.';
      notifyListeners();
    }
  }

  String getComponentName(String componentId) {
    return _componentNames[componentId] ?? 'Unknown Component';
  }

  List<CalibrationRecord> getCalibrationRecordsForComponent(String componentId) {
    return _calibrationRecords.where((record) => record.componentId == componentId).toList();
  }


  Future<void> fetchCalibrationRecords() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _calibrationRecords = await _service.loadCalibrationRecords();
    } catch (error) {
      _error = 'Failed to fetch calibration records. Please try again later.';
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

  CalibrationRecord? getLatestCalibrationForComponent(String componentId) {
    final componentRecords = _calibrationRecords.where((record) => record.componentId == componentId).toList();
    if (componentRecords.isEmpty) return null;
    return componentRecords.reduce((a, b) => a.calibrationDate.isAfter(b.calibrationDate) ? a : b);
  }

  bool isCalibrationDue(String componentId, Duration calibrationInterval) {
    final latestCalibration = getLatestCalibrationForComponent(componentId);
    if (latestCalibration == null) return true;
    return DateTime.now().difference(latestCalibration.calibrationDate) >= calibrationInterval;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}