// lib/screens/maintenance_procedure_screen.dart
import 'package:flutter/material.dart';
import '../models/maintenance_procedure.dart';
import '../providers/maintenance_provider.dart';
import 'package:provider/provider.dart';

class MaintenanceProcedureScreen extends StatefulWidget {
  final String componentId;
  final String procedureType;

  MaintenanceProcedureScreen({required this.componentId, required this.procedureType});

  @override
  _MaintenanceProcedureScreenState createState() => _MaintenanceProcedureScreenState();
}

class _MaintenanceProcedureScreenState extends State<MaintenanceProcedureScreen> {
  int _currentStep = 0;
  late Future<MaintenanceProcedure?> _procedureFuture;

  @override
  void initState() {
    super.initState();
    _procedureFuture = _loadProcedure();
  }

  Future<MaintenanceProcedure?> _loadProcedure() async {
    final maintenanceProvider = Provider.of<MaintenanceProvider>(context, listen: false);
    try {
      return await maintenanceProvider.getMaintenanceProcedure(widget.componentId, widget.procedureType);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load maintenance procedure. Please try again.')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maintenance Procedure'),
      ),
      body: FutureBuilder<MaintenanceProcedure?>(
        future: _procedureFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No procedure found for this component and type.'));
          }

          MaintenanceProcedure procedure = snapshot.data!;
          return Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < procedure.steps.length - 1) {
                setState(() {
                  _currentStep += 1;
                });
              } else {
                _completeMaintenance(context);
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() {
                  _currentStep -= 1;
                });
              }
            },
            steps: procedure.steps.asMap().entries.map((entry) {
              int idx = entry.key;
              MaintenanceStep step = entry.value;
              return Step(
                title: Text('Step ${idx + 1}'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.instruction),
                    if (step.tools.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Text('Tools needed:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...step.tools.map((tool) => Text('• $tool')),
                    ],
                    if (step.safetyPrecautions.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Text('Safety precautions:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...step.safetyPrecautions.map((precaution) => Text('• $precaution')),
                    ],
                  ],
                ),
                isActive: _currentStep >= idx,
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _completeMaintenance(BuildContext context) {
    // TODO: Implement logic to mark the maintenance task as completed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Maintenance procedure completed')),
    );
    Navigator.of(context).pop();
  }
}