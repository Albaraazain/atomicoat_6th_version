// lib/blocs/component/bloc/component_list_bloc.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../../modules/system_operation_also_main_module/models/system_component.dart';
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
      // Update local state
      final updatedComponents = Map<String, SystemComponent>.from(state.components);
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

  // Helper methods
  SystemComponent? getComponent(String name) => state.components[name];

  List<SystemComponent> getAllComponents() => state.components.values.toList();

  List<SystemComponent> getActiveComponents() =>
      state.components.values.where((c) => c.isActivated).toList();
}