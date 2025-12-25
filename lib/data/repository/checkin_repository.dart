import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../local/checkin_hive.dart';
import '../local/checkin_status_hive.dart';
import '../local/hive_boxes.dart';

import '../../domain/models/checkin.dart';
import '../../domain/enums/checkin_status.dart';

class CheckInRepository {
  final _uuid = const Uuid();

  /// Create check-in locally (offline-first)
  Future<void> createCheckIn({
    required String taskId,
    required String notes,
    required String category,
    required double latitude,
    required double longitude,
  }) async {
    final box = await Hive.openBox<CheckInHive>(HiveBoxes.checkIns);

    final checkIn = CheckInHive(
      id: _uuid.v4(),
      taskId: taskId,
      notes: notes,
      category: category,
      latitude: latitude,
      longitude: longitude,
      createdAt: DateTime.now(),
      syncStatus: CheckInSyncStatusHive.pending,
    );

    await box.add(checkIn);
  }

  /// Get all check-ins for a task
  Future<List<CheckIn>> getCheckInsForTask(String taskId) async {
    final box = await Hive.openBox<CheckInHive>(HiveBoxes.checkIns);

    return box.values
        .where((c) => c.taskId == taskId)
        .map((e) => e.toDomain())
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Update sync status (after successful / failed sync)
  Future<void> updateSyncStatus({
    required String checkInId,
    required CheckInSyncStatus status,
  }) async {
    final box = await Hive.openBox<CheckInHive>(HiveBoxes.checkIns);

    final hiveItem = box.values.firstWhere((c) => c.id == checkInId);

    hiveItem.syncStatus = status.toHive();
    await hiveItem.save();
  }

  /// Get all pending check-ins (for sync)
  Future<List<CheckIn>> getPendingCheckIns() async {
    final box = await Hive.openBox<CheckInHive>(HiveBoxes.checkIns);

    return box.values
        .where((c) => c.syncStatus == CheckInSyncStatusHive.pending)
        .map((e) => e.toDomain())
        .toList();
  }
}
