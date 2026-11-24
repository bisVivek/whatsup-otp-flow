import 'package:app_login/app.dart';
import 'package:app_login/core/storage/token_storage.dart';
import 'package:app_login/features/auth/data/auth_repository.dart';
import 'package:app_login/features/home/data/dashboard_repository.dart';
import 'package:app_login/features/home/domain/dashboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

class FakeDashboardRepository implements DashboardRepository {
  @override
  Future<Dashboard> fetch() async => Dashboard(
        title: 'Coming soon',
        quip: 'Nothing to see yet. We checked twice',
        progress: LaunchProgress(
          percent: 97,
          status: 'Building',
          caption: 'The last 3% is the hard part',
          stuckSince: DateTime(2026, 3, 14),
          daysStuck: 255,
        ),
        stats: const [
          Stat(label: 'Features shipped', value: '0', note: 'Same as last month'),
          Stat(label: 'Meetings about it', value: '14', note: '+6 vs last week'),
          Stat(label: 'Coffee', value: '38 L', note: 'Steady'),
        ],
        roadmap: const [
          RoadmapItem(title: 'Dark mode', status: 'Shipped', state: RoadmapState.shipped),
        ],
        notifyLaunch: false,
      );

  @override
  Future<bool> setNotifyLaunch(bool value) async => value;
}

void main() {
  testWidgets('WhatsApp number, code, then the coming soon dashboard', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        tokenStorageProvider.overrideWithValue(MemoryTokenStorage()),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        dashboardRepositoryProvider.overrideWithValue(FakeDashboardRepository()),
      ],
      child: const App(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsOneWidget);

    // A bad number stays on the screen with an error.
    await tester.enterText(find.byType(CupertinoTextField), '12345');
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid WhatsApp number'), findsOneWidget);

    await tester.enterText(find.byType(CupertinoTextField), '+91 99999 99999');
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();

    expect(find.text('Check WhatsApp'), findsOneWidget);

    // A wrong code shows the error and how many tries are left.
    await tester.enterText(find.byType(CupertinoTextField), '111111');
    await tester.pumpAndSettle();
    expect(find.textContaining('4 tries left'), findsOneWidget);
    // The cleared field keeps focus so the next try needs no extra tap.
    final otpInput = tester.widget<EditableText>(find.byType(EditableText));
    expect(otpInput.controller.text, isEmpty);
    expect(otpInput.focusNode.hasFocus, isTrue);

    await tester.enterText(find.byType(CupertinoTextField), '123456');
    await tester.pumpAndSettle();

    expect(find.text('Coming soon'), findsWidgets);
    expect(find.text('Days at 97%'), findsOneWidget);
    expect(find.text('Features shipped'), findsOneWidget);
  });
}
