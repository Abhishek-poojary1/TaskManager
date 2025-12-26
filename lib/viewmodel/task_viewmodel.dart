import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repository/task_repository.dart';
import '../domain/models/task.dart';
import '../domain/models/user.dart';

import '../domain/enums/task_filter.dart';
import '../domain/enums/task_sort.dart';
import '../domain/enums/task_status.dart';
import '../domain/enums/task_priority.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

final taskViewModelProvider =
    StateNotifierProvider<TaskViewModel, AsyncValue<List<Task>>>(
      (ref) => TaskViewModel(ref.read(taskRepositoryProvider)),
    );

class TaskViewModel extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskRepository _repository;

  TaskViewModel(this._repository) : super(const AsyncLoading());

  /// Local cache (source of truth)
  List<Task> _allTasks = [];

  TaskFilter _currentFilter = TaskFilter.all;
  TaskSort _currentSort = TaskSort.dueDate;

  // =========================
  // LOAD TASKS
  // ==============R===========
  Future<void> loadTasks(User currentUser) async {
    if (state is AsyncData && (state as AsyncData).value!.isNotEmpty) {
      return;
    }

    await forceReloadTasks(currentUser);
  }

  Future<void> forceReloadTasks(User currentUser) async {
    state = const AsyncLoading();

    try {
      final tasks = await _repository.getTasksForUser(currentUser);
      state = AsyncData(tasks);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // =========================
  // CREATE TASK (ADMIN)
  // =========================
  Future<void> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriority priority,
    required String assignedUserId,
    required User currentUser,
  }) async {
    await _repository.createTask(
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      assignedUserId: assignedUserId,
    );

    await loadTasks(currentUser);
  }

  // =========================
  // UPDATE STATUS (DIRTY WRITE)
  // =========================
  Future<void> updateStatus(
    Task task,
    TaskStatus status,
    User currentUser,
  ) async {
    await _repository.updateTaskStatus(task.id, status);

    // Update local cache without full reload
    _allTasks = _allTasks.map((t) {
      if (t.id == task.id) {
        return t.copyWith(
          status: status,
          isSynced: false,
          updatedAt: DateTime.now(),
        );
      }
      return t;
    }).toList();

    _applyFilterAndSort();
  }

  // =========================
  // SYNC (KEEP NAME AS IS)
  // =========================
  Future<void> trySyncTasks() async {
    final pendingTasks = await _repository.getPendingTasks();

    for (final task in pendingTasks) {
      // Future: API / Firebase / Supabase call here
      await _repository.markSynced(task.id);
    }

    // Refresh local cache after sync
    final refreshed = await _repository.getTasks();
    _allTasks = refreshed;

    _applyFilterAndSort();
  }

  // =========================
  // FILTER
  // =========================
  void applyFilter(TaskFilter filter) {
    _currentFilter = filter;
    _applyFilterAndSort();
  }

  // =========================
  // SORT
  // =========================
  void applySort(TaskSort sort) {
    _currentSort = sort;
    _applyFilterAndSort();
  }

  // =========================
  // INTERNAL: FILTER + SORT
  // =========================
  void _applyFilterAndSort() {
    List<Task> visibleTasks = List.from(_allTasks);

    // Filter
    if (_currentFilter != TaskFilter.all) {
      visibleTasks = visibleTasks.where((task) {
        switch (_currentFilter) {
          case TaskFilter.open:
            return task.status == TaskStatus.open;
          case TaskFilter.inProgress:
            return task.status == TaskStatus.inProgress;
          case TaskFilter.done:
            return task.status == TaskStatus.done;
          default:
            return true;
        }
      }).toList();
    }

    // Sort
    switch (_currentSort) {
      case TaskSort.dueDate:
        visibleTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;

      case TaskSort.priority:
        visibleTasks.sort(
          (a, b) => b.priority.index.compareTo(a.priority.index),
        );
        break;
    }

    state = AsyncData(visibleTasks);
  }
}
