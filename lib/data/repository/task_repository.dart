import 'package:hive/hive.dart';
import 'package:offline_task_app/data/local/user_role_hive.dart';
import 'package:offline_task_app/domain/models/user.dart';
import 'package:uuid/uuid.dart';

import '../local/hive_boxes.dart';
import '../local/task_hive.dart';

import '../../domain/models/task.dart';
import '../../domain/enums/task_status.dart';
import '../../domain/enums/task_priority.dart';

class TaskRepository {
  final _uuid = const Uuid();

  Future<List<Task>> getTasks() async {
    final box = await Hive.openBox<TaskHive>(HiveBoxes.tasks);
    return box.values.map((e) => e.toDomain()).toList();
  }

  Future<void> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriority priority,
    required String assignedUserId,
  }) async {
    final box = await Hive.openBox<TaskHive>(HiveBoxes.tasks);

    await box.add(
      TaskHive(
        id: _uuid.v4(),
        title: title,
        description: description,
        status: TaskStatus.open,
        priority: priority,
        dueDate: dueDate,
        location: '',
        assignedUserId: assignedUserId,

        // 🔐 OFFLINE-FIRST
        isSynced: false,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    final box = await Hive.openBox<TaskHive>(HiveBoxes.tasks);

    final task = box.values.firstWhere((t) => t.id == taskId);
    task
      ..status = status
      ..updatedAt = DateTime.now()
      ..isSynced = false; // 🔴 mark dirty

    await task.save();
  }

  Future<List<Task>> getTasksForUser(User user) async {
    final box = await Hive.openBox<TaskHive>(HiveBoxes.tasks);

    // Admin sees all tasks
    if (user.role == UserRole.admin) {
      return box.values.map((e) => e.toDomain()).toList();
    }

    // Member sees only assigned tasks
    return box.values
        .where((t) => t.assignedUserId == user.id)
        .map((e) => e.toDomain())
        .toList();
  }

  /// 🔁 Used later by sync worker
  Future<List<TaskHive>> getPendingTasks() async {
    final box = await Hive.openBox<TaskHive>(HiveBoxes.tasks);
    return box.values.where((t) => !t.isSynced).toList();
  }

  /// 🔁 Mark synced after successful upload
  Future<void> markSynced(String taskId) async {
    final box = await Hive.openBox<TaskHive>(HiveBoxes.tasks);
    final task = box.values.firstWhere((t) => t.id == taskId);
    task
      ..isSynced = true
      ..updatedAt = DateTime.now();
    await task.save();
  }
}
