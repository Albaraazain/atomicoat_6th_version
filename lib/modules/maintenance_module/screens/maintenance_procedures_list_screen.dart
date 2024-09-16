// lib/screens/maintenance_procedures_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/maintenance_provider.dart';
import '../models/maintenance_procedure.dart';
import './maintenance_procedure_screen.dart';

class MaintenanceProceduresListScreen extends StatelessWidget {
  final String componentId;
  final String componentName;

  MaintenanceProceduresListScreen({required this.componentId, required this.componentName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maintenance Procedures for $componentName'),
      ),
      body: Consumer<MaintenanceProvider>(
        builder: (ctx, maintenanceProvider, _) {
          final procedures = maintenanceProvider.procedures
              .where((proc) => proc.componentId == componentId)
              .toList();

          if (procedures.isEmpty) {
            return Center(
              child: Text('No maintenance procedures found for this component.'),
            );
          }

          return ListView.builder(
            itemCount: procedures.length,
            itemBuilder: (ctx, index) {
              final procedure = procedures[index];
              return ListTile(
                title: Text(procedure.procedureType),
                subtitle: Text('Steps: ${procedure.steps.length}'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MaintenanceProcedureScreen(
                        componentId: componentId,
                        procedureType: procedure.procedureType,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProcedureDialog(context),
        child: Icon(Icons.add),
        tooltip: 'Add new procedure',
      ),
    );
  }

  void _showAddProcedureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AddProcedureDialog(componentId: componentId, componentName: componentName),
    );
  }
}

class AddProcedureDialog extends StatefulWidget {
  final String componentId;
  final String componentName;

  AddProcedureDialog({required this.componentId, required this.componentName});

  @override
  _AddProcedureDialogState createState() => _AddProcedureDialogState();
}

class _AddProcedureDialogState extends State<AddProcedureDialog> {
  final _formKey = GlobalKey<FormState>();
  String _procedureType = '';
  List<MaintenanceStep> _steps = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Procedure'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Procedure Type'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a procedure type';
                }
                return null;
              },
              onSaved: (value) {
                _procedureType = value!;
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addStep,
              child: Text('Add Step'),
            ),
            ..._steps.asMap().entries.map((entry) {
              int idx = entry.key;
              MaintenanceStep step = entry.value;
              return ListTile(
                title: Text('Step ${idx + 1}: ${step.instruction}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _removeStep(idx),
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveProcedure,
          child: Text('Save'),
        ),
      ],
    );
  }

  void _addStep() {
    showDialog(
      context: context,
      builder: (ctx) => AddStepDialog(),
    ).then((step) {
      if (step != null) {
        setState(() {
          _steps.add(step);
        });
      }
    });
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
    });
  }

  void _saveProcedure() {
    if (_formKey.currentState!.validate() && _steps.isNotEmpty) {
      _formKey.currentState!.save();
      final newProcedure = MaintenanceProcedure(
        componentId: widget.componentId,
        componentName: widget.componentName,
        procedureType: _procedureType,
        steps: _steps,
      );
      Provider.of<MaintenanceProvider>(context, listen: false)
          .addMaintenanceProcedure(newProcedure);
      Navigator.of(context).pop();
    } else if (_steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add at least one step to the procedure.')),
      );
    }
  }
}

class AddStepDialog extends StatefulWidget {
  @override
  _AddStepDialogState createState() => _AddStepDialogState();
}

class _AddStepDialogState extends State<AddStepDialog> {
  final _formKey = GlobalKey<FormState>();
  String _instruction = '';
  List<String> _tools = [];
  List<String> _safetyPrecautions = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Step'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Instruction'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an instruction';
                }
                return null;
              },
              onSaved: (value) {
                _instruction = value!;
              },
            ),
            // Add fields for tools and safety precautions if needed
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveStep,
          child: Text('Add'),
        ),
      ],
    );
  }

  void _saveStep() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newStep = MaintenanceStep(
        instruction: _instruction,
        tools: _tools,
        safetyPrecautions: _safetyPrecautions,
      );
      Navigator.of(context).pop(newStep);
    }
  }
}