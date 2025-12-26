import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_task_app/domain/enums/checkin_status.dart';
import 'package:offline_task_app/domain/models/checkin.dart';

import 'package:offline_task_app/viewmodel/checkin_viewmodel.dart';

void main() {
  test('check-in submit changes state to loading then success', () async {
    final container = ProviderContainer();
    final vm = container.read(checkInViewModelProvider.notifier);

    final checkIn = CheckIn(
      id: '1',
      taskId: 'task1',
      notes: 'done',
      category: 'visit',
      latitude: 10,
      longitude: 20,
      createdAt: DateTime.now(),
      syncStatus: CheckInSyncStatus.pending,
    );

    await vm.submit(checkIn);

    expect(container.read(checkInViewModelProvider), isA<AsyncData>());
  });
}
