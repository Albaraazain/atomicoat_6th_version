// lib/screens/calibration_screen.dart
import 'package:flutter/material.dart';
import '../../../enums/navigation_item.dart';
import '../../../utils/navigation_helper.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/custom_app_bar.dart';
import '../widgets/calibration_history_widget.dart';
import '../providers/calibration_provider.dart';
import '../models/calibration_procedure.dart';
import '../models/calibration_record.dart';
import './calibration_procedure_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CalibrationScreen extends StatefulWidget {
  @override
  _CalibrationScreenState createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchCalibrationData());
  }

  Future<void> _fetchCalibrationData() async {
    final calibrationProvider = Provider.of<CalibrationProvider>(context, listen: false);
    await calibrationProvider.fetchCalibrationRecords();
    await calibrationProvider.fetchCalibrationProcedures();
    await calibrationProvider.fetchComponentNames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Calibration',
        onDrawerIconPressed: () => Scaffold.of(context).openDrawer(),
      ),
      drawer: AppDrawer(
        onSelectItem: (item) {
          Navigator.pop(context); // Close the drawer
          handleNavigation(context, item);
        },
        selectedItem: NavigationItem.mainDashboard,
      ),
      body: Consumer<CalibrationProvider>(
        builder: (ctx, calibrationProvider, _) {
          if (calibrationProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calibration Procedures',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16),
                  ...calibrationProvider.calibrationProcedures.map((procedure) =>
                      ListTile(
                        title: Text(procedure.componentName),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () => _showCalibrationProcedure(context, procedure),
                      ),
                  ).toList(),
                  SizedBox(height: 32),
                  Text(
                    'Calibration History',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16),
                  CalibrationHistoryWidget(
                    calibrationRecords: calibrationProvider.calibrationRecords,
                    getComponentName: (id) => calibrationProvider.getComponentName(id),
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
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewCalibrationRecord(context),
        child: Icon(Icons.add),
        tooltip: 'Add new calibration',
      ),
    );
  }

  void _showCalibrationProcedure(BuildContext context, CalibrationProcedure procedure) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CalibrationProcedureScreen(procedure: procedure),
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

  void _addNewCalibrationRecord(BuildContext context) {
    final calibrationProvider = Provider.of<CalibrationProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CalibrationEditDialog(
          calibrationRecord: CalibrationRecord(
            id: DateTime.now().toString(),
            componentId: '',
            calibrationDate: DateTime.now(),
            performedBy: '',
            calibrationData: {},
            notes: '',
          ),
          onSave: (newRecord) {
            calibrationProvider.addCalibrationRecord(newRecord);
          },
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
  late TextEditingController _componentIdController;
  late TextEditingController _performedByController;
  late TextEditingController _notesController;
  late DateTime _calibrationDate;

  @override
  void initState() {
    super.initState();
    _componentIdController = TextEditingController(text: widget.calibrationRecord.componentId);
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
              controller: _componentIdController,
              decoration: InputDecoration(labelText: 'Component ID'),
            ),
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
              componentId: _componentIdController.text,
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
    _componentIdController.dispose();
    _performedByController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}