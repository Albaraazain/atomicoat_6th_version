// lib/services/report_service.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/maintenance_task.dart';
import '../models/calibration_record.dart';
import '../models/component.dart';
import 'package:intl/intl.dart';

class ReportService {
  Future<File> generateMaintenanceReport(List<MaintenanceTask> tasks) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, child: pw.Text('Maintenance Report')),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Component', 'Description', 'Due Date', 'Status'],
                  ...tasks.map((task) => [
                    task.componentId,
                    task.description,
                    DateFormat('yyyy-MM-dd').format(task.dueDate),
                    task.isCompleted ? 'Completed' : 'Pending'
                  ]),
                ],
              ),
            ],
          );
        },
      ),
    );

    return _savePdfFile(pdf, 'maintenance_report.pdf');
  }

  Future<File> generateCalibrationReport(List<CalibrationRecord> records) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, child: pw.Text('Calibration Report')),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Component', 'Calibration Date', 'Performed By', 'Notes'],
                  ...records.map((record) => [
                    record.componentId,
                    DateFormat('yyyy-MM-dd').format(record.calibrationDate),
                    record.performedBy,
                    record.notes
                  ]),
                ],
              ),
            ],
          );
        },
      ),
    );

    return _savePdfFile(pdf, 'calibration_report.pdf');
  }

  Future<File> generateComponentStatusReport(List<Component> components) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, child: pw.Text('Component Status Report')),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Component', 'Type', 'Status', 'Last Maintenance'],
                  ...components.map((component) => [
                    component.name,
                    component.type,
                    component.status,
                    DateFormat('yyyy-MM-dd').format(component.lastMaintenanceDate),
                  ]),
                ],
              ),
            ],
          );
        },
      ),
    );

    return _savePdfFile(pdf, 'component_status_report.pdf');
  }

  Future<File> _savePdfFile(pw.Document pdf, String fileName) async {
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}