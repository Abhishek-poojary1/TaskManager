import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:offline_task_app/data/local/hive_boxes.dart';
import 'package:offline_task_app/data/local/task_hive.dart';
import 'package:offline_task_app/domain/enums/task_priority.dart';

import '../data/repository/task_repository.dart';
import '../domain/models/task.dart';
import '../domain/enums/task_status.dart';
import '../domain/enums/task_filter.dart';
import '../domain/enums/task_sort.dart';

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => TaskRepository(),
);

final taskViewModelProvider =
    StateNotifierProvider<TaskViewModel, AsyncValue<List<Task>>>(
      (ref) => TaskViewModel(ref),
    );

class TaskViewModel extends StateNotifier<AsyncValue<List<Task>>> {
  TaskViewModel(this.ref) : super(const AsyncLoading()) {
    _loadTasks();
    trySyncTasks();
  }

  final Ref ref;

  List<Task> _allTasks = [];
  TaskFilter _filter = TaskFilter.all;
  TaskSort _sort = TaskSort.dueDate;

  Future<void> _loadTasks() async {
    await ref.read(taskRepositoryProvider).seedTasksIfEmpty();
    _allTasks = await ref.read(taskRepositoryProvider).getTasks();
    _apply();
  }

  void applyFilter(TaskFilter filter) {
    _filter = filter;
    _apply();
  }

  void applySort(TaskSort sort) {
    _sort = sort;
    _apply();
  }

  Future<void> trySyncTasks() async {
    final result = await Connectivity().checkConnectivity();

    if (result == ConnectivityResult.none) {
      // No internet → do nothing
      return;
    }

    // Simulate network sync
    await Future.delayed(const Duration(seconds: 2));

    final box = await Hive.openBox<TaskHive>(HiveBoxes.tasks);

    for (final task in box.values) {
      if (!task.isSynced) {
        task.isSynced = true;
        await task.save();
      }
    }

    _allTasks = await ref.read(taskRepositoryProvider).getTasks();
    _apply();
  }

  Future<void> createTask({
    required String title,
    required String description,
    required TaskPriority priority,
    required DateTime dueDate,
  }) async {
    await ref
        .read(taskRepositoryProvider)
        .createTask(
          title: title,
          description: description,
          priority: priority,
          dueDate: dueDate,
        );

    _allTasks = await ref.read(taskRepositoryProvider).getTasks();

    _apply();

    await trySyncTasks();
  }

  Future<void> updateStatus(Task task, TaskStatus newStatus) async {
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      status: newStatus,
      priority: task.priority,
      dueDate: task.dueDate,
      location: task.location,
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await ref.read(taskRepositoryProvider).updateTask(updatedTask);
    _allTasks = await ref.read(taskRepositoryProvider).getTasks();
    _apply();
  }

  void _apply() {
    // Always start from original data
    List<Task> list = List<Task>.from(_allTasks);

    // -------- FILTER --------
    if (_filter != TaskFilter.all) {
      final TaskStatus status;

      switch (_filter) {
        case TaskFilter.open:
          status = TaskStatus.open;
          break;
        case TaskFilter.inProgress:
          status = TaskStatus.inProgress;
          break;
        case TaskFilter.done:
          status = TaskStatus.done;
          break;
        case TaskFilter.all:
          status = TaskStatus.open; // unreachable
      }

      list = list.where((t) => t.status == status).toList();
    }

    // -------- SORT --------
    if (_sort == TaskSort.dueDate) {
      list.sort((a, b) {
        return a.dueDate.compareTo(b.dueDate); // earliest first
      });
    } else if (_sort == TaskSort.priority) {
      list.sort((a, b) {
        return b.priority.index.compareTo(a.priority.index); // high first
      });
    }

    state = AsyncData(list);
  }
}
