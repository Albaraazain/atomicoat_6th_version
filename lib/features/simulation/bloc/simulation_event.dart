// lib/blocs/simulation/bloc/simulation_event.dart


import 'package:experiment_planner/shared/base/base_bloc_event.dart';

sealed class SimulationEvent extends BaseBlocEvent {
  SimulationEvent() : super();
}

class StartSimulation extends SimulationEvent {}

class StopSimulation extends SimulationEvent {}

class SimulationTick extends SimulationEvent {
  final DateTime timestamp;
  SimulationTick() : timestamp = DateTime.now();
}

class UpdateComponentValues extends SimulationEvent {
  final Map<String, Map<String, double>> updates;

  UpdateComponentValues(this.updates);
}

class CheckSafetyConditions extends SimulationEvent {}

class GenerateRandomError extends SimulationEvent {}