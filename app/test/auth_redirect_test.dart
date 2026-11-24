import 'package:app_login/core/router/app_router.dart';
import 'package:app_login/core/router/routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

void main() {
  const restoring = AsyncLoading<Object?>();
  const signedOut = AsyncData<Object?>(null);
  const signedIn = AsyncData<Object?>(testUser);

  String? go(AsyncValue<Object?> auth, String at, {bool codeSent = false}) =>
      authRedirect(auth: auth, location: at, codeSent: codeSent);

  test('holds on splash while the stored session is checked', () {
    expect(go(restoring, Routes.home), Routes.splash);
    expect(go(restoring, Routes.splash), isNull);
  });

  test('signed out users land on login', () {
    expect(go(signedOut, Routes.splash), Routes.login);
    expect(go(signedOut, Routes.home), Routes.login);
    expect(go(signedOut, Routes.login), isNull);
  });

  test('verify needs a code to have been sent first', () {
    expect(go(signedOut, Routes.verify), Routes.login);
    expect(go(signedOut, Routes.verify, codeSent: true), isNull);
  });

  test('signed in users skip the auth screens', () {
    expect(go(signedIn, Routes.login), Routes.home);
    expect(go(signedIn, Routes.verify), Routes.home);
    expect(go(signedIn, Routes.splash), Routes.home);
    expect(go(signedIn, Routes.home), isNull);
  });
}
