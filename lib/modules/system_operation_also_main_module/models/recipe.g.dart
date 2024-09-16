// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeAdapter extends TypeAdapter<Recipe> {
  @override
  final int typeId = 2;

  @override
  Recipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Recipe(
      id: fields[0] as String,
      name: fields[1] as String,
      steps: (fields[2] as List).cast<RecipeStep>(),
      substrate: fields[3] as String,
      chamberTemperatureSetPoint: fields[4] as double,
      pressureSetPoint: fields[5] as double,
      version: fields[6] as int,
      lastModified: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Recipe obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.steps)
      ..writeByte(3)
      ..write(obj.substrate)
      ..writeByte(4)
      ..write(obj.chamberTemperatureSetPoint)
      ..writeByte(5)
      ..write(obj.pressureSetPoint)
      ..writeByte(6)
      ..write(obj.version)
      ..writeByte(7)
      ..write(obj.lastModified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecipeStepAdapter extends TypeAdapter<RecipeStep> {
  @override
  final int typeId = 3;

  @override
  RecipeStep read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeStep(
      type: fields[0] as StepType,
      parameters: (fields[1] as Map).cast<String, dynamic>(),
      subSteps: (fields[2] as List?)?.cast<RecipeStep>(),
    );
  }

  @override
  void write(BinaryWriter writer, RecipeStep obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.parameters)
      ..writeByte(2)
      ..write(obj.subSteps);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeStepAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StepTypeAdapter extends TypeAdapter<StepType> {
  @override
  final int typeId = 4;

  @override
  StepType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return StepType.loop;
      case 1:
        return StepType.valve;
      case 2:
        return StepType.purge;
      case 3:
        return StepType.setParameter;
      default:
        return StepType.loop;
    }
  }

  @override
  void write(BinaryWriter writer, StepType obj) {
    switch (obj) {
      case StepType.loop:
        writer.writeByte(0);
        break;
      case StepType.valve:
        writer.writeByte(1);
        break;
      case StepType.purge:
        writer.writeByte(2);
        break;
      case StepType.setParameter:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StepTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ValveTypeAdapter extends TypeAdapter<ValveType> {
  @override
  final int typeId = 5;

  @override
  ValveType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ValveType.valveA;
      case 1:
        return ValveType.valveB;
      default:
        return ValveType.valveA;
    }
  }

  @override
  void write(BinaryWriter writer, ValveType obj) {
    switch (obj) {
      case ValveType.valveA:
        writer.writeByte(0);
        break;
      case ValveType.valveB:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValveTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
