// lib/screens/report_generation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';

class ReportGenerationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Text('Generate Reports'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Report Type', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _generateReport(context, ReportType.maintenance),
              child: Text('Maintenance Report'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _generateReport(context, ReportType.calibration),
              child: Text('Calibration Report'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _generateReport(context, ReportType.componentStatus),
              child: Text('Component Status Report'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateReport(BuildContext context, ReportType type) async {
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    File reportFile;

    try {
      switch (type) {
        case ReportType.maintenance:
          reportFile = await reportProvider.generateMaintenanceReport();
          break;
        case ReportType.calibration:
          reportFile = await reportProvider.generateCalibrationReport();
          break;
        case ReportType.componentStatus:
          reportFile = await reportProvider.generateComponentStatusReport();
          break;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report generated successfully'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () => OpenFile.open(reportFile.path),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate report: ${e.toString()}')),
      );
    }
  }
}

enum ReportType { maintenance, calibration, componentStatus }