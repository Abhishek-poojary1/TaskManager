import '../../data/local/user_role_hive.dart';

class User {
  final String id;
  final String email;
  final String passwordHash;
  final UserRole role;

  User({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.role,
  });
}
