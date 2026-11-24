import 'package:app_login/core/storage/token_storage.dart';
import 'package:app_login/features/auth/application/auth_controller.dart';
import 'package:app_login/features/auth/application/otp_flow_controller.dart';
import 'package:app_login/features/auth/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

void main() {
  late MemoryTokenStorage tokens;
  late FakeAuthRepository repo;
  late ProviderContainer container;

  setUp(() {
    tokens = MemoryTokenStorage();
    repo = FakeAuthRepository();
    container = ProviderContainer(overrides: [
      tokenStorageProvider.overrideWithValue(tokens),
      authRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(container.dispose);
  });

  OtpFlowController flow() => container.read(otpFlowControllerProvider.notifier);
  OtpFlowState state() => container.read(otpFlowControllerProvider);

  test('rejects a malformed number without calling the API', () async {
    expect(await flow().requestCode('12345'), isFalse);
    expect(state().error, 'Enter a valid WhatsApp number');
    expect(repo.requests, 0);
  });

  test('normalises the number and schedules a resend', () async {
    expect(await flow().requestCode('  99999-99999 '), isTrue);
    expect(state().phone, '919999999999');
    expect(state().displayPhone, '+91 99999 99999');
    expect(state().codeSent, isTrue);
    expect(state().resendAt!.isAfter(DateTime.now()), isTrue);
  });

  test('a wrong code reports attempts left and bumps the clear signal', () async {
    await flow().requestCode(testUser.phone!);
    expect(await flow().verify('000000'), isFalse);
    expect(state().error, "That code isn't right");
    expect(state().attemptsLeft, 4);
    expect(state().failures, 1);
    expect(tokens.token, isNull);
  });

  test('the right code stores the token and signs in', () async {
    await container.read(authControllerProvider.future);
    await flow().requestCode(testUser.phone!);

    expect(await flow().verify('123456'), isTrue);
    expect(tokens.token, '1|token');
    expect(container.read(authControllerProvider).value, testUser);
    expect(state().codeSent, isFalse, reason: 'flow resets after sign in');
  });

  test('sign out clears the token', () async {
    await container.read(authControllerProvider.future);
    await flow().requestCode(testUser.phone!);
    await flow().verify('123456');

    await container.read(authControllerProvider.notifier).signOut();
    expect(tokens.token, isNull);
    expect(container.read(authControllerProvider).value, isNull);
  });
}
