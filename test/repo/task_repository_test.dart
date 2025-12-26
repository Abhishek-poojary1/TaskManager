import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:offline_task_app/data/local/task_hive.dart';
import 'package:offline_task_app/data/local/hive_boxes.dart';
import 'package:offline_task_app/data/repository/task_repository.dart';
import 'package:offline_task_app/domain/enums/task_priority.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(TaskHiveAdapter());
    }

    await Hive.openBox<TaskHive>(HiveBoxes.tasks);
  });

  tearDown(() async {
    await Hive.box<TaskHive>(HiveBoxes.tasks).clear();
  });

  test('create & read task from hive', () async {
    final repo = TaskRepository();

    await repo.createTask(
      title: 'Test Task',
      description: 'Test Description',
      dueDate: DateTime.now(),
      priority: TaskPriority.medium,
      assignedUserId: '',
    );

    final tasks = await repo.getTasks();

    expect(tasks.length, 1);
    expect(tasks.first.title, 'Test Task');
    expect(tasks.first.description, 'Test Description');
    expect(tasks.first.location, 'Unassigned'); // internal default
  });
}
