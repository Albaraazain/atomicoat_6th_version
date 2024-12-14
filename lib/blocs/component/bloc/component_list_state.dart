import 'package:equatable/equatable.dart';
import '../../../modules/system_operation_also_main_module/models/system_component.dart';

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
