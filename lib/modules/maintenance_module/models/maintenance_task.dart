// lib/models/maintenance_task.dart
import 'package:flutter/foundation.dart';

class MaintenanceTask {
  final String id;
  final String componentId;
  final String description;
  final DateTime dueDate;
  bool isCompleted;

  MaintenanceTask({
    required this.id,
    required this.componentId,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
  });

  MaintenanceTask copyWith({
    String? id,
    String? componentId,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return MaintenanceTask(
      id: id ?? this.id,
      componentId: componentId ?? this.componentId,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'componentId': componentId,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory MaintenanceTask.fromJson(Map<String, dynamic> json) {
    return MaintenanceTask(
      id: json['id'],
      componentId: json['componentId'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      isCompleted: json['isCompleted'] == 1,
    );
  }

  @override
  String toString() {
    return 'MaintenanceTask(id: $id, componentId: $componentId, description: $description, dueDate: $dueDate, isCompleted: $isCompleted)';
  }
}