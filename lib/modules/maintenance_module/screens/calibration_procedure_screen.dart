// lib/screens/calibration_procedure_screen.dart
import 'package:flutter/material.dart';
import '../models/calibration_procedure.dart';
import '../models/calibration_record.dart';
import '../providers/calibration_provider.dart';
import 'package:provider/provider.dart';

class CalibrationProcedureScreen extends StatefulWidget {
  final CalibrationProcedure procedure;

  CalibrationProcedureScreen({required this.procedure});

  @override
  _CalibrationProcedureScreenState createState() => _CalibrationProcedureScreenState();
}

class _CalibrationProcedureScreenState extends State<CalibrationProcedureScreen> {
  int _currentStep = 0;
  Map<int, String> _stepResults = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calibrate ${widget.procedure.componentName}'),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < widget.procedure.steps.length - 1) {
            setState(() {
              _currentStep += 1;
            });
          } else {
            _completeCalibration(context);
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep -= 1;
            });
          }
        },
        steps: widget.procedure.steps.asMap().entries.map((entry) {
          int idx = entry.key;
          CalibrationStep step = entry.value;
          return Step(
            title: Text('Step ${idx + 1}'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.instruction),
                if (step.expectedValue != null)
                  Text('Expected Value: ${step.expectedValue} ${step.unit ?? ''}'),
                TextField(
                  decoration: InputDecoration(labelText: 'Enter result'),
                  onChanged: (value) {
                    _stepResults[idx] = value;
                  },
                ),
              ],
            ),
            isActive: _currentStep >= idx,
          );
        }).toList(),
      ),
    );
  }

  // In _CalibrationProcedureScreenState class
  void _completeCalibration(BuildContext context) {
    final calibrationProvider = Provider.of<CalibrationProvider>(context, listen: false);

    // Convert Map<int, String> to Map<String, dynamic>
    final Map<String, dynamic> calibrationData = _stepResults.map((key, value) => MapEntry(key.toString(), value));

    // Create a new CalibrationRecord
    final newRecord = CalibrationRecord(
      id: DateTime.now().toString(),
      componentId: widget.procedure.componentId,
      calibrationDate: DateTime.now(),
      performedBy: 'Current User', // Replace with actual user data when available
      calibrationData: calibrationData,
      notes: 'Calibration completed using standard procedure',
    );

    // Add the new record
    calibrationProvider.addCalibrationRecord(newRecord);

    // Show completion message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calibration completed and recorded')),
    );

    // Navigate back to the Calibration Screen
    Navigator.of(context).pop();
  }
}