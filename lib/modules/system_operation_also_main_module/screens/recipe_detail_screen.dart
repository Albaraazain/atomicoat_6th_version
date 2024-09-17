import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../models/system_component.dart';
import '../providers/recipe_provider.dart';
import '../providers/system_state_provider.dart';

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

class _RecipeDetailScreenState extends State<RecipeDetailScreen> with TickerProviderStateMixin {
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
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecipeData();
    });
  }

  void _loadRecipeData() {
    if (widget.recipeId != null) {
      final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
      final recipe = recipeProvider.getRecipeById(widget.recipeId!);
      if (recipe != null) {
        setState(() {
          _nameController.text = recipe.name;
          _substrateController.text = recipe.substrate;
          _chamberTempController.text = recipe.chamberTemperatureSetPoint.toString();
          _pressureController.text = recipe.pressureSetPoint.toString();
          _steps = List.from(recipe.steps);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recipe not found'), backgroundColor: Colors.red),
        );
      }
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
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, child) {
        return Scaffold(
          backgroundColor: DarkThemeColors.background,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: DarkThemeColors.background,
            title: Text(
              widget.recipeId == null ? 'Create Recipe' : 'Edit Recipe',
              style: TextStyle(color: DarkThemeColors.primaryText, fontWeight: FontWeight.w500),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.save, color: DarkThemeColors.accent),
                onPressed: () => _saveRecipe(recipeProvider),
              ),
            ],
          ),
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRecipeNameInput(),
                      SizedBox(height: 16),
                      _buildSubstrateInput(),
                      SizedBox(height: 24),
                      _buildGlobalParametersInputs(),
                      SizedBox(height: 24),
                      _buildStepsHeader(),
                      SizedBox(height: 16),
                      _buildStepsList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecipeNameInput() {
    return _buildTextField(
      controller: _nameController,
      label: 'Recipe Name',
      icon: Icons.title,
    );
  }

  Widget _buildSubstrateInput() {
    return _buildTextField(
      controller: _substrateController,
      label: 'Substrate',
      icon: Icons.layers,
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
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: DarkThemeColors.primaryText),
      keyboardType: keyboardType,
      onChanged: onChanged,
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

  String _getStepTitle(RecipeStep step) {
    switch (step.type) {
      case StepType.loop:
        return 'Loop ${step.parameters['iterations']} times';
      case StepType.valve:
        return '${step.parameters['valveType'] == ValveType.valveA ? 'Valve A' : 'Valve B'} for ${step.parameters['duration']}s';
      case StepType.purge:
        return 'Purge for ${step.parameters['duration']}s';
      case StepType.setParameter:
        return 'Set ${step.parameters['component']} ${step.parameters['parameter']} to ${step.parameters['value']}';
      default:
        return 'Unknown Step';
    }
  }

  Widget _buildStepEditor(RecipeStep step) {
    switch (step.type) {
      case StepType.loop:
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
      case StepType.valve:
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
      case StepType.purge:
        return _buildNumberInput(
          label: 'Duration (seconds)',
          value: step.parameters['duration'],
          onChanged: (value) {
            setState(() {
              step.parameters['duration'] = value;
            });
          },
        );
      case StepType.setParameter:
        return _buildSetParameterEditor(step);
      default:
        return Text('Unknown Step Type', style: TextStyle(color: DarkThemeColors.primaryText));
    }
  }

  Widget _buildSetParameterEditor(RecipeStep step) {
    final systemStateProvider = Provider.of<SystemStateProvider>(context, listen: false);
    final availableComponents = systemStateProvider.components.values.toList();

    SystemComponent? selectedComponent = step.parameters['component'] != null
        ? availableComponents.firstWhere((c) => c.name == step.parameters['component'])
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown<SystemComponent>(
          label: 'Component',
          value: selectedComponent,
          items: availableComponents,
          onChanged: (value) {
            setState(() {
              step.parameters['component'] = value?.name;
              step.parameters['parameter'] = null; // Reset parameter when component changes
              step.parameters['value'] = null; // Reset value when component changes
            });
          },
          itemToString: (component) => component.name,
        ),
        SizedBox(height: 16),
        if (selectedComponent != null)
          _buildDropdown<String>(
            label: 'Parameter',
            value: step.parameters['parameter'],
            items: selectedComponent.setValues.keys.toList(),
            onChanged: (value) {
              setState(() {
                step.parameters['parameter'] = value;
                step.parameters['value'] = null; // Reset value when parameter changes
              });
            },
          ),
        SizedBox(height: 16),
        if (step.parameters['parameter'] != null)
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
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required Function(T?) onChanged,
    String Function(T)? itemToString,
  }) {
    return Row(
      children: [
      Expanded(
      flex: 2,
      child: Text(label, style: TextStyle(color: DarkThemeColors.secondaryText)),
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
            itemToString != null ? itemToString(item) : item.toString(),
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
          child: Text(label, style: TextStyle(color: DarkThemeColors.secondaryText)),
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
          style: TextStyle(
            color: DarkThemeColors.primaryText,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: DarkThemeColors.accent),
              onPressed: () {
                _showEditStepDialog(context, step, index, parentStep: parentStep);
              },
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
                title: Text('Add Step', style: TextStyle(color: DarkThemeColors.primaryText, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: Icon(Icons.loop, color: DarkThemeColors.accent),
                title: Text('Loop', style: TextStyle(color: DarkThemeColors.primaryText)),
                onTap: () {
                  Navigator.pop(context);
                  _addStep(StepType.loop, parentStep?.subSteps ?? _steps);
                },
              ),
              ListTile(
                leading: Icon(Icons.arrow_forward, color: DarkThemeColors.accent),
                title: Text('Valve', style: TextStyle(color: DarkThemeColors.primaryText)),
                onTap: () {
                  Navigator.pop(context);
                  _addStep(StepType.valve, parentStep?.subSteps ?? _steps);
                },
              ),
              ListTile(
                leading: Icon(Icons.air, color: DarkThemeColors.accent),
                title: Text('Purge', style: TextStyle(color: DarkThemeColors.primaryText)),
                onTap: () {
                  Navigator.pop(context);
                  _addStep(StepType.purge, parentStep?.subSteps ?? _steps);
                },
              ),
              ListTile(
                leading: Icon(Icons.settings, color: DarkThemeColors.accent),
                title: Text('Set Parameter', style: TextStyle(color: DarkThemeColors.primaryText)),
                onTap: () {
                  Navigator.pop(context);
                  _addStep(StepType.setParameter, parentStep?.subSteps ?? _steps);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _addStep(StepType type, List<RecipeStep> steps) {
    setState(() {
      switch (type) {
        case StepType.loop:
          steps.add(RecipeStep(
            type: StepType.loop,
            parameters: {'iterations': 1, 'temperature': null, 'pressure': null},
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
          final systemStateProvider = Provider.of<SystemStateProvider>(context, listen: false);
          final availableComponents = systemStateProvider.components.values.toList();
          if (availableComponents.isNotEmpty) {
            final firstComponent = availableComponents.first;
            final availableParameters = firstComponent.setValues.keys.toList();
            steps.add(RecipeStep(
              type: StepType.setParameter,
              parameters: {
                'component': firstComponent.name,
                'parameter': availableParameters.isNotEmpty ? availableParameters.first : null,
                'value': null,
              },
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No components available to set parameters.')),
            );
          }
          break;
      }
    });
  }

  void _showEditStepDialog(BuildContext context, RecipeStep step, int index, {RecipeStep? parentStep}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Step', style: TextStyle(color: DarkThemeColors.primaryText)),
          content: SingleChildScrollView(
            child: _buildStepEditor(step),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: DarkThemeColors.accent)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save', style: TextStyle(color: DarkThemeColors.accent)),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
          backgroundColor: DarkThemeColors.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        );
      },
    );
  }

  void _showDeleteStepDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Step', style: TextStyle(color: DarkThemeColors.primaryText)),
          content: Text('Are you sure you want to delete this step?', style: TextStyle(color: DarkThemeColors.primaryText)),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: DarkThemeColors.accent)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _steps.removeAt(index);
                });
              },
            ),
          ],
          backgroundColor: DarkThemeColors.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        );
      },
    );
  }

  void _saveRecipe(RecipeProvider recipeProvider) async {
    if (_nameController.text.isEmpty) {
      _showValidationError('Please enter a recipe name');
      return;
    }

    if (_substrateController.text.isEmpty) {
      _showValidationError('Please enter a substrate');
      return;
    }

    if (_steps.isEmpty) {
      _showValidationError('Please add at least one step to the recipe');
      return;
    }

    final newRecipe = Recipe(
      id: widget.recipeId ?? DateTime
          .now()
          .millisecondsSinceEpoch
          .toString(),
      name: _nameController.text,
      substrate: _substrateController.text,
      steps: _steps,
      chamberTemperatureSetPoint: double.tryParse(
          _chamberTempController.text) ?? 150.0,
      pressureSetPoint: double.tryParse(_pressureController.text) ?? 1.0,
    );

    try {
      if (widget.recipeId == null) {
        await recipeProvider.addRecipe(newRecipe);
      } else {
        await recipeProvider.updateRecipe(newRecipe);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recipe saved successfully'),
          backgroundColor: DarkThemeColors.accent,
        ),
      );

      // Use Navigator.of(context).pop() only once
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving recipe: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}