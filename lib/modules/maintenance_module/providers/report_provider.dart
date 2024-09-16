// lib/providers/report_provider.dart
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../services/report_service.dart';
import './maintenance_provider.dart';
import './calibration_provider.dart';

class ReportProvider with ChangeNotifier {
  final ReportService _reportService = ReportService();
  final MaintenanceProvider _maintenanceProvider;
  final CalibrationProvider _calibrationProvider;

  ReportProvider(this._maintenanceProvider, this._calibrationProvider);

  Future<File> generateMaintenanceReport() async {
    final tasks = _maintenanceProvider.tasks;
    return await _reportService.generateMaintenanceReport(tasks);
  }

  Future<File> generateCalibrationReport() async {
    final records = _calibrationProvider.calibrationRecords;
    return await _reportService.generateCalibrationReport(records);
  }

  Future<File> generateComponentStatusReport() async {
    final components = _maintenanceProvider.components;
    return await _reportService.generateComponentStatusReport(components);
  }
}