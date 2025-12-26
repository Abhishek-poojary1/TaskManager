import 'package:flutter_test/flutter_test.dart';
import 'package:offline_task_app/data/repository/checkin_repository.dart';
import 'package:offline_task_app/domain/enums/checkin_status.dart';
import 'package:offline_task_app/domain/models/checkin.dart';

import '../fakes/test_hive_init.dart';

void main() {
  setUp(() async {
    await initTestHive();
  });
  test('save & retrieve check-in by taskId', () async {
    final repo = CheckInRepository();

    final checkIn = CheckIn(
      id: '1',
      taskId: 'task1',
      notes: 'hello',
      category: 'visit',
      latitude: 12,
      longitude: 77,
      createdAt: DateTime.now(),
      syncStatus: CheckInSyncStatus.pending,
    );

    await repo.createCheckIn(checkIn);

    final list = await repo.getCheckInsForTask('task1');
    expect(list.isNotEmpty, true);
  });
}
