// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'haid_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HaidRecordAdapter extends TypeAdapter<HaidRecord> {
  @override
  final int typeId = 0;

  @override
  HaidRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HaidRecord(
      startDate: fields[0] as DateTime,
      endDate: fields[1] as DateTime?,
      durationDays: fields[2] as int,
      notes: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HaidRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.startDate)
      ..writeByte(1)
      ..write(obj.endDate)
      ..writeByte(2)
      ..write(obj.durationDays)
      ..writeByte(3)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HaidRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
