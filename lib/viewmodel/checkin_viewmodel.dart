import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repository/checkin_repository.dart';
import '../domain/models/checkin.dart';

final checkInRepositoryProvider = Provider<CheckInRepository>(
  (_) => CheckInRepository(),
);

final checkInViewModelProvider =
    StateNotifierProvider<CheckInViewModel, AsyncValue<void>>(
      (ref) => CheckInViewModel(ref),
    );

class CheckInViewModel extends StateNotifier<AsyncValue<void>> {
  CheckInViewModel(this.ref) : super(const AsyncData(null));

  final Ref ref;

  Future<void> submit(CheckIn checkIn) async {
    state = const AsyncLoading();
    try {
      await ref.read(checkInRepositoryProvider).createCheckIn(checkIn);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
