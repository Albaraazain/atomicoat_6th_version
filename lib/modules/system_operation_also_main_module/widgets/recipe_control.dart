// lib/modules/system_operation_also_main_module/widgets/recipe_control.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/recipe/bloc/recipe_bloc.dart';
import '../../../blocs/recipe/bloc/recipe_event.dart';
import '../../../blocs/recipe/bloc/recipe_state.dart';
import '../../../blocs/system_state/bloc/system_state_bloc.dart';
import '../../../blocs/system_state/bloc/system_state_event.dart';
import '../../../blocs/system_state/bloc/system_state_state.dart';
import '../models/recipe.dart';

class RecipeControl extends StatelessWidget {
  const RecipeControl({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SystemStateBloc, SystemStateState>(
      builder: (context, systemState) {
        return BlocBuilder<RecipeBloc, RecipeState>(
          builder: (context, recipeState) {
            return Opacity(
              opacity: 0.7,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRecipeSelector(context, recipeState, systemState),
                    SizedBox(height: 4),
                    _buildRecipeControls(context, recipeState, systemState),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecipeControls(
    BuildContext context,
    RecipeState recipeState,
    SystemStateState systemState,
  ) {
    final canStart = systemState.canStart &&
                    recipeState.activeRecipe == null &&
                    recipeState.isExecutionReady;
    final canStop = systemState.canStop &&
                   recipeState.executionStatus == RecipeExecutionStatus.running;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildControlButton(
              onPressed: canStart && recipeState.activeRecipe != null
                ? () => _startRecipe(context, recipeState.activeRecipe!.id)
                : null,
              child: Icon(Icons.play_arrow, color: Colors.white, size: 18),
              color: Colors.green,
            ),
            SizedBox(width: 8),
            _buildControlButton(
              onPressed: canStop
                ? () => context.read<RecipeBloc>().add(StopRecipeExecution())
                : null,
              child: Icon(Icons.stop, color: Colors.white, size: 18),
              color: Colors.red,
            ),
          ],
        ),
        SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _checkSystemStatus(context, systemState),
          icon: Icon(Icons.check_circle_outline, size: 16),
          label: Text('Check System Status', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildRecipeSelector(
    BuildContext context,
    RecipeState recipeState,
    SystemStateState systemState,
  ) {
    return Container(
      width: 150,
      child: DropdownButton<String>(
        isExpanded: true,
        value: recipeState.activeRecipe?.id,
        hint: Text('Select recipe',
            style: TextStyle(color: Colors.white70, fontSize: 12)),
        style: TextStyle(color: Colors.white, fontSize: 12),
        dropdownColor: Colors.black87,
        underline: Container(
          height: 1,
          color: Colors.white70,
        ),
        onChanged: systemState.isSystemRunning
            ? null
            : (String? newValue) {
                if (newValue != null) {
                  context.read<RecipeBloc>().add(StartRecipeExecution(newValue));
                }
              },
        items: recipeState.recipes.map<DropdownMenuItem<String>>((Recipe recipe) {
          return DropdownMenuItem<String>(
            value: recipe.id,
            child: Text(recipe.name, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
      ),
    );
  }

  void _checkSystemStatus(BuildContext context, SystemStateState systemState) {
    final issues = systemState.systemIssues;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            issues.isEmpty ? 'System Ready' : 'System Issues Found',
            style: TextStyle(
              color: issues.isEmpty ? Colors.green : Colors.orange,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: issues.isEmpty
                  ? [Text('All system checks passed. Ready to execute recipe.')]
                  : [
                      Text('The following issues were found:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 12),
                      ...issues.map((issue) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning, color: Colors.orange, size: 20),
                            SizedBox(width: 8),
                            Expanded(child: Text(issue)),
                          ],
                        ),
                      )),
                    ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControlButton({
    required VoidCallback? onPressed,
    required Widget child,
    required Color color,
  }) {
    return SizedBox(
      width: 30,
      height: 30,
      child: ElevatedButton(
        onPressed: onPressed,
        child: child,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  void _startRecipe(BuildContext context, String recipeId) {
    final systemState = context.read<SystemStateBloc>().state;

    if (!systemState.isReadinessCheckPassed) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('System Not Ready'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('The following issues need to be resolved:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  ...systemState.systemIssues.map((issue) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Expanded(child: Text(issue)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    } else {
      context.read<RecipeBloc>().add(StartRecipeExecution(recipeId));
    }
  }
}