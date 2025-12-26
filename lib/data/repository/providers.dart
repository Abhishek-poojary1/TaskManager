import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_repository.dart';
import 'user_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});
