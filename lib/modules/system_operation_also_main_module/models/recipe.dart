// lib/modules/system_operation_also_main_module/models/recipe.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  String id;
  String name;
  List<RecipeStep> steps;
  String substrate;
  double chamberTemperatureSetPoint;
  double pressureSetPoint;
  int version;
  DateTime lastModified;

  Recipe({
    required this.id,
    required this.name,
    required this.steps,
    required this.substrate,
    this.chamberTemperatureSetPoint = 150.0,
    this.pressureSetPoint = 1.0,
    this.version = 1,
    DateTime? lastModified,
  }) : this.lastModified = lastModified ?? DateTime.now();

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      steps: (json['steps'] as List<dynamic>)
          .map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      substrate: json['substrate'] as String,
      chamberTemperatureSetPoint: json['chamberTemperatureSetPoint'] as double? ?? 150.0,
      pressureSetPoint: json['pressureSetPoint'] as double? ?? 1.0,
      version: json['version'] as int? ?? 1,
      lastModified: (json['lastModified'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'steps': steps.map((e) => e.toJson()).toList(),
    'substrate': substrate,
    'chamberTemperatureSetPoint': chamberTemperatureSetPoint,
    'pressureSetPoint': pressureSetPoint,
    'version': version,
    'lastModified': Timestamp.fromDate(lastModified),
  };
}

class RecipeStep {
  StepType type;
  Map<String, dynamic> parameters;
  List<RecipeStep>? subSteps;

  RecipeStep({
    required this.type,
    required this.parameters,
    this.subSteps,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      type: StepType.values.firstWhere((e) => e.toString() == 'StepType.${json['type']}'),
      parameters: Map<String, dynamic>.from(json['parameters']).map((key, value) {
        if (key == 'valveType' && value is String) {
          return MapEntry(key, ValveType.values.firstWhere((e) => e.toString() == 'ValveType.$value'));
        }
        return MapEntry(key, value);
      }),
      subSteps: json['subSteps'] != null
          ? (json['subSteps'] as List<dynamic>)
          .map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.toString().split('.').last,
    'parameters': parameters.map((key, value) {
      if (value is ValveType) {
        return MapEntry(key, value.toString().split('.').last);
      }
      return MapEntry(key, value);
    }),
    'subSteps': subSteps?.map((e) => e.toJson()).toList(),
  };
}

enum StepType { loop, valve, purge, setParameter }

enum ValveType { valveA, valveB }