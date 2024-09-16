// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safety_error.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SafetyErrorAdapter extends TypeAdapter<SafetyError> {
  @override
  final int typeId = 9;

  @override
  SafetyError read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SafetyError(
      id: fields[0] as String,
      description: fields[1] as String,
      severity: fields[2] as SafetyErrorSeverity,
    );
  }

  @override
  void write(BinaryWriter writer, SafetyError obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.severity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SafetyErrorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SafetyErrorSeverityAdapter extends TypeAdapter<SafetyErrorSeverity> {
  @override
  final int typeId = 10;

  @override
  SafetyErrorSeverity read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SafetyErrorSeverity.warning;
      case 1:
        return SafetyErrorSeverity.critical;
      default:
        return SafetyErrorSeverity.warning;
    }
  }

  @override
  void write(BinaryWriter writer, SafetyErrorSeverity obj) {
    switch (obj) {
      case SafetyErrorSeverity.warning:
        writer.writeByte(0);
        break;
      case SafetyErrorSeverity.critical:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SafetyErrorSeverityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
