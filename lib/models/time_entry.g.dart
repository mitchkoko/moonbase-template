// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimeEntryAdapter extends TypeAdapter<TimeEntry> {
  @override
  final int typeId = 0;

  @override
  TimeEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimeEntry(
      date: fields[0] as DateTime,
      startTime: fields[1] as DateTime,
      endTime: fields[2] as DateTime,
      duration: fields[3] as Duration,
    );
  }

  @override
  void write(BinaryWriter writer, TimeEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.duration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}