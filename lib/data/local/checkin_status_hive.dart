import 'package:hive/hive.dart';
import '../../domain/enums/checkin_status.dart';

part 'checkin_status_hive.g.dart';

@HiveType(typeId: 9)
enum CheckInSyncStatusHive {
  @HiveField(0)
  pending,

  @HiveField(1)
  synced,

  @HiveField(2)
  failed,
}

extension CheckInSyncStatusHiveX on CheckInSyncStatusHive {
  CheckInSyncStatus toDomain() {
    switch (this) {
      case CheckInSyncStatusHive.pending:
        return CheckInSyncStatus.pending;
      case CheckInSyncStatusHive.synced:
        return CheckInSyncStatus.synced;
      case CheckInSyncStatusHive.failed:
        return CheckInSyncStatus.failed;
    }
  }
}
