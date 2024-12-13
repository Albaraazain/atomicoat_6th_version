// lib/blocs/component/bloc/component_list_bloc.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../modules/system_operation_also_main_module/models/system_component.dart';
import '../repository/component_repository.dart';

// Events
abstract class ComponentListEvent extends Equatable {
  const ComponentListEvent();

  @override
  List<Object> get props => [];
}

class LoadComponents extends ComponentListEvent {
  final String? userId;
  const LoadComponents({this.userId});

  @override
  List<Object?> get props => [userId];
}

class ClearAllComponents extends ComponentListEvent {
  final String? userId;
  const ClearAllComponents({this.userId});

  @override
  List<Object?> get props => [userId];
}

class ActivateComponents extends ComponentListEvent {
  final List<String> componentIds;
  final String? userId;

  const ActivateComponents(this.componentIds, {this.userId});

  @override
  List<Object?> get props => [componentIds, userId];
}

class CheckSystemReadiness extends ComponentListEvent {}

class GetSystemIssues extends ComponentListEvent {}

class UpdateComponent extends ComponentListEvent {
  final SystemComponent component;

  const UpdateComponent(this.component);

  @override
  List<Object> get props => [component];
}

class AddComponent extends ComponentListEvent {
  final SystemComponent component;

  const AddComponent(this.component);

  @override
  List<Object> get props => [component];
}

// State
class ComponentListState extends Equatable {
  final Map<String, SystemComponent> components;
  final bool isLoading;
  final String? error;

  const ComponentListState({
    this.components = const {},
    this.isLoading = false,
    this.error,
  });

  ComponentListState copyWith({
    Map<String, SystemComponent>? components,
    bool? isLoading,
    String? error,
  }) {
    return ComponentListState(
      components: components ?? this.components,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [components, isLoading, error];
}

// Bloc
class ComponentListBloc extends Bloc<ComponentListEvent, ComponentListState> {
  final ComponentRepository _repository;
  StreamSubscription? _componentsSubscription;

  ComponentListBloc(this._repository) : super(const ComponentListState()) {
    on<LoadComponents>(_onLoadComponents);
    on<UpdateComponent>(_onUpdateComponent);
    on<AddComponent>(_onAddComponent);
  }

  Future<void> _onLoadComponents(
    LoadComponents event,
    Emitter<ComponentListState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      // Load initial components
      final components = await _repository.getAllComponents();
      final componentsMap = {
        for (var component in components) component.name: component
      };

      emit(state.copyWith(
        components: componentsMap,
        isLoading: false,
      ));

      // Setup real-time updates if needed
      // This would depend on your Firestore implementation
      // _setupComponentsSubscription();

    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> _onUpdateComponent(
    UpdateComponent event,
    Emitter<ComponentListState> emit,
  ) async {
    try {
      // Update local state
      final updatedComponents = Map<String, SystemComponent>.from(state.components);
      updatedComponents[event.component.name] = event.component;

      emit(state.copyWith(components: updatedComponents));

      // Persist to repository
      await _repository.saveComponent(event.component);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onAddComponent(
    AddComponent event,
    Emitter<ComponentListState> emit,
  ) async {
    try {
      // Update local state
      final updatedComponents = Map<String, SystemComponent>.from(state.components);
      updatedComponents[event.component.name] = event.component;

      emit(state.copyWith(components: updatedComponents));

      // Persist to repository
      await _repository.saveComponent(event.component);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _setupComponentsSubscription() {
    // Implement real-time updates subscription if needed
    // This would depend on your Firestore implementation
  }

  @override
  Future<void> close() {
    _componentsSubscription?.cancel();
    return super.close();
  }

  // Helper methods
  SystemComponent? getComponent(String name) => state.components[name];

  List<SystemComponent> getAllComponents() => state.components.values.toList();

  List<SystemComponent> getActiveComponents() =>
      state.components.values.where((c) => c.isActivated).toList();
}