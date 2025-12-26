import 'package:offline_task_app/domain/enums/task_priority.dart';
import 'package:offline_task_app/domain/enums/task_status.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final String location;
  final String assignedUserId; // ✅ ADD
  final bool isSynced;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.location,
    required this.assignedUserId, // ✅ ADD
    required this.isSynced,
    required this.updatedAt,
  });
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    String? location,
    String? assignedUserId,
    bool? isSynced,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      location: location ?? this.location,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
