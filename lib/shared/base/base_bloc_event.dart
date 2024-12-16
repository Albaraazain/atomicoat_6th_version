// lib/blocs/base/base_bloc_event.dart

import 'package:equatable/equatable.dart';

/// Base event class that includes common event properties
abstract class BaseBlocEvent extends Equatable {
  final DateTime timestamp;

  // Remove const constructor since we need DateTime.now()
  BaseBlocEvent() : timestamp = DateTime.now();

  @override
  List<Object?> get props => [timestamp.millisecondsSinceEpoch];
}