import 'package:flutter/foundation.dart';

enum StepType {
  loop,
  valve,
  purge,
  setParameter,
}

enum ValveType {
  valveA,
  valveB,
}

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
      lastModified: DateTime.parse(json['lastModified'] as String),
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
    'lastModified': lastModified.toIso8601String(),
  };

  Recipe copyWith({
    String? id,
    String? name,
    List<RecipeStep>? steps,
    String? substrate,
    double? chamberTemperatureSetPoint,
    double? pressureSetPoint,
    int? version,
    DateTime? lastModified,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      steps: steps ?? List.from(this.steps),
      substrate: substrate ?? this.substrate,
      chamberTemperatureSetPoint: chamberTemperatureSetPoint ?? this.chamberTemperatureSetPoint,
      pressureSetPoint: pressureSetPoint ?? this.pressureSetPoint,
      version: version ?? this.version,
      lastModified: lastModified ?? DateTime.now(),
    );
  }
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
      type: StepType.values.firstWhere(
              (e) => e.toString() == 'StepType.${json['type']}'),
      parameters: _parseParameters(json['parameters'] as Map<String, dynamic>, json['type'] as String),
      subSteps: json['subSteps'] != null
          ? (json['subSteps'] as List<dynamic>)
          .map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.toString().split('.').last,
    'parameters': _serializeParameters(parameters, type),
    'subSteps': subSteps?.map((e) => e.toJson()).toList(),
  };

  static Map<String, dynamic> _parseParameters(Map<String, dynamic> params, String stepType) {
    switch (stepType) {
      case 'valve':
        return {
          'valveType': ValveType.values.firstWhere((e) => e.toString() == 'ValveType.${params['valveType']}'),
          'duration': params['duration'] as int,
          'gasFlow': params['gasFlow'] as double?,
        };
      case 'loop':
        return {
          'iterations': params['iterations'] as int,
          'temperature': params['temperature'] as double?,
          'pressure': params['pressure'] as double?,
        };
      case 'purge':
        return {
          'duration': params['duration'] as int,
          'gasFlow': params['gasFlow'] as double?,
        };
      case 'setParameter':
        return {
          'component': params['component'] as String,
          'parameter': params['parameter'] as String,
          'value': params['value'] as double,
        };
      default:
        return params;
    }
  }

  static Map<String, dynamic> _serializeParameters(Map<String, dynamic> params, StepType stepType) {
    switch (stepType) {
      case StepType.valve:
        return {
          'valveType': (params['valveType'] as ValveType).toString().split('.').last,
          'duration': params['duration'],
          'gasFlow': params['gasFlow'],
        };
      case StepType.loop:
        return {
          'iterations': params['iterations'],
          'temperature': params['temperature'],
          'pressure': params['pressure'],
        };
      case StepType.purge:
        return {
          'duration': params['duration'],
          'gasFlow': params['gasFlow'],
        };
      case StepType.setParameter:
        return {
          'component': params['component'],
          'parameter': params['parameter'],
          'value': params['value'],
        };
      default:
        return params;
    }
  }

  RecipeStep copyWith({
    StepType? type,
    Map<String, dynamic>? parameters,
    List<RecipeStep>? subSteps,
  }) {
    return RecipeStep(
      type: type ?? this.type,
      parameters: parameters ?? Map.from(this.parameters),
      subSteps: subSteps ?? (this.subSteps != null ? List.from(this.subSteps!) : null),
    );
  }
}