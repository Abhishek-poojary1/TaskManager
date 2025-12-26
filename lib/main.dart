import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_task_app/data/repository/user_repository.dart';
import 'data/local/hive_init.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  final userRepo = UserRepository();
  await userRepo.seedAdminIfNotExists();
  runApp(const ProviderScope(child: App()));
}
