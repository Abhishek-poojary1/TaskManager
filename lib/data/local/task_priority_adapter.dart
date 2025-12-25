import 'package:hive/hive.dart';
import '../../domain/enums/task_priority.dart';

class TaskPriorityAdapter extends TypeAdapter<TaskPriority> {
  @override
  final int typeId = 3;

  @override
  TaskPriority read(BinaryReader reader) {
    return TaskPriority.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, TaskPriority obj) {
    writer.writeInt(obj.index);
  }
}
