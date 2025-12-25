import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repository/auth_repository.dart';
import '../domain/models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AsyncValue<User?>>(
      (ref) => AuthViewModel(ref),
    );

class AuthViewModel extends StateNotifier<AsyncValue<User?>> {
  AuthViewModel(this.ref) : super(const AsyncLoading()) {
    _loadSession();
  }

  final Ref ref;

  Future<void> _loadSession() async {
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    state = AsyncData(user);
  }

  Future<void> login(String email) async {
    state = const AsyncLoading();
    try {
      final user = await ref.read(authRepositoryProvider).login(email);
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}
