// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkin_status_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CheckInSyncStatusHiveAdapter extends TypeAdapter<CheckInSyncStatusHive> {
  @override
  final int typeId = 5;

  @override
  CheckInSyncStatusHive read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CheckInSyncStatusHive.pending;
      case 1:
        return CheckInSyncStatusHive.synced;
      case 2:
        return CheckInSyncStatusHive.failed;
      default:
        return CheckInSyncStatusHive.pending;
    }
  }

  @override
  void write(BinaryWriter writer, CheckInSyncStatusHive obj) {
    switch (obj) {
      case CheckInSyncStatusHive.pending:
        writer.writeByte(0);
        break;
      case CheckInSyncStatusHive.synced:
        writer.writeByte(1);
        break;
      case CheckInSyncStatusHive.failed:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckInSyncStatusHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
