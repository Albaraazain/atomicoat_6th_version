import 'package:equatable/equatable.dart';
import '../models/system_component.dart';

abstract class ComponentListEvent extends Equatable {
  const ComponentListEvent();

  @override
  List<Object> get props => [];
}

class LoadComponents extends ComponentListEvent {
  final String? userId;
  const LoadComponents({this.userId}) : super();

  @override
  List<Object> get props => [userId ?? ''];
}

class ClearAllComponents extends ComponentListEvent {
  final String? userId;
  const ClearAllComponents({this.userId});

  @override
  List<Object> get props => [userId ?? ''];
}

class ActivateComponents extends ComponentListEvent {
  final List<String> componentIds;
  final String? userId;

  const ActivateComponents(this.componentIds, {this.userId});

  @override
  List<Object> get props => [componentIds, userId ?? ''];
}

class CheckSystemReadiness extends ComponentListEvent {}

class GetSystemIssues extends ComponentListEvent {}

class UpdateComponent extends ComponentListEvent {
  final SystemComponent component;
  final String? userId;  // Make userId optional since it's not needed for global components

  UpdateComponent(this.component, {this.userId});

  @override
  List<Object> get props => [component, userId ?? ''];
}

class RemoveComponent extends ComponentListEvent {
  final String componentId;
  final String? userId;

  const RemoveComponent(this.componentId, {this.userId});

  @override
  List<Object> get props => [componentId, userId ?? ''];
}

class AddComponent extends ComponentListEvent {
  final SystemComponent component;

  const AddComponent(this.component);

  @override
  List<Object> get props => [component];
}

class UpdateAllComponents extends ComponentListEvent {
  final Map<String, SystemComponent> components;

  const UpdateAllComponents(this.components);

  @override
  List<Object> get props => [components];
}

class ComponentError extends ComponentListEvent {
  final String error;

  const ComponentError(this.error);

  @override
  List<Object> get props => [error];
}
