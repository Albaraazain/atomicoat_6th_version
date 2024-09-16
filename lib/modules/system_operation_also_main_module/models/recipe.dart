// lib/modules/system_operation_also_main_module/models/recipe.dart

import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'recipe.g.dart';

@HiveType(typeId: 2)
class Recipe {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<RecipeStep> steps;

  @HiveField(3)
  String substrate;

  @HiveField(4)
  double chamberTemperatureSetPoint;

  @HiveField(5)
  double pressureSetPoint;

  @HiveField(6)
  int version;

  @HiveField(7)
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

@HiveType(typeId: 3)
class RecipeStep {
  @HiveField(0)
  StepType type;

  @HiveField(1)
  Map<String, dynamic> parameters;

  @HiveField(2)
  List<RecipeStep>? subSteps;

  RecipeStep({
    required this.type,
    required this.parameters,
    this.subSteps,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      type: StepType.values.firstWhere((e) => e.toString() == 'StepType.${json['type']}'),
      parameters: Map<String, dynamic>.from(json['parameters']),
      subSteps: json['subSteps'] != null
          ? (json['subSteps'] as List<dynamic>)
          .map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.toString().split('.').last,
    'parameters': parameters,
    'subSteps': subSteps?.map((e) => e.toJson()).toList(),
  };
}

@HiveType(typeId: 4)
enum StepType {
  @HiveField(0)
  loop,
  @HiveField(1)
  valve,
  @HiveField(2)
  purge,
  @HiveField(3)
  setParameter,
}

@HiveType(typeId: 5)
enum ValveType {
  @HiveField(0)
  valveA,
  @HiveField(1)
  valveB,
}