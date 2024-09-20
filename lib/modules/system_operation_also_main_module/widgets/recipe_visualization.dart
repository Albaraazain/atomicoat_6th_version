import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/system_state_provider.dart';
import '../models/recipe.dart';

class RecipeVisualization extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SystemStateProvider>(
      builder: (context, systemStateProvider, child) {
        Recipe? activeRecipe = systemStateProvider.activeRecipe;
        int currentStepIndex = systemStateProvider.currentRecipeStepIndex;

        if (activeRecipe == null) {
          return Center(child: Text('No active recipe'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Active Recipe: ${activeRecipe.name}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: activeRecipe.steps.length,
                itemBuilder: (context, index) {
                  final step = activeRecipe.steps[index];
                  final isCurrentStep = index == currentStepIndex;
                  return ListTile(
                    leading: Icon(
                      isCurrentStep ? Icons.play_arrow : Icons.circle,
                      color: isCurrentStep ? Colors.green : Colors.grey,
                    ),
                    title: Text(_getStepDescription(step)),
                    tileColor: isCurrentStep ? Colors.green.withOpacity(0.1) : null,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LinearProgressIndicator(
                value: (currentStepIndex + 1) / activeRecipe.steps.length,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getStepDescription(RecipeStep step) {
    switch (step.type) {
      case StepType.valve:
        return 'Open ${step.parameters['valveType']} for ${step.parameters['duration']} seconds';
      case StepType.purge:
        return 'Purge for ${step.parameters['duration']} seconds';
      case StepType.loop:
        return 'Loop ${step.parameters['iterations']} times';
      case StepType.setParameter:
        return 'Set ${step.parameters['parameter']} of ${step.parameters['component']} to ${step.parameters['value']}';
      default:
        return 'Unknown step type';
    }
  }
}