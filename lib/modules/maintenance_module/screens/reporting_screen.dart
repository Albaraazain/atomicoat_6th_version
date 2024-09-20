// lib/screens/reporting_screen.dart
import 'package:flutter/material.dart';
import '../providers/maintenance_provider.dart';
import '../providers/calibration_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ReportingScreen extends StatelessWidget {
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
        title: Text('Reporting'),
      ),
      body: ListView(
        children: [
          _buildReportCard(
            context,
            'Maintenance Summary',
            'View summary of maintenance tasks',
                () => _showMaintenanceSummary(context),
          ),
          _buildReportCard(
            context,
            'Calibration History',
            'View history of calibrations',
                () => _showCalibrationHistory(context),
          ),
          _buildReportCard(
            context,
            'Component Status',
            'View current status of all components',
                () => _showComponentStatus(context),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, String title, String description, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _showMaintenanceSummary(BuildContext context) {
    final maintenanceProvider = Provider.of<MaintenanceProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Maintenance Summary'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total Tasks: ${maintenanceProvider.tasks.length}'),
              Text('Completed Tasks: ${maintenanceProvider.tasks.where((task) => task.isCompleted).length}'),
              Text('Pending Tasks: ${maintenanceProvider.tasks.where((task) => !task.isCompleted).length}'),
              SizedBox(height: 16),
              Text('Recent Tasks:'),
              ...maintenanceProvider.tasks.take(5).map((task) =>
                  Text('- ${task.description} (${task.isCompleted ? "Completed" : "Pending"})'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCalibrationHistory(BuildContext context) {
    final calibrationProvider = Provider.of<CalibrationProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Calibration History'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total Calibrations: ${calibrationProvider.calibrationRecords.length}'),
              SizedBox(height: 16),
              Text('Recent Calibrations:'),
              ...calibrationProvider.calibrationRecords.take(5).map((record) =>
                  Text('- ${record.componentId} on ${DateFormat('yyyy-MM-dd').format(record.calibrationDate)}'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showComponentStatus(BuildContext context) {
    final maintenanceProvider = Provider.of<MaintenanceProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Component Status'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: maintenanceProvider.components.map((component) =>
                Text('${component.name}: ${component.status}'),
            ).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}