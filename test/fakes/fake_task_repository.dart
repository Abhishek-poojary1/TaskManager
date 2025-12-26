import 'package:offline_task_app/data/repository/task_repository.dart';
import 'package:offline_task_app/domain/models/task.dart';
import 'package:offline_task_app/domain/enums/task_status.dart';
import 'package:offline_task_app/domain/enums/task_priority.dart';
import 'package:offline_task_app/domain/models/user.dart';

class FakeTaskRepository extends TaskRepository {
  @override
  Future<List<Task>> getTasksForUser(User user) async {
    return [
      Task(
        id: '1',
        title: 'Open High Priority',
        description: 'Test',
        status: TaskStatus.open,
        priority: TaskPriority.high,
        dueDate: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: true,
        assignedUserId: user.id,
        location: '',
      ),
      Task(
        id: '2',
        title: 'Done Low Priority',
        description: 'Test',
        status: TaskStatus.done,
        priority: TaskPriority.low,
        dueDate: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: true,
        assignedUserId: user.id,
        location: '',
      ),
    ];
  }
}
