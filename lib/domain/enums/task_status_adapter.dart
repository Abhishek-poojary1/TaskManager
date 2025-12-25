import 'package:hive/hive.dart';
import '../../domain/enums/task_status.dart';

class TaskStatusAdapter extends TypeAdapter<TaskStatus> {
  @override
  final int typeId = 2;

  @override
  TaskStatus read(BinaryReader reader) {
    return TaskStatus.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, TaskStatus obj) {
    writer.writeInt(obj.index);
  }
}
