// lib/modules/system_operation_also_main_module/widgets/component_control_overlay.dart

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../blocs/component/bloc/component_list_bloc.dart';
import '../../../blocs/component/bloc/component_list_state.dart';
import '../../../blocs/recipe/bloc/recipe_bloc.dart';
import '../../../blocs/recipe/bloc/recipe_state.dart';
import '../models/recipe.dart';
import '../models/system_component.dart';
import 'component_control_dialog.dart';

class ComponentControlOverlay extends StatefulWidget {
  final String overlayId;

  ComponentControlOverlay({required this.overlayId});

  @override
  _ComponentControlOverlayState createState() => _ComponentControlOverlayState();
}

class _ComponentControlOverlayState extends State<ComponentControlOverlay> {
  Map<String, Offset> _componentPositions = {};
  Size? _overlaySize;
  final GlobalKey _overlayKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadComponentPositions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateOverlaySize();
    });
  }

  void _updateOverlaySize() {
    final RenderBox? renderBox = _overlayKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _overlaySize = renderBox.size;
      });
      if (_componentPositions.isEmpty) {
        _resetPositions();
      }
    }
  }

  void _loadComponentPositions() async {
    final prefs = await SharedPreferences.getInstance();
    final positionsJson = prefs.getString('component_positions_${widget.overlayId}');
    if (positionsJson != null) {
      setState(() {
        _componentPositions = Map.fromEntries(
          (json.decode(positionsJson) as Map<String, dynamic>).entries.map(
                (entry) => MapEntry(
              entry.key,
              Offset(entry.value['dx'], entry.value['dy']),
            ),
          ),
        );
      });
    }
  }

  void _saveComponentPositions() async {
    final prefs = await SharedPreferences.getInstance();
    final positionsJson = json.encode(
      _componentPositions.map(
        (key, value) => MapEntry(key, {'dx': value.dx, 'dy': value.dy}),
      ),
    );
    await prefs.setString('component_positions_${widget.overlayId}', positionsJson);
  }

  void _resetPositions() {
    if (_overlaySize == null) return;
    setState(() {
      _componentPositions = {
        'Nitrogen Generator': Offset(_overlaySize!.width * 0.2, _overlaySize!.height * 0.5),
        'MFC': Offset(_overlaySize!.width * 0.35, _overlaySize!.height * 0.5),
        'Valve 1': Offset(_overlaySize!.width * 0.5, _overlaySize!.height * 0.3),
        'Valve 2': Offset(_overlaySize!.width * 0.5, _overlaySize!.height * 0.7),
        'Reaction Chamber': Offset(_overlaySize!.width * 0.65, _overlaySize!.height * 0.5),
        'Pressure Control System': Offset(_overlaySize!.width * 0.8, _overlaySize!.height * 0.3),
        'Vacuum Pump': Offset(_overlaySize!.width * 0.8, _overlaySize!.height * 0.7),
        'Precursor Heater 1': Offset(_overlaySize!.width * 0.25, _overlaySize!.height * 0.3),
        'Precursor Heater 2': Offset(_overlaySize!.width * 0.25, _overlaySize!.height * 0.7),
        'Frontline Heater': Offset(_overlaySize!.width * 0.75, _overlaySize!.height * 0.3),
        'Backline Heater': Offset(_overlaySize!.width * 0.75, _overlaySize!.height * 0.7),
      };
    });
    _saveComponentPositions();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ComponentListBloc, ComponentListState>(
      builder: (context, componentListState) {
        return BlocBuilder<RecipeBloc, RecipeState>(
          builder: (context, recipeState) {
            return Container(
              key: _overlayKey,
              child: Stack(
                children: [
                  ...componentListState.components.entries.map((entry) {
                    final componentName = entry.key;
                    final component = entry.value;
                    return _buildDraggableComponent(
                      componentName,
                      component,
                      recipeState,
                    );
                  }).toList(),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton(
                      mini: true,
                      child: Icon(Icons.refresh, size: 20),
                      onPressed: _resetPositions,
                      tooltip: 'Reset component positions',
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDraggableComponent(
    String componentName,
    SystemComponent component,
    RecipeState recipeState,
  ) {
    final position = _componentPositions[componentName] ?? Offset.zero;
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable(
        feedback: _buildComponentIndicator(component, recipeState),
        childWhenDragging: Container(),
        onDragEnd: (details) {
          final RenderBox? renderBox = _overlayKey.currentContext?.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final localPosition = renderBox.globalToLocal(details.offset);
            setState(() {
              _componentPositions[componentName] = localPosition;
            });
            _saveComponentPositions();
          }
        },
        child: GestureDetector(
          onTap: () => _showComponentControlDialog(context, component, recipeState),
          child: _buildComponentIndicator(component, recipeState),
        ),
      ),
    );
  }

  Widget _buildComponentIndicator(
    SystemComponent component,
    RecipeState recipeState,
  ) {
    final isActiveInCurrentStep = _isComponentActiveInCurrentStep(component, recipeState);
    final color = component.isActivated
        ? (isActiveInCurrentStep ? Colors.green : Colors.blue)
        : Colors.red;

    double indicatorSize = _overlaySize != null ? _overlaySize!.width * 0.06 : 30.0;
    indicatorSize = indicatorSize.clamp(20.0, 40.0);

    return Container(
      width: indicatorSize,
      height: indicatorSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.2),
        border: Border.all(color: color, width: 1),
      ),
      child: Center(
        child: Text(
          _getComponentAbbreviation(component.name),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: indicatorSize * 0.3,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getComponentAbbreviation(String componentName) {
    final words = componentName.split(' ');
    if (words.length > 1) {
      return words.map((word) => word[0]).join('').toUpperCase();
    } else {
      return componentName.substring(0, min(2, componentName.length)).toUpperCase();
    }
  }

  bool _isComponentActiveInCurrentStep(
    SystemComponent component,
    RecipeState recipeState,
  ) {
    if (recipeState.activeRecipe == null ||
        recipeState.currentStepIndex >= recipeState.activeRecipe!.steps.length) {
      return false;
    }

    final currentStep = recipeState.activeRecipe!.steps[recipeState.currentStepIndex];
    switch (currentStep.type) {
      case StepType.valve:
        final valveType = currentStep.parameters['valveType'] as ValveType;
        return (valveType == ValveType.valveA && component.name == 'Valve 1') ||
            (valveType == ValveType.valveB && component.name == 'Valve 2');
      case StepType.purge:
        return component.name == 'MFC' || component.name == 'Nitrogen Generator';
      case StepType.setParameter:
        return component.name == currentStep.parameters['component'];
      default:
        return false;
    }
  }

  void _showComponentControlDialog(
    BuildContext context,
    SystemComponent component,
    RecipeState recipeState,
  ) {
    showDialog(
      context: context,
      builder: (context) => ComponentControlDialog(
        component: component,
        isActiveInCurrentStep: _isComponentActiveInCurrentStep(component, recipeState),
        currentRecipeStep: recipeState.activeRecipe?.steps[recipeState.currentStepIndex],
      ),
    );
  }
}