import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repository/checkin_repository.dart';
import '../domain/models/checkin.dart';

/// ----------------------
/// PROVIDERS
/// ----------------------

final checkInRepositoryProvider = Provider<CheckInRepository>(
  (_) => CheckInRepository(),
);

final checkInViewModelProvider =
    StateNotifierProvider<CheckInViewModel, AsyncValue<void>>(
      (ref) => CheckInViewModel(ref),
    );

final checkInsForTaskProvider = FutureProvider.family<List<CheckIn>, String>((
  ref,
  taskId,
) async {
  final repo = ref.read(checkInRepositoryProvider);
  return repo.getCheckInsForTask(taskId);
});

/// ----------------------
/// VIEW MODEL
/// ----------------------

class CheckInViewModel extends StateNotifier<AsyncValue<void>> {
  CheckInViewModel(this.ref) : super(const AsyncData(null));

  final Ref ref;

  Future<void> submit(CheckIn checkIn) async {
    state = const AsyncLoading(); // ✅ THIS MUST COMPILE

    try {
      await ref.read(checkInRepositoryProvider).createCheckIn(checkIn);

      // Refresh admin + member views
      // ignore: unused_result
      ref.refresh(checkInsForTaskProvider(checkIn.taskId));

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
