import 'package:hive/hive.dart';
import 'package:offline_task_app/data/local/user_role_hive.dart';
import '../../domain/models/user.dart';

part 'user_hive.g.dart';

@HiveType(typeId: 7)
class UserHive extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String email;

  @HiveField(2)
  String passwordHash;

  @HiveField(3)
  UserRole role;

  UserHive({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.role,
  });

  User toDomain() {
    return User(id: id, email: email, passwordHash: passwordHash, role: role);
  }
}
