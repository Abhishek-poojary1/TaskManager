import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:offline_task_app/viewmodel/auth_viewmodel.dart';

void main() {
  test('login success updates state with user', () async {
    final container = ProviderContainer();
    final vm = container.read(authViewModelProvider.notifier);

    await vm.login(email: 'user@test.com', password: '123456');

    final state = container.read(authViewModelProvider);
    expect(state.value, isNotNull);
  });

  test('login fails with wrong password', () async {
    final container = ProviderContainer();
    final vm = container.read(authViewModelProvider.notifier);

    expect(
      () => vm.login(email: 'user@test.com', password: 'wrong'),
      throwsException,
    );
  });
}
