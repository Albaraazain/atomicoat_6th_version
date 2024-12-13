// lib/blocs/component/bloc/component_list_event.dart

import 'package:equatable/equatable.dart';
import '../../../modules/system_operation_also_main_module/models/system_component.dart';

abstract class ComponentListEvent extends Equatable {
  const ComponentListEvent();

  @override
  List<Object> get props => [];
}

class LoadComponents extends ComponentListEvent {
  final String? userId;
  const LoadComponents({this.userId});

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

  const UpdateComponent(this.component);

  @override
  List<Object> get props => [component];
}

class RemoveComponent extends ComponentListEvent {
  final String componentId;
  final String? userId;

  const RemoveComponent(this.componentId, {this.userId});

  @override
  List<Object> get props => [componentId, userId ?? ''];
}