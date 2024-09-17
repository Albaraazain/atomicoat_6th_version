// lib/widgets/component_control_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/system_component.dart';
import '../models/recipe.dart';
import '../providers/system_state_provider.dart';

class ComponentControlDialog extends StatefulWidget {
  final SystemComponent component;
  final bool isActiveInCurrentStep;
  final RecipeStep? currentRecipeStep;

  ComponentControlDialog({
    required this.component,
    required this.isActiveInCurrentStep,
    this.currentRecipeStep,
  });

  @override
  _ComponentControlDialogState createState() => _ComponentControlDialogState();
}

class _ComponentControlDialogState extends State<ComponentControlDialog> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (var entry in widget.component.setValues.entries)
        entry.key: TextEditingController(text: entry.value.toString())
    };
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _updateSetValues(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final systemProvider = Provider.of<SystemStateProvider>(context, listen: false);
      _controllers.forEach((parameter, controller) {
        double? newValue = double.tryParse(controller.text);
        if (newValue != null) {
          systemProvider.setComponentSetValue(widget.component.name, parameter, newValue);
        }
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.component.name),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Status: ${widget.component.isActivated ? "Active" : "Inactive"}'),
              SizedBox(height: 10),
              Text('Current Values:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...widget.component.currentValues.entries.map((entry) =>
                  Text('  ${entry.key}: ${entry.value.toStringAsFixed(2)}')
              ),
              SizedBox(height: 10),
              Text('Set Values:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...widget.component.setValues.entries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: TextFormField(
                  controller: _controllers[entry.key],
                  decoration: InputDecoration(
                    labelText: entry.key,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid number';
                    }
                    return null;
                  },
                ),
              )),
              SizedBox(height: 10),
              Text('Active in Current Step: ${widget.isActiveInCurrentStep ? "Yes" : "No"}'),
              if (widget.currentRecipeStep != null) ...[
                SizedBox(height: 10),
                Text('Current Recipe Step:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('  Type: ${widget.currentRecipeStep!.type}'),
                ...widget.currentRecipeStep!.parameters.entries.map((entry) =>
                    Text('  ${entry.key}: ${entry.value}')
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
        TextButton(
          onPressed: () => _updateSetValues(context),
          child: Text('Update'),
        ),
        TextButton(
          onPressed: () => _toggleComponentActivation(context),
          child: Text(widget.component.isActivated ? 'Deactivate' : 'Activate'),
        ),
      ],
    );
  }

  void _toggleComponentActivation(BuildContext context) {
    final systemProvider = Provider.of<SystemStateProvider>(context, listen: false);
    if (widget.component.isActivated) {
      systemProvider.deactivateComponent(widget.component.name);
    } else {
      systemProvider.activateComponent(widget.component.name);
    }
    Navigator.of(context).pop();
  }
}
