// lib/blocs/simulation/models/simulation_config.dart
import 'package:experiment_planner/features/simulation/models/component_simulation_behavior.dart';

class SimulationConfig {
  static final Map<String, ComponentBehavior> componentBehaviors = {
    'Reaction Chamber': ReactorChamberBehavior(),
    'MFC': MFCBehavior(),
    'Valve 1': ValveBehavior(),
    'Valve 2': ValveBehavior(),
    'Precursor Heater 1': HeaterBehavior(),
    'Precursor Heater 2': HeaterBehavior(),
  };
}