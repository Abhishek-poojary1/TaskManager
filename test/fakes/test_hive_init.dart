import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:offline_task_app/data/local/task_hive.dart';
import 'package:offline_task_app/data/local/checkin_hive.dart';
import 'package:offline_task_app/data/local/user_hive.dart';
import 'package:offline_task_app/data/local/user_role_hive.dart';
import 'package:offline_task_app/data/local/checkin_status_adapter.dart';
import 'package:offline_task_app/domain/enums/task_status_adapter.dart';
import 'package:offline_task_app/data/local/task_priority_adapter.dart';

Future<void> initTestHive() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final dir = Directory.systemTemp.createTempSync();
  Hive.init(dir.path);

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserRoleAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(UserHiveAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(TaskStatusAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(TaskPriorityAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(TaskHiveAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(CheckInStatusAdapter());
  }
  if (!Hive.isAdapterRegistered(6)) {
    Hive.registerAdapter(CheckInHiveAdapter());
  }
}
