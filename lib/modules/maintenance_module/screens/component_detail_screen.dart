// lib/screens/component_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/component.dart';
import '../models/calibration_record.dart';
import '../providers/maintenance_provider.dart';
import '../providers/calibration_provider.dart';
import '../widgets/maintenance_task_list.dart';
import '../widgets/calibration_history_widget.dart';
import '../widgets/component_status_update_dialog.dart';
import 'maintenance_procedures_list_screen.dart';

class ComponentDetailScreen extends StatelessWidget {
  final Component component;

  ComponentDetailScreen({required this.component});

  @override
  Widget build(BuildContext context) {
    final maintenanceProvider = Provider.of<MaintenanceProvider>(context);
    final calibrationProvider = Provider.of<CalibrationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(component.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _showStatusUpdateDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildComponentInfo(),
              SizedBox(height: 24),
              _buildMaintenanceTasks(maintenanceProvider),
              SizedBox(height: 24),
              _buildCalibrationHistory(context, calibrationProvider),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MaintenanceProceduresListScreen(
                        componentId: component.id,
                        componentName: component.name,
                      ),
                    ),
                  );
                },
                child: Text('View Maintenance Procedures'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComponentInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Component Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Type: ${component.type}'),
            Text('Status: ${component.status}'),
            Text('Last Maintenance: ${component.lastMaintenanceDate.toString()}'),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceTasks(MaintenanceProvider provider) {
    final tasks = provider.getTasksForComponent(component.id);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Maintenance Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            MaintenanceTaskList(tasks: tasks),
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrationHistory(BuildContext context, CalibrationProvider provider) {
    final calibrationRecords = provider.getCalibrationRecordsForComponent(component.id);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calibration History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            CalibrationHistoryWidget(
              calibrationRecords: calibrationRecords,
              componentId: component.id,
              getComponentName: (id) => provider.getComponentName(id),
              showEditDialog: (context, record, onSave) {
                _showEditCalibrationDialog(context, record, onSave);
              },
              showDeleteConfirmationDialog: (context, record, onDelete) {
                _showDeleteConfirmationDialog(context, record, onDelete);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => ComponentStatusUpdateDialog(
        component: component,
        onUpdate: (newStatus, notes) {
          Provider.of<MaintenanceProvider>(context, listen: false)
              .updateComponentStatus(component.id, newStatus);
        },
      ),
    );
  }

  void _showEditCalibrationDialog(BuildContext context, CalibrationRecord record, Function(CalibrationRecord) onSave) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CalibrationEditDialog(
          calibrationRecord: record,
          onSave: onSave,
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, CalibrationRecord record, Function() onDelete) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Calibration Record'),
          content: Text('Are you sure you want to delete this calibration record?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                onDelete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class CalibrationEditDialog extends StatefulWidget {
  final CalibrationRecord calibrationRecord;
  final Function(CalibrationRecord) onSave;

  CalibrationEditDialog({required this.calibrationRecord, required this.onSave});

  @override
  _CalibrationEditDialogState createState() => _CalibrationEditDialogState();
}

class _CalibrationEditDialogState extends State<CalibrationEditDialog> {
  late TextEditingController _performedByController;
  late TextEditingController _notesController;
  late DateTime _calibrationDate;

  @override
  void initState() {
    super.initState();
    _performedByController = TextEditingController(text: widget.calibrationRecord.performedBy);
    _notesController = TextEditingController(text: widget.calibrationRecord.notes);
    _calibrationDate = widget.calibrationRecord.calibrationDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.calibrationRecord.id.isEmpty ? 'Add Calibration Record' : 'Edit Calibration Record'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _performedByController,
              decoration: InputDecoration(labelText: 'Performed By'),
            ),
            ListTile(
              title: Text('Calibration Date'),
              subtitle: Text(DateFormat('yyyy-MM-dd').format(_calibrationDate)),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _calibrationDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null && picked != _calibrationDate) {
                  setState(() {
                    _calibrationDate = picked;
                  });
                }
              },
            ),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            final updatedRecord = widget.calibrationRecord.copyWith(
              performedBy: _performedByController.text,
              calibrationDate: _calibrationDate,
              notes: _notesController.text,
            );
            widget.onSave(updatedRecord);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _performedByController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}