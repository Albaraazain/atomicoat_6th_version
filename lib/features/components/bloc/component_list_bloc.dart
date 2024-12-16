

import 'dart:async';
import 'package:bloc/bloc.dart';
import '../models/system_component.dart';
import '../repository/component_repository.dart';
import 'component_list_event.dart';
import 'component_list_state.dart';

class ComponentListBloc extends Bloc<ComponentListEvent, ComponentListState> {
  final ComponentRepository _repository;
  StreamSubscription? _componentsSubscription;

  ComponentListBloc(this._repository) : super(const ComponentListState()) {
    on<LoadComponents>(_onLoadComponents);
    on<UpdateComponent>(_onUpdateComponent);
    on<AddComponent>(_onAddComponent);
    on<UpdateAllComponents>(_onUpdateAllComponents);
    on<ComponentError>(_onComponentError);
  }

  Future<void> _setupComponentsSubscription() async {
    await _componentsSubscription?.cancel();
    _componentsSubscription = _repository.watchAllComponents().listen(
      (components) {
        final componentsMap = {
          for (var component in components) component.name: component
        };
        add(UpdateAllComponents(componentsMap));
      },
      onError: (error) {
        add(ComponentError(error.toString()));
      },
    );
  }

  Future<void> _onLoadComponents(
    LoadComponents event,
    Emitter<ComponentListState> emit,
  ) async {
    try {
      print("ComponentListBloc: Processing event $event");

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

      // Setup real-time updates
      await _setupComponentsSubscription();
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
      print("ComponentListBloc: Processing event $event");

      // Update local state
      final updatedComponents =
          Map<String, SystemComponent>.from(state.components);
      updatedComponents[event.component.name] = event.component;

      emit(state.copyWith(components: updatedComponents));

      // Persist to repository
      await _repository.saveComponentState(event.component);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onAddComponent(
    AddComponent event,
    Emitter<ComponentListState> emit,
  ) async {
    try {
      print("ComponentListBloc: Processing event $event");

      // Update local state
      final updatedComponents =
          Map<String, SystemComponent>.from(state.components);
      updatedComponents[event.component.name] = event.component;

      emit(state.copyWith(components: updatedComponents));

      // Persist to repository
      await _repository.saveComponentState(event.component);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _componentsSubscription?.cancel();
    return super.close();
  }

  void _onUpdateAllComponents(
    UpdateAllComponents event,
    Emitter<ComponentListState> emit,
  ) {
    emit(state.copyWith(components: event.components));
  }

  void _onComponentError(
    ComponentError event,
    Emitter<ComponentListState> emit,
  ) {
    emit(state.copyWith(error: event.error));
  }

  // Helper methods
  SystemComponent? getComponent(String name) => state.components[name];

  List<SystemComponent> getAllComponents() => state.components.values.toList();

  List<SystemComponent> getActiveComponents() =>
      state.components.values.where((c) => c.isActivated).toList();
}
