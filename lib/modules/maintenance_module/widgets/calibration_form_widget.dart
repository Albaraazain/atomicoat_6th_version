// lib/widgets/calibration_form_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/component.dart';
import '../models/calibration_record.dart';
import '../providers/calibration_provider.dart';
import 'package:intl/intl.dart';

class CalibrationFormWidget extends StatefulWidget {
  final Component component;

  CalibrationFormWidget({required this.component});

  @override
  _CalibrationFormWidgetState createState() => _CalibrationFormWidgetState();
}

class _CalibrationFormWidgetState extends State<CalibrationFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _performedByController;
  late TextEditingController _notesController;
  late DateTime _calibrationDate;
  Map<String, dynamic> _calibrationData = {};

  @override
  void initState() {
    super.initState();
    _performedByController = TextEditingController();
    _notesController = TextEditingController();
    _calibrationDate = DateTime.now();
  }

  @override
  void dispose() {
    _performedByController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calibration for ${widget.component.name}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _performedByController,
            decoration: InputDecoration(labelText: 'Performed By'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter who performed the calibration';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Text('Calibration Date: ${DateFormat('MMM dd, yyyy').format(_calibrationDate)}'),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _calibrationDate,
                    firstDate: DateTime.now().subtract(Duration(days: 365)),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && picked != _calibrationDate) {
                    setState(() {
                      _calibrationDate = picked;
                    });
                  }
                },
                child: Text('Select Date'),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text('Calibration Data', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8),
          ..._buildCalibrationDataFields(),
          SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: InputDecoration(labelText: 'Notes'),
            maxLines: 3,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitCalibration,
            child: Text('Submit Calibration'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCalibrationDataFields() {
    // This is where you would add specific fields based on the component type
    // For this example, we'll add some generic fields
    return [
      TextFormField(
        decoration: InputDecoration(labelText: 'Measurement 1'),
        keyboardType: TextInputType.number,
        onSaved: (value) => _calibrationData['measurement1'] = double.tryParse(value ?? '') ?? 0,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value';
          }
          if (double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
      TextFormField(
        decoration: InputDecoration(labelText: 'Measurement 2'),
        keyboardType: TextInputType.number,
        onSaved: (value) => _calibrationData['measurement2'] = double.tryParse(value ?? '') ?? 0,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value';
          }
          if (double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    ];
  }

  void _submitCalibration() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final calibrationProvider = Provider.of<CalibrationProvider>(context, listen: false);
      final newCalibration = CalibrationRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        componentId: widget.component.id,
        calibrationDate: _calibrationDate,
        performedBy: _performedByController.text,
        calibrationData: _calibrationData,
        notes: _notesController.text,
      );

      calibrationProvider.addCalibrationRecord(newCalibration).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Calibration submitted successfully')),
        );
        Navigator.of(context).pop();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit calibration. Please try again.')),
        );
      });
    }
  }
}