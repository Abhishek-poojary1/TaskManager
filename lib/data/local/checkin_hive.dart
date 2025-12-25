import 'package:hive/hive.dart';

import 'package:hive/hive.dart';

import '../../domain/models/checkin.dart';
import 'checkin_status_hive.dart';

part 'checkin_hive.g.dart';

@HiveType(typeId: 6)
class CheckInHive extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String taskId;

  @HiveField(2)
  String notes;

  @HiveField(3)
  String category;

  @HiveField(4)
  double latitude;

  @HiveField(5)
  double longitude;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  CheckInSyncStatusHive syncStatus;

  CheckInHive({
    required this.id,
    required this.taskId,
    required this.notes,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.syncStatus,
  });
}
