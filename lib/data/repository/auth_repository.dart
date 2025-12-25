import 'package:hive/hive.dart';
import '../../domain/models/user.dart';
import '../local/hive_boxes.dart';

class AuthRepository {
  Future<User?> getCurrentUser() async {
    final box = await Hive.openBox(HiveBoxes.auth);
    final email = box.get('email');
    final role = box.get('role');

    if (email == null || role == null) return null;

    return User(
      id: 'local-user',
      email: email,
      role: role == 'admin' ? UserRole.admin : UserRole.member,
    );
  }

  Future<User> login(String email) async {
    final box = await Hive.openBox(HiveBoxes.auth);

    final role = email.contains('admin') ? UserRole.admin : UserRole.member;

    await box.put('email', email);
    await box.put('role', role.name);

    return User(id: 'local-user', email: email, role: role);
  }

  Future<void> logout() async {
    final box = await Hive.openBox(HiveBoxes.auth);
    await box.clear();
  }
}
