import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_repository.dart';
import '../domain/user.dart';

/// The signed-in user, or null when signed out.
///
/// Loading only while the stored token is being checked at startup.
class AuthController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final tokens = ref.read(tokenStorageProvider);
    final token = await tokens.read();
    if (token == null) return null;

    try {
      return await ref.read(authRepositoryProvider).me();
    } on ApiException catch (e) {
      if (e.isUnauthorized) await tokens.clear();
      return null;
    }
  }

  Future<void> signIn(AuthSession session) async {
    await ref.read(tokenStorageProvider).write(session.token);
    state = AsyncData(session.user);
  }

  Future<void> signOut() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } on ApiException {
      // The token is dropped locally either way.
    }
    await _clear();
  }

  /// The server rejected the token, so the session is already gone.
  Future<void> expire() async {
    if (state.value == null) return;
    await _clear();
  }

  Future<void> _clear() async {
    await ref.read(tokenStorageProvider).clear();
    state = const AsyncData(null);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, User?>(AuthController.new, retry: (_, _) => null);
