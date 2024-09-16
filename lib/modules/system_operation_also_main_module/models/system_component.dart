// lib/modules/system_operation_also_main_module/models/system_component.dart

import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'data_point.dart';

part 'system_component.g.dart';

@HiveType(typeId: 6)
class SystemComponent {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String description;

  @HiveField(2)
  ComponentStatus status;

  @HiveField(3)
  Map<String, double> currentValues;

  @HiveField(4)
  Map<String, double> setValues;

  @HiveField(5)
  List<String> errorMessages;

  @HiveField(6)
  Map<String, List<DataPoint>> parameterHistory;

  @HiveField(7)
  bool isActivated;

  SystemComponent({
    required this.name,
    required this.description,
    this.status = ComponentStatus.normal,
    required this.currentValues,
    required this.setValues,
    this.errorMessages = const [],
    this.isActivated = false,
  }) : parameterHistory = {
    for (var key in currentValues.keys) key: [],
  };

  factory SystemComponent.fromJson(Map<String, dynamic> json) {
    return SystemComponent(
      name: json['name'] as String,
      description: json['description'] as String,
      status: ComponentStatus.values.firstWhere((e) => e.toString() == 'ComponentStatus.${json['status']}'),
      currentValues: Map<String, double>.from(json['currentValues']),
      setValues: Map<String, double>.from(json['setValues']),
      errorMessages: List<String>.from(json['errorMessages']),
      isActivated: json['isActivated'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'status': status.toString().split('.').last,
    'currentValues': currentValues,
    'setValues': setValues,
    'errorMessages': errorMessages,
    'isActivated': isActivated,
  };
}

@HiveType(typeId: 7)
enum ComponentStatus {
  @HiveField(0)
  normal,
  @HiveField(1)
  warning,
  @HiveField(2)
  error
}