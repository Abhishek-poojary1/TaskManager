import 'package:hive/hive.dart';
import '../../domain/enums/checkin_status.dart';

class CheckInStatusAdapter extends TypeAdapter<CheckInSyncStatus> {
  @override
  final int typeId = 5;

  @override
  CheckInSyncStatus read(BinaryReader reader) {
    return CheckInSyncStatus.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, CheckInSyncStatus obj) {
    writer.writeInt(obj.index);
  }
}
