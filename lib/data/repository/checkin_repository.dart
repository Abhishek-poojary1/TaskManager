import 'package:hive/hive.dart';

import '../local/hive_boxes.dart';
import '../local/checkin_hive.dart';
import '../local/checkin_status_hive.dart';

import '../../domain/models/checkin.dart';

class CheckInRepository {
  Future<void> createCheckIn(CheckIn checkIn) async {
    try {
      final box = await Hive.openBox<CheckInHive>(HiveBoxes.checkins);

      final hiveModel = CheckInHive(
        id: checkIn.id,
        taskId: checkIn.taskId,
        notes: checkIn.notes,
        category: checkIn.category,
        latitude: checkIn.latitude,
        longitude: checkIn.longitude,
        createdAt: checkIn.createdAt,
        syncStatus: CheckInSyncStatusHive.pending,
      );

      await box.put(checkIn.id, hiveModel);
    } catch (e) {
      rethrow;
    }
  }

  /// ✅ FIXED HERE
  Future<List<CheckIn>> getPendingCheckIns() async {
    final box = await Hive.openBox<CheckInHive>(HiveBoxes.checkins);

    return box.values
        .where((c) => c.syncStatus == CheckInSyncStatusHive.pending)
        .map((e) => e.toDomain())
        .toList();
  }

  Future<List<CheckIn>> getCheckInsForTask(String taskId) async {
    final box = await Hive.openBox<CheckInHive>(HiveBoxes.checkins);

    return box.values
        .where((c) => c.taskId == taskId)
        .map((e) => e.toDomain())
        .toList();
  }

  Future<void> markSynced(String id) async {
    final box = await Hive.openBox<CheckInHive>(HiveBoxes.checkins);

    // ✅ Direct key access instead of searching through values
    final item = box.get(id);
    if (item != null) {
      item.syncStatus = CheckInSyncStatusHive.synced;
      await item.save();
    }
  }
}
