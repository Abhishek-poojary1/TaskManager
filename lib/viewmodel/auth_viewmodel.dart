import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_task_app/data/local/user_role_hive.dart';

import '../data/repository/auth_repository.dart';
import '../data/repository/user_repository.dart';
import '../domain/models/user.dart';
import '../data/repository/providers.dart';

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AsyncValue<User?>>(
      (ref) => AuthViewModel(
        ref.read(authRepositoryProvider),
        ref.read(userRepositoryProvider),
      ),
    );

class AuthViewModel extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  AuthViewModel(this._authRepository, this._userRepository)
    : super(const AsyncLoading()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final user = await _authRepository.getCurrentUser();
    state = AsyncData(user);
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();

    final user = await _userRepository.login(email: email, password: password);

    if (user == null) {
      state = AsyncError('Invalid credentials', StackTrace.current);
      return;
    }

    await _authRepository.login(user);
    state = AsyncData(user);
  }

  Future<void> signup({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    state = const AsyncLoading();

    // 🔒 HARD ENFORCEMENT
    if (role != UserRole.member) {
      state = AsyncError(
        'Only member accounts can be created',
        StackTrace.current,
      );
      return;
    }

    await _userRepository.signUp(
      email: email,
      password: password,
      role: UserRole.member,
    );

    final user = await _userRepository.login(email: email, password: password);

    if (user != null) {
      await _authRepository.login(user);
      state = AsyncData(user);
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AsyncData(null);
  }
}
