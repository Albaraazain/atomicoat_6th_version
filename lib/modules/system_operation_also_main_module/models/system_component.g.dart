// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_component.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SystemComponentAdapter extends TypeAdapter<SystemComponent> {
  @override
  final int typeId = 6;

  @override
  SystemComponent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SystemComponent(
      name: fields[0] as String,
      description: fields[1] as String,
      status: fields[2] as ComponentStatus,
      currentValues: (fields[3] as Map).cast<String, double>(),
      setValues: (fields[4] as Map).cast<String, double>(),
      errorMessages: (fields[5] as List).cast<String>(),
      isActivated: fields[7] as bool,
    )..parameterHistory = (fields[6] as Map).map((dynamic k, dynamic v) =>
        MapEntry(k as String, (v as List).cast<DataPoint>()));
  }

  @override
  void write(BinaryWriter writer, SystemComponent obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.currentValues)
      ..writeByte(4)
      ..write(obj.setValues)
      ..writeByte(5)
      ..write(obj.errorMessages)
      ..writeByte(6)
      ..write(obj.parameterHistory)
      ..writeByte(7)
      ..write(obj.isActivated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemComponentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ComponentStatusAdapter extends TypeAdapter<ComponentStatus> {
  @override
  final int typeId = 7;

  @override
  ComponentStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ComponentStatus.normal;
      case 1:
        return ComponentStatus.warning;
      case 2:
        return ComponentStatus.error;
      default:
        return ComponentStatus.normal;
    }
  }

  @override
  void write(BinaryWriter writer, ComponentStatus obj) {
    switch (obj) {
      case ComponentStatus.normal:
        writer.writeByte(0);
        break;
      case ComponentStatus.warning:
        writer.writeByte(1);
        break;
      case ComponentStatus.error:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComponentStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
