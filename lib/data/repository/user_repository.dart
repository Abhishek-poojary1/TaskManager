import 'package:hive/hive.dart';
import 'package:offline_task_app/data/local/hashpass.dart';
import 'package:offline_task_app/data/local/hive_boxes.dart';
import 'package:offline_task_app/data/local/user_hive.dart';
import 'package:offline_task_app/data/local/user_role_hive.dart';
import 'package:offline_task_app/domain/models/user.dart';
import 'package:uuid/uuid.dart';

class UserRepository {
  Future<void> signUp({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final box = await Hive.openBox<UserHive>('users');

    final exists = box.values.any((u) => u.email == email);
    if (exists) {
      throw Exception('User already exists');
    }

    await box.add(
      UserHive(
        id: const Uuid().v4(),
        email: email,
        passwordHash: hashPassword(password),
        role: role,
      ),
    );
  }

  Future<List<User>> getAllUsers() async {
    final box = await Hive.openBox<UserHive>(HiveBoxes.users);
    return box.values.map((u) => u.toDomain()).toList();
  }

  Future<void> seedAdminIfNotExists() async {
    final box = await Hive.openBox<UserHive>(HiveBoxes.users);

    final exists = box.values.any((u) => u.role == UserRole.admin);
    if (exists) return;

    await box.add(
      UserHive(
        id: 'admin-001',
        email: 'admin@demo.com',
        passwordHash: hashPassword('admin123'),
        role: UserRole.admin,
      ),
    );
  }

  Future<User?> getUserById(String id) async {
    final box = await Hive.openBox<UserHive>(HiveBoxes.users);

    try {
      final userHive = box.values.firstWhere((u) => u.id == id);
      return userHive.toDomain();
    } catch (_) {
      return null;
    }
  }

  Future<User?> login({required String email, required String password}) async {
    final box = await Hive.openBox<UserHive>('users');
    final hash = hashPassword(password);

    try {
      final user = box.values.firstWhere(
        (u) => u.email == email && u.passwordHash == hash,
      );
      return user.toDomain();
    } catch (_) {
      return null;
    }
  }
}
