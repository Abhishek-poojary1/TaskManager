import '../enums/task_status.dart';
import '../enums/task_priority.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime dueDate;
  final String location;
  final DateTime updatedAt;
  final bool isSynced;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.location,
    required this.updatedAt,
    required this.isSynced,
  });

  Task copyWith({TaskStatus? status, bool? isSynced, DateTime? updatedAt}) {
    return Task(
      id: id,
      title: title,
      description: description,
      status: status ?? this.status,
      priority: priority,
      dueDate: dueDate,
      location: location,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
