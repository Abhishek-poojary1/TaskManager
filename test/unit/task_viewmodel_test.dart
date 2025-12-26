import 'package:flutter_test/flutter_test.dart';
import 'package:offline_task_app/data/local/user_role_hive.dart';
import 'package:offline_task_app/domain/enums/task_filter.dart';
import 'package:offline_task_app/domain/enums/task_priority.dart';
import 'package:offline_task_app/domain/enums/task_sort.dart';
import 'package:offline_task_app/domain/enums/task_status.dart';
import 'package:offline_task_app/domain/models/user.dart';
import 'package:offline_task_app/viewmodel/task_viewmodel.dart';

import '../fakes/fake_task_repository.dart';

void main() {
  late User testUser;

  setUp(() {
    testUser = User(
      id: 'user1',
      email: 'user@test.com',
      role: UserRole.member,
      passwordHash: 'hashed_password',
    );
  });

  test('filter open tasks only', () async {
    final repo = FakeTaskRepository();
    final vm = TaskViewModel(repo);

    await vm.loadTasks(testUser);

    vm.applyFilter(TaskFilter.open);

    final tasks = vm.state.value!;
    expect(tasks.isNotEmpty, true);
    expect(tasks.every((t) => t.status == TaskStatus.open), true);
  });

  test('sort tasks by priority', () async {
    final repo = FakeTaskRepository();
    final vm = TaskViewModel(repo);

    await vm.loadTasks(testUser);

    vm.applySort(TaskSort.priority);

    final tasks = vm.state.value!;
    expect(tasks.first.priority, TaskPriority.high);
  });
}
