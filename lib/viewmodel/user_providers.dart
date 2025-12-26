import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repository/user_repository.dart';
import '../domain/models/user.dart';

final usersProvider = FutureProvider<List<User>>((ref) async {
  final repo = UserRepository();
  return repo.getAllUsers();
});
final assignedUserProvider = FutureProvider.family<User?, String>((
  ref,
  userId,
) async {
  final repo = UserRepository();
  return repo.getUserById(userId);
});
