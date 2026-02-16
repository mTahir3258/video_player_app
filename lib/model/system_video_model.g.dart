// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_video_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SystemVideoAdapter extends TypeAdapter<SystemVideo> {
  @override
  final int typeId = 1;

  @override
  SystemVideo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SystemVideo(
      path: fields[0] as String,
      name: fields[1] as String,
      assetId: fields[3] as String?,
    )..durationMillis = fields[2] as int;
  }

  @override
  void write(BinaryWriter writer, SystemVideo obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.path)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.durationMillis)
      ..writeByte(3)
      ..write(obj.assetId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemVideoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
