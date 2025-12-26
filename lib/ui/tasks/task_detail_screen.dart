import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_task_app/data/local/user_role_hive.dart';
import 'package:offline_task_app/domain/enums/task_priority.dart';
import 'package:offline_task_app/viewmodel/checkin_viewmodel.dart';
import 'package:offline_task_app/viewmodel/user_providers.dart';

import '../../domain/models/task.dart';
import '../../domain/models/user.dart';
import '../../domain/enums/task_status.dart';
import '../../viewmodel/task_viewmodel.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../checkin/checkin_form_screen.dart';

class TaskDetailScreen extends ConsumerWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

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
    final authState = ref.watch(authViewModelProvider);
    final statusColor = _getStatusColor(task.status);
    final priorityColor = _getPriorityColor(task.priority);

    return authState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('Auth error: $e'),
            ],
          ),
        ),
      ),
      data: (User? user) {
        if (user == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Not logged in'),
                ],
              ),
            ),
          );
        }

        final bool isMember = user.role == UserRole.member;

        return Scaffold(
          appBar: AppBar(
            title: const Row(
              children: [
                Icon(Icons.assignment, size: 24),
                SizedBox(width: 12),
                Text(
                  'Task Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            elevation: 3,
            backgroundColor: Colors.deepPurple.shade700,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section with Status
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor.withOpacity(0.2),
                        statusColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          task.status.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.description,
                                    size: 20,
                                    color: Colors.deepPurple.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Description',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                task.description,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.6,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 👤 ASSIGNED USER (ADMIN ONLY)
                      if (user.role == UserRole.admin)
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 20,
                                      color: Colors.deepPurple.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Assigned To',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Consumer(
                                  builder: (context, ref, _) {
                                    final assignedUserAsync = ref.watch(
                                      assignedUserProvider(task.assignedUserId),
                                    );

                                    return assignedUserAsync.when(
                                      loading: () =>
                                          const Text('Loading user...'),
                                      error: (_, __) => const Text(
                                        'Unable to load user',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      data: (assignedUser) {
                                        if (assignedUser == null) {
                                          return const Text(
                                            'User not found',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          );
                                        }

                                        return Row(
                                          children: [
                                            const Icon(Icons.email, size: 16),
                                            const SizedBox(width: 8),
                                            Text(
                                              assignedUser.email,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Details Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 20,
                                    color: Colors.deepPurple.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Task Information',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              _InfoRow(
                                icon: Icons.flag,
                                label: 'Priority',
                                value: task.priority.name.toUpperCase(),
                                valueColor: priorityColor,
                              ),
                              const Divider(height: 24),

                              _InfoRow(
                                icon: Icons.calendar_today,
                                label: 'Due Date',
                                value: _formatDate(task.dueDate),
                              ),
                              const Divider(height: 24),

                              _InfoRow(
                                icon: Icons.update,
                                label: 'Last Updated',
                                value: _formatDate(task.updatedAt),
                              ),
                              const Divider(height: 24),

                              _InfoRow(
                                icon: task.isSynced
                                    ? Icons.cloud_done
                                    : Icons.cloud_off,
                                label: 'Sync Status',
                                value: task.isSynced ? 'SYNCED' : 'NOT SYNCED',
                                valueColor: task.isSynced
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Status Update Section (for both Admin and Member)
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.swap_horiz,
                                    size: 20,
                                    color: Colors.deepPurple.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Update Status',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _StatusButton(ref, task, TaskStatus.open),
                                  _StatusButton(
                                    ref,
                                    task,
                                    TaskStatus.inProgress,
                                  ),
                                  _StatusButton(ref, task, TaskStatus.done),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 📋 CHECK-INS SECTION
                      const Text(
                        'Check-ins',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Consumer(
                        builder: (context, ref, _) {
                          final state = ref.watch(
                            checkInsForTaskProvider(task.id),
                          );

                          return state.when(
                            loading: () => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            error: (e, _) => Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red.shade400,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Error loading check-ins',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            data: (checkIns) {
                              if (checkIns.isEmpty) {
                                return Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.grey.shade400,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'No check-ins yet',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              return Column(
                                children: checkIns.map((c) {
                                  return Card(
                                    elevation: 2,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Header Row
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors
                                                      .deepPurple
                                                      .shade700
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  Icons.location_on,
                                                  color: Colors
                                                      .deepPurple
                                                      .shade700,
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      c.category,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                  ],
                                                ),
                                              ),
                                              // Sync Status Badge
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      c.syncStatus.name ==
                                                          'synced'
                                                      ? Colors.green.shade50
                                                      : Colors.orange.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color:
                                                        c.syncStatus.name ==
                                                            'synced'
                                                        ? Colors.green.shade300
                                                        : Colors
                                                              .orange
                                                              .shade300,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      c.syncStatus.name ==
                                                              'synced'
                                                          ? Icons.cloud_done
                                                          : Icons.cloud_off,
                                                      size: 14,
                                                      color:
                                                          c.syncStatus.name ==
                                                              'synced'
                                                          ? Colors
                                                                .green
                                                                .shade700
                                                          : Colors
                                                                .orange
                                                                .shade700,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      c.syncStatus.name
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            c.syncStatus.name ==
                                                                'synced'
                                                            ? Colors
                                                                  .green
                                                                  .shade700
                                                            : Colors
                                                                  .orange
                                                                  .shade700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 16),

                                          // Location Coordinates
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.grey.shade200,
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                // Latitude
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.north,
                                                      size: 18,
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Latitude:',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors
                                                            .grey
                                                            .shade700,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        c.latitude
                                                            .toStringAsFixed(6),
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors
                                                              .grey
                                                              .shade900,
                                                          fontFamily:
                                                              'monospace',
                                                        ),
                                                        textAlign:
                                                            TextAlign.right,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Divider(
                                                  height: 1,
                                                  color: Colors.grey.shade300,
                                                ),
                                                const SizedBox(height: 8),
                                                // Longitude
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.east,
                                                      size: 18,
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Longitude:',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors
                                                            .grey
                                                            .shade700,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        c.longitude
                                                            .toStringAsFixed(6),
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors
                                                              .grey
                                                              .shade900,
                                                          fontFamily:
                                                              'monospace',
                                                        ),
                                                        textAlign:
                                                            TextAlign.right,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Notes (if not empty)
                                          if (c.notes.isNotEmpty) ...[
                                            const SizedBox(height: 12),
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons.note_outlined,
                                                    size: 16,
                                                    color: Colors.blue.shade700,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      c.notes,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors
                                                            .grey
                                                            .shade800,
                                                        height: 1.4,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Check-in Button (Member Only)
                      if (isMember)
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.edit_note, size: 24),
                            label: const Text(
                              'Create Check-in',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple.shade700,
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CheckInFormScreen(task: task),
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
    }

    return '${date.day}/${date.month}/${date.year}';
  }
}

/// ----------------------
/// INFO ROW WIDGET
/// ----------------------
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? Colors.grey.shade900,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

/// ----------------------
/// STATUS BUTTON
/// ----------------------
class _StatusButton extends StatelessWidget {
  final WidgetRef ref;
  final Task task;
  final TaskStatus status;

  const _StatusButton(this.ref, this.task, this.status);

  Color get _color {
    switch (status) {
      case TaskStatus.open:
        return Colors.blue;
      case TaskStatus.inProgress:
        return Colors.orange;
      case TaskStatus.done:
        return Colors.green;
    }
  }

  IconData get _icon {
    switch (status) {
      case TaskStatus.open:
        return Icons.radio_button_unchecked;
      case TaskStatus.inProgress:
        return Icons.timelapse;
      case TaskStatus.done:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelected = task.status == status;
    final user = ref.read(authViewModelProvider).value!;

    return FilterChip(
      avatar: Icon(_icon, size: 18, color: isSelected ? Colors.white : _color),
      label: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: isSelected ? Colors.white : _color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      selected: isSelected,
      selectedColor: _color,
      backgroundColor: _color.withOpacity(0.15),
      checkmarkColor: Colors.white,
      side: BorderSide(color: _color, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      onSelected: (_) {
        ref
            .read(taskViewModelProvider.notifier)
            .updateStatus(task, status, user);
        Navigator.pop(context);
      },
    );
  }
}
