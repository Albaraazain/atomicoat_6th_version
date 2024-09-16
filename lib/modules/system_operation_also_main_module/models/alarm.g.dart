// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlarmAdapter extends TypeAdapter<Alarm> {
  @override
  final int typeId = 0;

  @override
  Alarm read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Alarm(
      id: fields[0] as String,
      message: fields[1] as String,
      severity: fields[2] as AlarmSeverity,
      timestamp: fields[3] as DateTime,
      acknowledged: fields[4] as bool,
      isSafetyAlert: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Alarm obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.message)
      ..writeByte(2)
      ..write(obj.severity)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.acknowledged)
      ..writeByte(5)
      ..write(obj.isSafetyAlert);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AlarmSeverityAdapter extends TypeAdapter<AlarmSeverity> {
  @override
  final int typeId = 1;

  @override
  AlarmSeverity read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AlarmSeverity.info;
      case 1:
        return AlarmSeverity.warning;
      case 2:
        return AlarmSeverity.critical;
      default:
        return AlarmSeverity.info;
    }
  }

  @override
  void write(BinaryWriter writer, AlarmSeverity obj) {
    switch (obj) {
      case AlarmSeverity.info:
        writer.writeByte(0);
        break;
      case AlarmSeverity.warning:
        writer.writeByte(1);
        break;
      case AlarmSeverity.critical:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmSeverityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
