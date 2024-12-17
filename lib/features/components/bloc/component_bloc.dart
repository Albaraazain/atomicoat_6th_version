import 'dart:async';
import 'package:bloc/bloc.dart';
import '../models/system_component.dart';
import '../repository/user_component_state_repository.dart';
import 'component_event.dart';
import 'component_state.dart';

class ComponentBloc extends Bloc<ComponentEvent, ComponentState> {
  final UserComponentStateRepository _repository;
  final String userId;
  StreamSubscription<SystemComponent?>? _componentSubscription;

  ComponentBloc(this._repository, {required this.userId}) : super(ComponentState.initial()) {
    on<ComponentInitialized>(_onComponentInitialized);
    on<ComponentValueUpdated>(_onComponentValueUpdated);
    on<ComponentSetValueUpdated>(_onComponentSetValueUpdated);
    on<ComponentActivationToggled>(_onComponentActivationToggled);
    on<ComponentErrorAdded>(_onComponentErrorAdded);
    on<ComponentErrorsCleared>(_onComponentErrorsCleared);
    on<ComponentStatusUpdated>(_onComponentStatusUpdated);
    on<ComponentCheckDateUpdated>(_onComponentCheckDateUpdated);
    on<ComponentLimitsUpdated>(_onComponentLimitsUpdated);
  }

  Future<void> _onComponentInitialized(
    ComponentInitialized event,
    Emitter<ComponentState> emit,
  ) async {
    emit(ComponentState.loading());

    try {
      final component = await _repository.get(event.componentName, userId: userId);
      if (component != null) {
        emit(ComponentState.loaded(component));

        // Start watching for changes
        await _componentSubscription?.cancel();
        _componentSubscription = _repository
            .watch(event.componentName, userId: userId)
            .listen(
              (component) {
                if (!emit.isDone) {
                  if (component != null) {
                    emit(ComponentState.loaded(component));
                  } else {
                    emit(ComponentState.error('Component not found'));
                  }
                }
              },
            );
      } else {
        emit(ComponentState.error('Component not found'));
      }
    } catch (e) {
      emit(ComponentState.error(e.toString()));
    }
  }

  Future<void> _onComponentValueUpdated(
    ComponentValueUpdated event,
    Emitter<ComponentState> emit,
  ) async {
    if (state.component == null) return;

    try {
      final updatedComponent = state.component!;
      updatedComponent.updateCurrentValues(event.currentValues);
      await _repository.saveComponentState(
        updatedComponent,
        userId: userId,
      );
      emit(ComponentState.loaded(updatedComponent));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onComponentSetValueUpdated(
    ComponentSetValueUpdated event,
    Emitter<ComponentState> emit,
  ) async {
    if (state.component == null) return;

    try {
      final updatedComponent = state.component!;
      updatedComponent.updateSetValues(event.setValues);
      await _repository.saveComponentState(
        updatedComponent,
        userId: userId,
      );
      emit(ComponentState.loaded(updatedComponent));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onComponentActivationToggled(
    ComponentActivationToggled event,
    Emitter<ComponentState> emit,
  ) async {
    if (state.component == null) return;

    try {
      final updatedComponent = state.component!;
      updatedComponent.isActivated = event.isActivated;
      await _repository.saveComponentState(
        updatedComponent,
        userId: userId,
      );
      emit(ComponentState.loaded(updatedComponent));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onComponentErrorAdded(
    ComponentErrorAdded event,
    Emitter<ComponentState> emit,
  ) async {
    if (state.component == null) return;

    try {
      final updatedComponent = state.component!;
      updatedComponent.addErrorMessage(event.errorMessage);
      await _repository.saveComponentState(
        updatedComponent,
        userId: userId,
      );
      emit(ComponentState.loaded(updatedComponent));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onComponentErrorsCleared(
    ComponentErrorsCleared event,
    Emitter<ComponentState> emit,
  ) async {
    if (state.component == null) return;

    try {
      final updatedComponent = state.component!;
      updatedComponent.clearErrorMessages();
      await _repository.saveComponentState(
        updatedComponent,
        userId: userId,
      );
      emit(ComponentState.loaded(updatedComponent));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onComponentStatusUpdated(
    ComponentStatusUpdated event,
    Emitter<ComponentState> emit,
  ) async {
    if (state.component == null) return;

    try {
      final updatedComponent = state.component!;
      updatedComponent.status = event.status;
      await _repository.saveComponentState(
        updatedComponent,
        userId: userId,
      );
      emit(ComponentState.loaded(updatedComponent));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onComponentCheckDateUpdated(
    ComponentCheckDateUpdated event,
    Emitter<ComponentState> emit,
  ) async {
    if (state.component == null) return;

    try {
      final updatedComponent = state.component!;
      updatedComponent.updateLastCheckDate(event.checkDate);
      await _repository.saveComponentState(
        updatedComponent,
        userId: userId,
      );
      emit(ComponentState.loaded(updatedComponent));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onComponentLimitsUpdated(
    ComponentLimitsUpdated event,
    Emitter<ComponentState> emit,
  ) async {
    if (state.component == null) return;

    try {
      final updatedComponent = state.component!;
      if (event.minValues != null) {
        updatedComponent.updateMinValues(event.minValues!);
      }
      if (event.maxValues != null) {
        updatedComponent.updateMaxValues(event.maxValues!);
      }
      await _repository.saveComponentState(
        updatedComponent,
        userId: userId,
      );
      emit(ComponentState.loaded(updatedComponent));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _componentSubscription?.cancel();
    return super.close();
  }
}