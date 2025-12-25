import 'package:hive/hive.dart';
import '../../domain/enums/checkin_status.dart';

part 'checkin_status_hive.g.dart';

@HiveType(typeId: 5)
enum CheckInSyncStatusHive {
  @HiveField(0)
  pending,

  @HiveField(1)
  synced,

  @HiveField(2)
  failed,
}

extension CheckInSyncStatusMapper on CheckInSyncStatusHive {
  CheckInSyncStatus toDomain() {
    return CheckInSyncStatus.values[index];
  }
}

extension CheckInSyncStatusHiveMapper on CheckInSyncStatus {
  CheckInSyncStatusHive toHive() {
    return CheckInSyncStatusHive.values[index];
  }
}
