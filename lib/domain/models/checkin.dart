import '../enums/checkin_status.dart';

class CheckIn {
  final String id;
  final String taskId;
  final String notes;
  final String category;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final CheckInSyncStatus syncStatus;

  CheckIn({
    required this.id,
    required this.taskId,
    required this.notes,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.syncStatus,
  });

  CheckIn copyWith({CheckInSyncStatus? syncStatus}) {
    return CheckIn(
      id: id,
      taskId: taskId,
      notes: notes,
      category: category,
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
