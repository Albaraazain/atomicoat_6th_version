// lib/modules/system_operation_also_main_module/widgets/recipe_progress_indicator.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/recipe/bloc/recipe_bloc.dart';
import '../../../blocs/recipe/bloc/recipe_state.dart';
import '../models/recipe.dart';

class RecipeProgressIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecipeBloc, RecipeState>(
      builder: (context, state) {
        if (state.activeRecipe == null) {
          return SizedBox.shrink();
        }

        int totalSteps = state.activeRecipe!.steps.length;
        int currentStep = state.currentStepIndex;
        double progress = totalSteps > 0 ? currentStep / totalSteps : 0.0;

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
                'Recipe Progress: ${state.activeRecipe!.name}',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              LinearProgressIndicator(value: progress),
              SizedBox(height: 4),
              Text(
                state.executionStatus == RecipeExecutionStatus.running
                    ? 'Step ${currentStep + 1} of $totalSteps'
                    : _getStatusText(state.executionStatus),
                style: TextStyle(color: Colors.white),
              ),
              if (state.executionStatus == RecipeExecutionStatus.running &&
                  currentStep < totalSteps)
                Text(
                  _getStepDescription(state.activeRecipe!.steps[currentStep]),
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
            ],
          ),
        );
      },
    );
  }

  String _getStatusText(RecipeExecutionStatus status) {
    switch (status) {
      case RecipeExecutionStatus.completed:
        return 'Recipe Completed';
      case RecipeExecutionStatus.paused:
        return 'Recipe Paused';
      case RecipeExecutionStatus.error:
        return 'Recipe Error';
      case RecipeExecutionStatus.idle:
        return 'Recipe Ready';
      case RecipeExecutionStatus.running:
        return 'Recipe Running';
    }
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