import 'package:hive/hive.dart';

import '../../domain/models/user.dart';
import '../local/hive_boxes.dart';
import 'user_repository.dart';

class AuthRepository {
  final UserRepository _userRepository = UserRepository();

  /// Restore logged-in user from session
  Future<User?> getCurrentUser() async {
    final box = await Hive.openBox(HiveBoxes.auth);
    final userId = box.get('userId');

    if (userId == null) return null;

    return _userRepository.getUserById(userId);
  }

  /// Login (email + password already validated elsewhere)
  Future<User> login(User user) async {
    final box = await Hive.openBox(HiveBoxes.auth);

    await box.put('userId', user.id);

    return user;
  }

  /// Logout
  Future<void> logout() async {
    final box = await Hive.openBox(HiveBoxes.auth);
    await box.clear();
  }
}
