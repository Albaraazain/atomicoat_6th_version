// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_log_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SystemLogEntryAdapter extends TypeAdapter<SystemLogEntry> {
  @override
  final int typeId = 11;

  @override
  SystemLogEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SystemLogEntry(
      timestamp: fields[0] as DateTime,
      message: fields[1] as String,
      severity: fields[2] as ComponentStatus,
    );
  }

  @override
  void write(BinaryWriter writer, SystemLogEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.message)
      ..writeByte(2)
      ..write(obj.severity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemLogEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
