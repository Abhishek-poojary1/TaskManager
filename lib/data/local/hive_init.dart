import 'package:hive_flutter/hive_flutter.dart';

import 'user_hive.dart';
import 'user_role_hive.dart';
import 'task_hive.dart';
import 'task_priority_adapter.dart';
import 'checkin_hive.dart'; // ✅ Make sure this import exists
import 'checkin_status_hive.dart';
import 'checkin_status_adapter.dart';
import 'package:offline_task_app/domain/enums/task_status_adapter.dart';

Future<void> initHive() async {
  await Hive.initFlutter();

  // USER ROLE
  if (!Hive.isAdapterRegistered(8)) {
    Hive.registerAdapter(UserRoleAdapter());
  }

  // USER
  if (!Hive.isAdapterRegistered(7)) {
    Hive.registerAdapter(UserHiveAdapter());
  }

  // TASK STATUS
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(TaskStatusAdapter());
  }

  // TASK PRIORITY
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(TaskPriorityAdapter());
  }

  // TASK
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(TaskHiveAdapter());
  }

  // CHECK-IN STATUS (domain enum)
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(CheckInStatusAdapter());
  }

  // CHECK-IN SYNC STATUS (hive enum) - Register BEFORE CheckInHive
  if (!Hive.isAdapterRegistered(9)) {
    Hive.registerAdapter(CheckInSyncStatusHiveAdapter());
  }

  // CHECK-IN (the object) - Register AFTER CheckInSyncStatusHive
  if (!Hive.isAdapterRegistered(6)) {
    Hive.registerAdapter(CheckInHiveAdapter()); // ✅ This should now work
  }
}
