import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/system_state_provider.dart';

class SubstrateStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SystemStateProvider>(
      builder: (context, systemStateProvider, child) {
        final activeRecipe = systemStateProvider.activeRecipe;
        final isSystemRunning = systemStateProvider.isSystemRunning;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Substrate Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                _buildSubstrateInfo(activeRecipe?.substrate),
                SizedBox(height: 16),
                _buildProcessingStatus(isSystemRunning, systemStateProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubstrateInfo(String? substrate) {
    return Row(
      children: [
        Icon(Icons.science, size: 24),
        SizedBox(width: 8),
        Text(
          'Current Substrate: ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(substrate ?? 'No substrate loaded'),
      ],
    );
  }

  Widget _buildProcessingStatus(bool isSystemRunning, SystemStateProvider provider) {
    if (!isSystemRunning) {
      return Text('System not running');
    }

    final totalSteps = provider.activeRecipe?.steps.length ?? 0;
    final currentStep = provider.currentRecipeStepIndex + 1;
    final progress = totalSteps > 0 ? currentStep / totalSteps : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Processing Status:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        SizedBox(height: 8),
        Text('Step $currentStep of $totalSteps'),
        SizedBox(height: 8),
        Text('Estimated time remaining: ${_estimateRemainingTime(provider)}'),
      ],
    );
  }

  String _estimateRemainingTime(SystemStateProvider provider) {
    // This is a simplified estimation. You might want to implement a more accurate
    // calculation based on the actual recipe steps and their durations.
    final totalSteps = provider.activeRecipe?.steps.length ?? 0;
    final currentStep = provider.currentRecipeStepIndex + 1;
    final remainingSteps = totalSteps - currentStep;

    // Assume an average of 30 seconds per step
    final estimatedSeconds = remainingSteps * 30;

    if (estimatedSeconds < 60) {
      return '$estimatedSeconds seconds';
    } else if (estimatedSeconds < 3600) {
      final minutes = (estimatedSeconds / 60).round();
      return '$minutes minutes';
    } else {
      final hours = (estimatedSeconds / 3600).round();
      return '$hours hours';
    }
  }
}