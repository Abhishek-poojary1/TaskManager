import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_task_app/domain/enums/task_priority.dart';
import 'package:offline_task_app/domain/enums/task_status.dart';

import '../../viewmodel/task_viewmodel.dart';
import '../../viewmodel/auth_viewmodel.dart';

import '../../domain/models/task.dart';
import '../../domain/models/user.dart';
import '../../domain/enums/task_filter.dart';
import '../../domain/enums/task_sort.dart';

import '../admin/create_task_screen.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.open:
        return Colors.blue;
      case TaskStatus.inProgress:
        return Colors.orange;
      case TaskStatus.done:
        return Colors.green;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.grey;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskViewModelProvider);
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.task_alt, size: 24),
            SizedBox(width: 12),
            Text(
              'Task Manager',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        elevation: 3,
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        actions: authState.maybeWhen(
          data: (User? user) {
            if (user == null) return [];

            final bool isAdmin = user.role == UserRole.admin;

            return [
              // ➕ CREATE TASK (ADMIN ONLY)
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 26),
                  tooltip: 'Create Task',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateTaskScreen(),
                      ),
                    );
                  },
                ),

              // 🔍 FILTER (STATUS)
              PopupMenuButton<TaskFilter>(
                icon: const Icon(Icons.filter_list, size: 26),
                tooltip: 'Filter Tasks',
                onSelected: (filter) {
                  ref.read(taskViewModelProvider.notifier).applyFilter(filter);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: TaskFilter.all,
                    child: Row(
                      children: [
                        Icon(Icons.list, size: 20, color: Colors.deepPurple),
                        SizedBox(width: 12),
                        Text(
                          'All Tasks',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: TaskFilter.open,
                    child: Row(
                      children: [
                        Icon(
                          Icons.radio_button_unchecked,
                          size: 20,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Open',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: TaskFilter.inProgress,
                    child: Row(
                      children: [
                        Icon(Icons.timelapse, size: 20, color: Colors.orange),
                        SizedBox(width: 12),
                        Text(
                          'In Progress',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: TaskFilter.done,
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 20, color: Colors.green),
                        SizedBox(width: 12),
                        Text(
                          'Done',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 🔃 SORT
              PopupMenuButton<TaskSort>(
                icon: const Icon(Icons.sort, size: 26),
                tooltip: 'Sort Tasks',
                onSelected: (sort) {
                  ref.read(taskViewModelProvider.notifier).applySort(sort);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: TaskSort.dueDate,
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: Colors.deepPurple,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Sort by Due Date',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: TaskSort.priority,
                    child: Row(
                      children: [
                        Icon(
                          Icons.priority_high,
                          size: 20,
                          color: Colors.deepPurple,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Sort by Priority',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 🔐 LOGOUT
              IconButton(
                icon: const Icon(Icons.logout, size: 24),
                tooltip: 'Logout',
                color: Colors.red.shade200,
                onPressed: () {
                  ref.read(authViewModelProvider.notifier).logout();
                },
              ),
              const SizedBox(width: 8),
            ];
          },
          orElse: () => [],
        ),
      ),

      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('Auth error: $e', style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Not logged in', style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }

          return taskState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error: $e', style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
            data: (List<Task> tasks) {
              if (tasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No tasks available',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await ref.read(taskViewModelProvider.notifier).trySyncTasks();
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final statusColor = _getStatusColor(task.status);
                    final priorityColor = _getPriorityColor(task.priority);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 4,
                      ),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: statusColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TaskDetailScreen(task: task),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Row: Title + Status Badge
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: statusColor,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      task.status.name.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Priority & Due Date Row
                              Row(
                                children: [
                                  // Priority Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: priorityColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.flag,
                                          size: 14,
                                          color: priorityColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          task.priority.name.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: priorityColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // Due Date
                                  Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDate(task.dueDate),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Sync Status Row
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: task.isSynced
                                          ? Colors.green.withOpacity(0.15)
                                          : Colors.amber.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: task.isSynced
                                            ? Colors.green
                                            : Colors.amber.shade700,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          task.isSynced
                                              ? Icons.cloud_done
                                              : Icons.cloud_off,
                                          size: 14,
                                          color: task.isSynced
                                              ? Colors.green
                                              : Colors.amber.shade700,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          task.isSynced ? 'SYNCED' : 'In Local',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: task.isSynced
                                                ? Colors.green
                                                : Colors.amber.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    final difference = taskDate.difference(today).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 1 && difference <= 7) {
      return 'In $difference days';
    } else if (difference < -1) {
      return '${difference.abs()} days ago';
    }

    return '${date.day}/${date.month}/${date.year}';
  }
}
