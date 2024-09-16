import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/system_state_provider.dart';

class RecipeProgressIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SystemStateProvider>(
      builder: (context, provider, child) {
        if (provider.activeRecipe == null) {
          return SizedBox.shrink();
        }

        int totalSteps = provider.activeRecipe!.steps.length;
        int currentStep = provider.currentRecipeStepIndex;
        double progress = currentStep / totalSteps;

        return Container(
          width: 250,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Recipe Progress: ${provider.activeRecipe!.name}',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              LinearProgressIndicator(value: progress),
              SizedBox(height: 4),
              Text(
                provider.isSystemRunning
                    ? 'Step ${currentStep + 1} of $totalSteps'
                    : 'Recipe Completed',
                style: TextStyle(color: Colors.white),
              ),
              if (provider.isSystemRunning && currentStep < totalSteps)
                Text(
                  _getStepDescription(provider.activeRecipe!.steps[currentStep]),
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
            ],
          ),
        );
      },
    );
  }

  String _getStepDescription(RecipeStep step) {
    switch (step.type) {
      case StepType.valve:
        return 'Opening ${step.parameters['valveType'] == ValveType.valveA ? 'Valve A' : 'Valve B'} for ${step.parameters['duration']}s';
      case StepType.purge:
        return 'Purging for ${step.parameters['duration']}s';
      case StepType.loop:
        return 'Looping ${step.parameters['iterations']} times';
      case StepType.setParameter:
        return 'Setting ${step.parameters['parameter']} of ${step.parameters['component']} to ${step.parameters['value']}';
      default:
        return 'Unknown step type';
    }
  }
}