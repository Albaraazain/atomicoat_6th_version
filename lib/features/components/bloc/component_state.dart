import 'package:equatable/equatable.dart';
import '../models/system_component.dart';

// Keep this as ComponentState since it's specific to the components feature
class ComponentState extends Equatable {
  final SystemComponent? component;
  final bool isLoading;
  final String? error;

  const ComponentState({
    this.component,
    this.isLoading = false,
    this.error,
  });

  factory ComponentState.initial() {
    return const ComponentState(isLoading: false);
  }

  factory ComponentState.loading() {
    return const ComponentState(isLoading: true);
  }

  factory ComponentState.loaded(SystemComponent component) {
    return ComponentState(component: component, isLoading: false);
  }

  factory ComponentState.error(String error) {
    return ComponentState(error: error, isLoading: false);
  }

  ComponentState copyWith({
    SystemComponent? component,
    bool? isLoading,
    String? error,
  }) {
    return ComponentState(
      component: component ?? this.component,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [component, isLoading, error];

  bool get isInitialized => component != null;
}