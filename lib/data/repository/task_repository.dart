import 'package:hive/hive.dart';
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
    required TaskPriority priority,
    required DateTime dueDate,
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
        location: 'Unassigned',
        updatedAt: DateTime.now(),
        isSynced: false,
      ),
    );
  }

  Future<void> seedTasksIfEmpty() async {
    final box = await Hive.openBox<TaskHive>(HiveBoxes.tasks);
    if (box.isNotEmpty) return;

    await box.addAll([
      TaskHive(
        id: _uuid.v4(),
        title: 'Site inspection',
        description: 'Inspect safety compliance',
        status: TaskStatus.open,
        priority: TaskPriority.high,
        dueDate: DateTime.now().add(const Duration(days: 1)),
        location: 'Warehouse A',
        updatedAt: DateTime.now(),
        isSynced: true,
      ),
      TaskHive(
        id: _uuid.v4(),
        title: 'Progress report',
        description: 'Daily progress update',
        status: TaskStatus.inProgress,
        priority: TaskPriority.medium,
        dueDate: DateTime.now().add(const Duration(days: 2)),
        location: 'Site B',
        updatedAt: DateTime.now(),
        isSynced: true,
      ),
    ]);
  }

  Future<void> updateTask(Task task) async {
    final box = await Hive.openBox<TaskHive>(HiveBoxes.tasks);
    final taskHive = box.values.firstWhere((e) => e.id == task.id);
    taskHive
      ..status = task.status
      ..updatedAt = DateTime.now()
      ..isSynced = false;
    await taskHive.save();
  }
}
