// lib/screens/add_calibration_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calibration_provider.dart';
import '../providers/maintenance_provider.dart';
import '../models/calibration_record.dart';

class AddCalibrationScreen extends StatefulWidget {
  @override
  _AddCalibrationScreenState createState() => _AddCalibrationScreenState();
}

class _AddCalibrationScreenState extends State<AddCalibrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _componentId = '';
  DateTime _calibrationDate = DateTime.now();
  String _performedBy = '';
  String _notes = '';
  Map<String, dynamic> _calibrationData = {};

  @override
  Widget build(BuildContext context) {
    final maintenanceProvider = Provider.of<MaintenanceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Calibration Record'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _componentId.isEmpty ? null : _componentId,
                hint: Text('Select Component'),
                items: maintenanceProvider.components.map((component) {
                  return DropdownMenuItem(
                    value: component.id,
                    child: Text(component.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _componentId = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a component';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text('Calibration Date: ${_calibrationDate.toString().substring(0, 10)}'),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _calibrationDate,
                        firstDate: DateTime.now().subtract(Duration(days: 365)),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _calibrationDate = pickedDate;
                        });
                      }
                    },
                    child: Text('Select Date'),
                  ),
                ],
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Performed By'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter who performed the calibration';
                  }
                  return null;
                },
                onSaved: (value) {
                  _performedBy = value!;
                },
              ),
              SizedBox(height: 16),
              Text('Calibration Data', style: Theme.of(context).textTheme.titleMedium),
              TextFormField(
                decoration: InputDecoration(labelText: 'Measurement 1'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  return null;
                },
                onSaved: (value) {
                  _calibrationData['measurement1'] = double.parse(value!);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Measurement 2'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  return null;
                },
                onSaved: (value) {
                  _calibrationData['measurement2'] = double.parse(value!);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Notes'),
                maxLines: 3,
                onSaved: (value) {
                  _notes = value ?? '';
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Add Calibration Record'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newCalibration = CalibrationRecord(
        id: DateTime.now().toString(), // You might want to use a more robust ID generation method
        componentId: _componentId,
        calibrationDate: _calibrationDate,
        performedBy: _performedBy,
        calibrationData: _calibrationData,
        notes: _notes,
      );
      Provider.of<CalibrationProvider>(context, listen: false).addCalibrationRecord(newCalibration);
      Navigator.of(context).pop();
    }
  }
}