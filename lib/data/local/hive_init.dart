import 'package:hive_flutter/hive_flutter.dart';
import 'package:offline_task_app/domain/enums/task_status_adapter.dart';
import 'checkin_hive.dart';
import 'checkin_status_adapter.dart';

import 'task_hive.dart';
import 'task_priority_adapter.dart';

Future<void> initHive() async {
  await Hive.initFlutter();

  Hive.registerAdapter(TaskHiveAdapter());
  Hive.registerAdapter(TaskStatusAdapter());
  Hive.registerAdapter(TaskPriorityAdapter());
  Hive.registerAdapter(CheckInHiveAdapter());
  Hive.registerAdapter(CheckInStatusAdapter());
}
