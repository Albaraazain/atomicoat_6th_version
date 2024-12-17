import 'package:experiment_planner/features/recipes/models/recipe.dart';

class RecipeDebug {
  static Map<String, dynamic> validateRecipeData(Recipe recipe) {
    final issues = <String, List<String>>{
      'critical': [],
      'warnings': [],
    };

    // Check required fields
    if (recipe.id.isEmpty) issues['critical']!.add('Recipe ID is empty');
    if (recipe.name.isEmpty) issues['critical']!.add('Recipe name is empty');
    if (recipe.substrate.isEmpty) issues['critical']!.add('Substrate is empty');
    if (recipe.steps.isEmpty) issues['critical']!.add('No steps defined');

    // Check parameter ranges
    if (recipe.chamberTemperatureSetPoint < 0 || recipe.chamberTemperatureSetPoint > 1000) {
      issues['warnings']!.add('Chamber temperature may be out of normal range');
    }
    if (recipe.pressureSetPoint <= 0 || recipe.pressureSetPoint > 10) {
      issues['warnings']!.add('Pressure may be out of normal range');
    }

    // Validate steps
    for (var i = 0; i < recipe.steps.length; i++) {
      final stepIssues = _validateStep(recipe.steps[i], i);
      issues['critical']!.addAll(stepIssues['critical']!);
      issues['warnings']!.addAll(stepIssues['warnings']!);
    }

    return issues;
  }

  static Map<String, List<String>> _validateStep(RecipeStep step, int index) {
    final issues = {
      'critical': <String>[],
      'warnings': <String>[],
    };

    switch (step.type) {
      case StepType.valve:
        if (!step.parameters.containsKey('duration')) {
          issues['critical']!.add('Step ${index + 1}: Missing valve duration');
        }
        if (!step.parameters.containsKey('valveType')) {
          issues['critical']!.add('Step ${index + 1}: Missing valve type');
        }
        break;

      case StepType.purge:
        if (!step.parameters.containsKey('duration')) {
          issues['critical']!.add('Step ${index + 1}: Missing purge duration');
        }
        final duration = step.parameters['duration'] as num?;
        if (duration != null && duration > 300) { // 5 minutes
          issues['warnings']!.add('Step ${index + 1}: Long purge duration (${duration}s)');
        }
        break;

      case StepType.loop:
        if (!step.parameters.containsKey('iterations')) {
          issues['critical']!.add('Step ${index + 1}: Missing loop iterations');
        }
        if (step.subSteps == null || step.subSteps!.isEmpty) {
          issues['critical']!.add('Step ${index + 1}: Empty loop step');
        } else {
          for (var i = 0; i < step.subSteps!.length; i++) {
            final subIssues = _validateStep(step.subSteps![i], i);
            issues['critical']!.addAll(
              subIssues['critical']!.map((e) => 'Step ${index + 1} (Sub $i): $e')
            );
            issues['warnings']!.addAll(
              subIssues['warnings']!.map((e) => 'Step ${index + 1} (Sub $i): $e')
            );
          }
        }
        break;

      case StepType.setParameter:
        if (!step.parameters.containsKey('component')) {
          issues['critical']!.add('Step ${index + 1}: Missing component');
        }
        if (!step.parameters.containsKey('parameter')) {
          issues['critical']!.add('Step ${index + 1}: Missing parameter name');
        }
        if (!step.parameters.containsKey('value')) {
          issues['critical']!.add('Step ${index + 1}: Missing parameter value');
        }
        break;
    }

    return issues;
  }

  static String prettyPrintRecipe(Recipe recipe) {
    final buffer = StringBuffer();
    buffer.writeln('Recipe: ${recipe.name} (ID: ${recipe.id})');
    buffer.writeln('Substrate: ${recipe.substrate}');
    buffer.writeln('Chamber Temperature: ${recipe.chamberTemperatureSetPoint}°C');
    buffer.writeln('Pressure: ${recipe.pressureSetPoint} atm');
    buffer.writeln('Steps:');

    _printSteps(recipe.steps, buffer, indent: 2);

    return buffer.toString();
  }

  static void _printSteps(List<RecipeStep> steps, StringBuffer buffer, {int indent = 0}) {
    final padding = ' ' * indent;
    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      buffer.writeln('$padding${i + 1}. ${_stepToString(step)}');

      if (step.type == StepType.loop && step.subSteps != null) {
        buffer.writeln('$padding   Sub-steps:');
        _printSteps(step.subSteps!, buffer, indent: indent + 4);
      }
    }
  }

  static String _stepToString(RecipeStep step) {
    switch (step.type) {
      case StepType.valve:
        return 'Valve (${step.parameters['valveType']}) for ${step.parameters['duration']}s';
      case StepType.purge:
        return 'Purge for ${step.parameters['duration']}s';
      case StepType.loop:
        return 'Loop ${step.parameters['iterations']} times';
      case StepType.setParameter:
        return 'Set ${step.parameters['component']} ${step.parameters['parameter']} to ${step.parameters['value']}';
    }
  }
}
