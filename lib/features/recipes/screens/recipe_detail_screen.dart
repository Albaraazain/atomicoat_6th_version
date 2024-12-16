

import 'package:experiment_planner/blocs/component/bloc/component_list_event.dart';
import 'package:experiment_planner/blocs/component/bloc/component_list_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/recipe/bloc/recipe_bloc.dart';
import '../../../blocs/recipe/bloc/recipe_event.dart';
import '../../../blocs/recipe/bloc/recipe_state.dart';
import '../../../blocs/component/bloc/component_list_bloc.dart';
import '../models/recipe.dart';

class DarkThemeColors {
  static const Color background = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color primaryText = Color(0xFFE0E0E0);
  static const Color secondaryText = Color(0xFFB0B0B0);
  static const Color accent = Color(0xFF64FFDA);
  static const Color divider = Color(0xFF2A2A2A);
  static const Color inputFill = Color(0xFF2C2C2C);
}

class RecipeDetailScreen extends StatefulWidget {
  final String? recipeId;

  RecipeDetailScreen({this.recipeId});

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen>
    with TickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _substrateController;
  late TextEditingController _chamberTempController;
  late TextEditingController _pressureController;
  List<RecipeStep> _steps = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _substrateController = TextEditingController();
    _chamberTempController = TextEditingController();
    _pressureController = TextEditingController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();

    // Initialize blocs
    context.read<ComponentListBloc>().add(LoadComponents());
    if (widget.recipeId != null) {
      context.read<RecipeBloc>().add(LoadRecipes());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecipeData();
    });
  }

  void _loadRecipeData() {
    if (widget.recipeId != null) {
      final recipeState = context.read<RecipeBloc>().state;
      final recipe = recipeState.recipes.firstWhere(
        (r) => r.id == widget.recipeId,
        orElse: () => Recipe(
          id: widget.recipeId!,
          name: '',
          substrate: '',
          steps: [],
          chamberTemperatureSetPoint: 150.0,
          pressureSetPoint: 1.0,
        ),
      );

      setState(() {
        _nameController.text = recipe.name;
        _substrateController.text = recipe.substrate;
        _chamberTempController.text =
            recipe.chamberTemperatureSetPoint.toString();
        _pressureController.text = recipe.pressureSetPoint.toString();
        _steps = List.from(recipe.steps);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _substrateController.dispose();
    _chamberTempController.dispose();
    _pressureController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecipeBloc, RecipeState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: DarkThemeColors.background,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: DarkThemeColors.background,
      title: Text(
        widget.recipeId == null ? 'Create Recipe' : 'Edit Recipe',
        style: TextStyle(
            color: DarkThemeColors.primaryText, fontWeight: FontWeight.w500),
      ),
      actions: [
        BlocBuilder<RecipeBloc, RecipeState>(
          builder: (context, state) {
            return IconButton(
              icon: Icon(Icons.save, color: DarkThemeColors.accent),
              onPressed: state.isLoading ? null : () => _saveRecipe(context),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return BlocBuilder<RecipeBloc, RecipeState>(
      builder: (context, recipeState) {
        if (recipeState.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        return SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInputs(),
                    SizedBox(height: 24),
                    _buildStepsSection(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBasicInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Recipe Name',
          icon: Icons.title,
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _substrateController,
          label: 'Substrate',
          icon: Icons.layers,
        ),
        SizedBox(height: 24),
        _buildGlobalParametersInputs(),
      ],
    );
  }

  Widget _buildGlobalParametersInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Global Parameters',
          style: TextStyle(
            color: DarkThemeColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _chamberTempController,
          label: 'Chamber Temperature (°C)',
          icon: Icons.thermostat,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _pressureController,
          label: 'Pressure (atm)',
          icon: Icons.compress,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: DarkThemeColors.primaryText),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: DarkThemeColors.secondaryText),
        prefixIcon: Icon(icon, color: DarkThemeColors.accent),
        filled: true,
        fillColor: DarkThemeColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: DarkThemeColors.accent),
        ),
      ),
    );
  }

  Widget _buildStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepsHeader(),
        SizedBox(height: 16),
        _buildStepsList(),
      ],
    );
  }

  Widget _buildStepsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recipe Steps',
          style: TextStyle(
            color: DarkThemeColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.add),
          label: Text('Add Step'),
          style: ElevatedButton.styleFrom(
            foregroundColor: DarkThemeColors.background,
            backgroundColor: DarkThemeColors.accent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => _showAddStepDialog(context),
        ),
      ],
    );
  }

  Widget _buildStepsList() {
    return BlocBuilder<ComponentListBloc, ComponentListState>(
      builder: (context, componentState) {
        return ReorderableListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: _steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            return _buildStepCard(step, index);
          }).toList(),
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final RecipeStep item = _steps.removeAt(oldIndex);
              _steps.insert(newIndex, item);
            });
          },
        );
      },
    );
  }

  Widget _buildStepCard(RecipeStep step, int index) {
    return Card(
      key: ValueKey(step),
      margin: EdgeInsets.only(bottom: 16),
      color: DarkThemeColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        title: Text(
          'Step ${index + 1}: ${_getStepTitle(step)}',
          style: TextStyle(color: DarkThemeColors.primaryText),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepEditor(step),
                if (step.type == StepType.loop) _buildLoopSubSteps(step),
              ],
            ),
          ),
        ],
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: DarkThemeColors.accent),
              onPressed: () => _showEditStepDialog(context, step, index),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteStepDialog(context, index),
            ),
          ],
        ),
      ),
    );
  }

  // show dialog to confirm deletion of a step
  void _showDeleteStepDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Step',
              style: TextStyle(color: DarkThemeColors.primaryText)),
          content: Text(
            'Are you sure you want to delete this step?',
            style: TextStyle(color: DarkThemeColors.primaryText),
          ),
          backgroundColor: DarkThemeColors.cardBackground,
          actions: [
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(color: DarkThemeColors.accent)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Delete',
                  style: TextStyle(color: DarkThemeColors.accent)),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _steps.removeAt(index);
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStepEditor(RecipeStep step) {
    switch (step.type) {
      case StepType.loop:
        return _buildLoopEditor(step);
      case StepType.valve:
        return _buildValveEditor(step);
      case StepType.purge:
        return _buildPurgeEditor(step);
      case StepType.setParameter:
        return _buildSetParameterEditor(step);
      default:
        return Text('Unknown Step Type',
            style: TextStyle(color: DarkThemeColors.primaryText));
    }
  }

  Widget _buildLoopEditor(RecipeStep step) {
    return Column(
      children: [
        _buildNumberInput(
          label: 'Number of iterations',
          value: step.parameters['iterations'],
          onChanged: (value) {
            setState(() {
              step.parameters['iterations'] = value;
            });
          },
        ),
        SizedBox(height: 16),
        _buildNumberInput(
          label: 'Temperature (°C)',
          value: step.parameters['temperature'],
          onChanged: (value) {
            setState(() {
              step.parameters['temperature'] = value;
            });
          },
        ),
        SizedBox(height: 16),
        _buildNumberInput(
          label: 'Pressure (atm)',
          value: step.parameters['pressure'],
          onChanged: (value) {
            setState(() {
              step.parameters['pressure'] = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildValveEditor(RecipeStep step) {
    return Column(
      children: [
        _buildDropdown<ValveType>(
          label: 'Valve',
          value: step.parameters['valveType'],
          items: ValveType.values,
          onChanged: (value) {
            setState(() {
              step.parameters['valveType'] = value;
            });
          },
        ),
        SizedBox(height: 16),
        _buildNumberInput(
          label: 'Duration (seconds)',
          value: step.parameters['duration'],
          onChanged: (value) {
            setState(() {
              step.parameters['duration'] = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPurgeEditor(RecipeStep step) {
    return _buildNumberInput(
      label: 'Duration (seconds)',
      value: step.parameters['duration'],
      onChanged: (value) {
        setState(() {
          step.parameters['duration'] = value;
        });
      },
    );
  }

  Widget _buildSetParameterEditor(RecipeStep step) {
    return BlocBuilder<ComponentListBloc, ComponentListState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final availableComponents = state.components.values.toList();
        final selectedComponent = step.parameters['component'] != null
            ? availableComponents.firstWhere(
                (c) => c.name == step.parameters['component'],
                orElse: () => availableComponents.first,
              )
            : availableComponents.first;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdown<String>(
              label: 'Component',
              value: step.parameters['component'] ?? selectedComponent.name,
              items: availableComponents.map((c) => c.name).toList(),
              onChanged: (value) {
                setState(() {
                  step.parameters['component'] = value;
                  step.parameters['parameter'] = null;
                  step.parameters['value'] = null;
                });
              },
            ),
            if (selectedComponent != null) ...[
              SizedBox(height: 16),
              _buildDropdown<String>(
                label: 'Parameter',
                value: step.parameters['parameter'],
                items: selectedComponent.setValues.keys.toList(),
                onChanged: (value) {
                  setState(() {
                    step.parameters['parameter'] = value;
                    step.parameters['value'] = null;
                  });
                },
              ),
              if (step.parameters['parameter'] != null) ...[
                SizedBox(height: 16),
                _buildNumberInput(
                  label: 'Value',
                  value: step.parameters['value'],
                  onChanged: (value) {
                    setState(() {
                      step.parameters['value'] = value;
                    });
                  },
                ),
              ],
            ],
          ],
        );
      },
    );
  }

  Widget _buildLoopSubSteps(RecipeStep loopStep) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          'Loop Steps:',
          style: TextStyle(
            color: DarkThemeColors.primaryText,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        ...loopStep.subSteps!.asMap().entries.map((entry) {
          int index = entry.key;
          RecipeStep subStep = entry.value;
          return _buildSubStepCard(subStep, index, loopStep);
        }).toList(),
        SizedBox(height: 8),
        ElevatedButton(
          child: Text('Add Loop Step'),
          style: ElevatedButton.styleFrom(
            foregroundColor: DarkThemeColors.background,
            backgroundColor: DarkThemeColors.accent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => _showAddStepDialog(context, parentStep: loopStep),
        ),
      ],
    );
  }

  Widget _buildSubStepCard(RecipeStep step, int index, RecipeStep parentStep) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      color: DarkThemeColors.inputFill,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        title: Text(
          'Substep ${index + 1}: ${_getStepTitle(step)}',
          style: TextStyle(color: DarkThemeColors.primaryText, fontSize: 14),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: DarkThemeColors.accent),
              onPressed: () => _showEditStepDialog(
                context,
                step,
                index,
                parentStep: parentStep,
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  parentStep.subSteps!.removeAt(index);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required Function(T?) onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label,
              style: TextStyle(color: DarkThemeColors.secondaryText)),
        ),
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<T>(
            value: value,
            onChanged: onChanged,
            items: items.map((T item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  item.toString(),
                  style: TextStyle(color: DarkThemeColors.primaryText),
                ),
              );
            }).toList(),
            dropdownColor: DarkThemeColors.cardBackground,
            decoration: InputDecoration(
              filled: true,
              fillColor: DarkThemeColors.inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberInput({
    required String label,
    required dynamic value,
    required Function(dynamic) onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label,
              style: TextStyle(color: DarkThemeColors.secondaryText)),
        ),
        Expanded(
          flex: 3,
          child: TextFormField(
            initialValue: value?.toString() ?? '',
            style: TextStyle(color: DarkThemeColors.primaryText),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              filled: true,
              fillColor: DarkThemeColors.inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            onChanged: (newValue) {
              onChanged(num.tryParse(newValue));
            },
          ),
        ),
      ],
    );
  }

  void _showEditStepDialog(BuildContext context, RecipeStep step, int index,
      {RecipeStep? parentStep}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Step',
              style: TextStyle(color: DarkThemeColors.primaryText)),
          content: SingleChildScrollView(
            child: _buildStepEditor(step),
          ),
          backgroundColor: DarkThemeColors.cardBackground,
          actions: [
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(color: DarkThemeColors.accent)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child:
                  Text('Save', style: TextStyle(color: DarkThemeColors.accent)),
              onPressed: () {
                Navigator.pop(context);
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddStepDialog(BuildContext context, {RecipeStep? parentStep}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: DarkThemeColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Add Step',
                    style: TextStyle(
                        color: DarkThemeColors.primaryText,
                        fontWeight: FontWeight.bold)),
              ),
              _buildStepTypeOption(
                context,
                'Loop',
                Icons.loop,
                StepType.loop,
                parentStep,
              ),
              _buildStepTypeOption(
                context,
                'Valve',
                Icons.arrow_forward,
                StepType.valve,
                parentStep,
              ),
              _buildStepTypeOption(
                context,
                'Purge',
                Icons.air,
                StepType.purge,
                parentStep,
              ),
              _buildStepTypeOption(
                context,
                'Set Parameter',
                Icons.settings,
                StepType.setParameter,
                parentStep,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepTypeOption(
    BuildContext context,
    String title,
    IconData icon,
    StepType type,
    RecipeStep? parentStep,
  ) {
    return ListTile(
      leading: Icon(icon, color: DarkThemeColors.accent),
      title: Text(title, style: TextStyle(color: DarkThemeColors.primaryText)),
      onTap: () {
        Navigator.pop(context);
        _addStep(type, parentStep?.subSteps ?? _steps);
      },
    );
  }

  void _addStep(StepType type, List<RecipeStep> steps) {
    setState(() {
      switch (type) {
        case StepType.loop:
          steps.add(RecipeStep(
            type: StepType.loop,
            parameters: {
              'iterations': 1,
              'temperature': null,
              'pressure': null
            },
            subSteps: [],
          ));
          break;
        case StepType.valve:
          steps.add(RecipeStep(
            type: StepType.valve,
            parameters: {'valveType': ValveType.valveA, 'duration': 5},
          ));
          break;
        case StepType.purge:
          steps.add(RecipeStep(
            type: StepType.purge,
            parameters: {'duration': 10},
          ));
          break;
        case StepType.setParameter:
          final componentState = context.read<ComponentListBloc>().state;
          final availableComponents = componentState.components.values.toList();

          if (availableComponents.isNotEmpty) {
            final firstComponent = availableComponents.first;
            steps.add(RecipeStep(
              type: StepType.setParameter,
              parameters: {
                'component': firstComponent.name,
                'parameter': null,
                'value': null,
              },
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No components available')),
            );
          }
          break;
      }
    });
  }

  String _getStepTitle(RecipeStep step) {
    switch (step.type) {
      case StepType.loop:
        return 'Loop ${step.parameters['iterations']} times';
      case StepType.valve:
        return '${step.parameters['valveType'] == ValveType.valveA ? 'Valve A' : 'Valve B'} '
            'for ${step.parameters['duration']}s';
      case StepType.purge:
        return 'Purge for ${step.parameters['duration']}s';
      case StepType.setParameter:
        return 'Set ${step.parameters['component']} ${step.parameters['parameter']} '
            'to ${step.parameters['value']}';
      default:
        return 'Unknown Step';
    }
  }

  void _saveRecipe(BuildContext context) {
    final errors = _validateRecipe();
    if (errors.isNotEmpty) {
      _showValidationErrors(errors);
      return;
    }

    final newRecipe = Recipe(
      id: widget.recipeId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      substrate: _substrateController.text,
      steps: _steps,
      chamberTemperatureSetPoint:
          double.tryParse(_chamberTempController.text) ?? 150.0,
      pressureSetPoint: double.tryParse(_pressureController.text) ?? 1.0,
    );

    if (widget.recipeId == null) {
      context.read<RecipeBloc>().add(AddRecipe(newRecipe));
    } else {
      context.read<RecipeBloc>().add(UpdateRecipe(newRecipe));
    }
  }

  List<String> _validateRecipe() {
    final errors = <String>[];

    if (_nameController.text.isEmpty) {
      errors.add('Recipe name is required');
    }

    if (_substrateController.text.isEmpty) {
      errors.add('Substrate is required');
    }

    if (_steps.isEmpty) {
      errors.add('At least one step is required');
    }

    // Validate all steps
    for (var i = 0; i < _steps.length; i++) {
      final stepErrors = _validateStep(_steps[i], i + 1);
      errors.addAll(stepErrors);
    }

    return errors;
  }

  List<String> _validateStep(RecipeStep step, int stepNumber) {
    final errors = <String>[];
    final prefix = 'Step $stepNumber:';

    switch (step.type) {
      case StepType.loop:
        if (step.parameters['iterations'] == null ||
            step.parameters['iterations'] <= 0) {
          errors.add('$prefix Loop iterations must be greater than 0');
        }
        if (step.subSteps == null || step.subSteps!.isEmpty) {
          errors.add('$prefix Loop must contain at least one step');
        } else {
          for (var i = 0; i < step.subSteps!.length; i++) {
            final subErrors = _validateStep(step.subSteps![i], i + 1);
            errors.addAll(subErrors.map((e) => '$prefix Substep $e'));
          }
        }
        break;

      case StepType.valve:
        if (step.parameters['duration'] == null ||
            step.parameters['duration'] <= 0) {
          errors.add('$prefix Valve duration must be greater than 0');
        }
        if (step.parameters['valveType'] == null) {
          errors.add('$prefix Valve type must be selected');
        }
        break;

      case StepType.purge:
        if (step.parameters['duration'] == null ||
            step.parameters['duration'] <= 0) {
          errors.add('$prefix Purge duration must be greater than 0');
        }
        break;

      case StepType.setParameter:
        if (step.parameters['component'] == null) {
          errors.add('$prefix Component must be selected');
        }
        if (step.parameters['parameter'] == null) {
          errors.add('$prefix Parameter must be selected');
        }
        if (step.parameters['value'] == null) {
          errors.add('$prefix Value must be set');
        }
        break;
    }

    return errors;
  }

  void _showValidationErrors(List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Validation Errors',
          style: TextStyle(color: DarkThemeColors.primaryText),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: errors
                .map((error) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '• $error',
                        style: TextStyle(color: DarkThemeColors.primaryText),
                      ),
                    ))
                .toList(),
          ),
        ),
        backgroundColor: DarkThemeColors.cardBackground,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: DarkThemeColors.accent)),
          ),
        ],
      ),
    );
  }
}
