// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blood_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BloodEventAdapter extends TypeAdapter<BloodEvent> {
  @override
  final int typeId = 1;

  @override
  BloodEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BloodEvent(
      timestamp: fields[0] as DateTime,
      type: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BloodEvent obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BloodEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
