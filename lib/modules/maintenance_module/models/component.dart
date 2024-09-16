// lib/models/component.dart
import 'package:flutter/foundation.dart';

class Component {
  final String id;
  final String name;
  final String type;
  String status;
  DateTime lastMaintenanceDate;

  Component({
    required this.id,
    required this.name,
    required this.type,
    this.status = 'normal',
    required this.lastMaintenanceDate,
  });

  Component copyWith({
    String? id,
    String? name,
    String? type,
    String? status,
    DateTime? lastMaintenanceDate,
  }) {
    return Component(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      lastMaintenanceDate: lastMaintenanceDate ?? this.lastMaintenanceDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'status': status,
      'lastMaintenanceDate': lastMaintenanceDate.toIso8601String(),
    };
  }

  factory Component.fromJson(Map<String, dynamic> json) {
    return Component(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      status: json['status'],
      lastMaintenanceDate: DateTime.parse(json['lastMaintenanceDate']),
    );
  }

  @override
  String toString() {
    return 'Component(id: $id, name: $name, type: $type, status: $status, lastMaintenanceDate: $lastMaintenanceDate)';
  }
}