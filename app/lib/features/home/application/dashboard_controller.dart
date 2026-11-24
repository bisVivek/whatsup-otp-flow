import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../data/dashboard_repository.dart';
import '../domain/dashboard.dart';

class DashboardController extends AsyncNotifier<Dashboard> {
  @override
  Future<Dashboard> build() => ref.read(dashboardRepositoryProvider).fetch();

  Future<void> refresh() async {
    final next = await AsyncValue.guard(ref.read(dashboardRepositoryProvider).fetch);
    // Keep showing the old data if a refresh fails.
    if (next.hasValue || !state.hasValue) state = next;
  }

  /// Optimistic toggle; rolls back if the server says no.
  Future<String?> toggleNotify() async {
    final current = state.value;
    if (current == null) return null;
    final want = !current.notifyLaunch;
    state = AsyncData(current.copyWith(notifyLaunch: want));

    try {
      final saved = await ref.read(dashboardRepositoryProvider).setNotifyLaunch(want);
      state = AsyncData(current.copyWith(notifyLaunch: saved));
      return null;
    } on ApiException catch (e) {
      state = AsyncData(current);
      return e.message;
    }
  }
}

final dashboardControllerProvider =
    AsyncNotifierProvider.autoDispose<DashboardController, Dashboard>(
  DashboardController.new,
  retry: (_, _) => null,
);
