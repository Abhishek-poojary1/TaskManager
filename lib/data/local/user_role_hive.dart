import 'package:hive/hive.dart';

part 'user_role_hive.g.dart';

@HiveType(typeId: 8)
enum UserRole {
  @HiveField(0)
  admin,

  @HiveField(1)
  member,
}
