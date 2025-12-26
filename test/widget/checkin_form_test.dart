import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:offline_task_app/domain/enums/task_priority.dart';
import 'package:offline_task_app/domain/enums/task_status.dart';
import 'package:offline_task_app/domain/models/task.dart';
import 'package:offline_task_app/ui/checkin/checkin_form_screen.dart';

void main() {
  // 👇 Fake task for widget test
  final fakeTask = Task(
    id: 'task-1',
    title: 'Test Task',
    description: 'Test Description',
    status: TaskStatus.open,
    priority: TaskPriority.medium,
    dueDate: DateTime.now(),
    updatedAt: DateTime.now(),
    isSynced: false,
    assignedUserId: 'user-1',
    location: '',
  );

  testWidgets('check-in submit button works', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: CheckInFormScreen(task: fakeTask)),
      ),
    );

    // Enter valid notes (min 10 chars)
    await tester.enterText(
      find.byType(TextFormField).first,
      'Work completed successfully',
    );

    // Tap submit
    await tester.tap(find.text('Submit'));

    await tester.pump();

    // Ensure no infinite loader / crash
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
