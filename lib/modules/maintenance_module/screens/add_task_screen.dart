// lib/screens/add_task_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/maintenance_provider.dart';
import '../models/maintenance_task.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _description = '';
  DateTime _dueDate = DateTime.now();
  String _componentId = '';

  @override
  Widget build(BuildContext context) {
    final maintenanceProvider = Provider.of<MaintenanceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Maintenance Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text('Due Date: ${_dueDate.toString().substring(0, 10)}'),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _dueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _dueDate = pickedDate;
                        });
                      }
                    },
                    child: Text('Select Date'),
                  ),
                ],
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Add Task'),
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
      final newTask = MaintenanceTask(
        id: DateTime.now().toString(), // You might want to use a more robust ID generation method
        componentId: _componentId,
        description: _description,
        dueDate: _dueDate,
        isCompleted: false,
      );
      Provider.of<MaintenanceProvider>(context, listen: false).addTask(newTask);
      Navigator.of(context).pop();
    }
  }
}