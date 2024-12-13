// lib/blocs/system_state/bloc/system_state_event.dart

import '../../base/base_bloc_event.dart';

abstract class SystemStateEvent extends BaseBlocEvent {}

class InitializeSystem extends SystemStateEvent {}

class StartSystem extends SystemStateEvent {}

class StopSystem extends SystemStateEvent {}

class EmergencyStop extends SystemStateEvent {}

class CheckSystemReadiness extends SystemStateEvent {}

class SaveSystemState extends SystemStateEvent {
  final Map<String, dynamic> state;

  SaveSystemState(this.state);

  @override
  List<Object?> get props => [...super.props, state];
}

class ValidateSystemState extends SystemStateEvent {}

class UpdateSystemParameters extends SystemStateEvent {
  final Map<String, Map<String, double>> updates;

  UpdateSystemParameters(this.updates);

  @override
  List<Object?> get props => [...super.props, updates];
}