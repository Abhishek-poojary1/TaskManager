import 'package:hive/hive.dart';
import '../../domain/models/task.dart';
import '../../domain/enums/task_status.dart';
import '../../domain/enums/task_priority.dart';

part 'task_hive.g.dart';

@HiveType(typeId: 3)
class TaskHive extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  TaskStatus status;

  @HiveField(4)
  TaskPriority priority;

  @HiveField(5)
  DateTime dueDate;

  @HiveField(6)
  String location;

  @HiveField(7)
  String assignedUserId; // ✅ ADD

  @HiveField(8)
  bool isSynced;

  @HiveField(9)
  DateTime updatedAt;

  TaskHive({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.location,
    required this.assignedUserId, // ✅ ADD
    required this.isSynced,
    required this.updatedAt,
  });

  Task toDomain() {
    return Task(
      id: id,
      title: title,
      description: description,
      status: status,
      priority: priority,
      dueDate: dueDate,
      location: location,
      assignedUserId: assignedUserId, // ✅ ADD
      isSynced: isSynced,
      updatedAt: updatedAt,
    );
  }
}
