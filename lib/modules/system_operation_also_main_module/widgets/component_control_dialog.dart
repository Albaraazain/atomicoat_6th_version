import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/system_component.dart';
import '../models/recipe.dart';
import '../providers/system_state_provider.dart';

class ComponentControlDialog extends StatelessWidget {
  final SystemComponent component;
  final bool isActiveInCurrentStep;
  final RecipeStep? currentRecipeStep;

  ComponentControlDialog({
    required this.component,
    required this.isActiveInCurrentStep,
    this.currentRecipeStep,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(component.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Status: ${component.isActivated ? "Active" : "Inactive"}'),
            SizedBox(height: 10),
            Text('Current Values:'),
            ...component.currentValues.entries.map((entry) =>
                Text('  ${entry.key}: ${entry.value.toStringAsFixed(2)}')
            ),
            SizedBox(height: 10),
            Text('Set Values:'),
            ...component.setValues.entries.map((entry) =>
                Text('  ${entry.key}: ${entry.value.toStringAsFixed(2)}')
            ),
            SizedBox(height: 10),
            Text('Active in Current Step: ${isActiveInCurrentStep ? "Yes" : "No"}'),
            if (currentRecipeStep != null) ...[
              SizedBox(height: 10),
              Text('Current Recipe Step:'),
              Text('  Type: ${currentRecipeStep!.type}'),
              ...currentRecipeStep!.parameters.entries.map((entry) =>
                  Text('  ${entry.key}: ${entry.value}')
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
        TextButton(
          onPressed: () => _toggleComponentActivation(context),
          child: Text(component.isActivated ? 'Deactivate' : 'Activate'),
        ),
      ],
    );
  }

  void _toggleComponentActivation(BuildContext context) {
    final systemProvider = Provider.of<SystemStateProvider>(context, listen: false);
    if (component.isActivated) {
      systemProvider.deactivateComponent(component.name);
    } else {
      systemProvider.activateComponent(component.name);
    }
    Navigator.of(context).pop();
  }
}