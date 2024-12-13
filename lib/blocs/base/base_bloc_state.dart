// lib/blocs/base/base_bloc_state.dart

import 'package:equatable/equatable.dart';

/// Base state class that includes common state properties
abstract class BaseBlocState extends Equatable {
  final bool isLoading;
  final String? error;
  final DateTime lastUpdated;

  BaseBlocState({
    this.isLoading = false,
    this.error,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  @override
  List<Object?> get props => [isLoading, error, lastUpdated];
}