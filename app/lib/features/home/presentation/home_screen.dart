import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../ui/app_button.dart';
import '../../../ui/grouped_section.dart';
import '../../../ui/status_dot.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/user.dart';
import '../application/dashboard_controller.dart';
import '../domain/dashboard.dart';
import 'widgets/eta_card.dart';
import 'widgets/stat_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final dashboard = ref.watch(dashboardControllerProvider);
    final title = dashboard.value?.title ?? 'Home';

    return CupertinoPageScaffold(
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(title),
            border: null,
            trailing: user == null
                ? null
                : _AvatarButton(user: user, onTap: () => _confirmSignOut(context, ref)),
          ),
          CupertinoSliverRefreshControl(
            onRefresh: ref.read(dashboardControllerProvider.notifier).refresh,
          ),
          switch (dashboard) {
            AsyncData(:final value) => _Content(dashboard: value, user: user),
            AsyncError(:final error) => SliverFillRemaining(
                hasScrollBody: false,
                child: _ErrorState(
                  message: error is ApiException
                      ? error.message
                      : 'Something went wrong',
                  onRetry: () => ref.invalidate(dashboardControllerProvider),
                ),
              ),
            _ => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CupertinoActivityIndicator()),
              ),
          },
        ],
      ),
    );
  }
}

Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
  final user = ref.read(authControllerProvider).value;
  final confirmed = await showCupertinoModalPopup<bool>(
    context: context,
    builder: (context) => CupertinoActionSheet(
      title: user == null ? null : Text(user.name),
      message: user == null ? null : Text(user.contact),
      actions: [
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Sign out'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Cancel'),
      ),
    ),
  );
  if (confirmed == true) {
    await ref.read(authControllerProvider.notifier).signOut();
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.dashboard, required this.user});

  final Dashboard dashboard;
  final User? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final secondary = context.c(AppColors.textSecondary);

    return SliverSafeArea(
      top: false,
      sliver: SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.x4, 0, AppSpace.x4, AppSpace.x8,
        ),
        sliver: SliverList.list(
          children: [
            _Entrance(
              child: Text(
                dashboard.quip,
                style: AppText.callout.copyWith(color: secondary),
              ),
            ),
            const SizedBox(height: AppSpace.x5),
            _Entrance(delay: 1, child: EtaCard(progress: dashboard.progress)),
            const SizedBox(height: AppSpace.x3),
            _Entrance(delay: 2, child: StatRow(stats: dashboard.stats)),
            const SizedBox(height: AppSpace.x8),
            _Entrance(
              delay: 3,
              child: GroupedSection(
                header: 'On the roadmap',
                children: [
                  for (final item in dashboard.roadmap)
                    GroupedRow(
                      title: item.title,
                      value: item.status,
                      leading: Center(
                        child: StatusDot(
                          tone: switch (item.state) {
                            RoadmapState.shipped => StatusTone.done,
                            RoadmapState.building => StatusTone.progress,
                            RoadmapState.planned => StatusTone.idle,
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.x8),
            GroupedSection(
              header: 'Launch',
              footer: "We'll email you once. Twice if we forget we already did",
              children: [
                GroupedRow(
                  title: 'Tell me when it ships',
                  icon: CupertinoIcons.bell,
                  trailing: CupertinoSwitch(
                    value: dashboard.notifyLaunch,
                    activeTrackColor: context.c(AppColors.accent),
                    onChanged: (_) => _toggleNotify(context, ref),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.x8),
            if (user != null)
              GroupedSection(
                header: 'Account',
                children: [
                  GroupedRow(
                    title: user!.name,
                    value: user!.contact,
                    icon: CupertinoIcons.person,
                  ),
                  GroupedRow(
                    title: 'Sign out',
                    icon: CupertinoIcons.square_arrow_right,
                    destructive: true,
                    onTap: () => _confirmSignOut(context, ref),
                  ),
                ],
              ),
            const SizedBox(height: AppSpace.x8),
            Center(
              child: Text(
                'Version 0.0.1 · pull down for a fresh excuse',
                style: AppText.footnote.copyWith(
                  color: context.c(AppColors.textMuted),
                  fontFeatures: AppText.tabular,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleNotify(BuildContext context, WidgetRef ref) async {
    final error = await ref.read(dashboardControllerProvider.notifier).toggleNotify();
    if (error == null || !context.mounted) return;
    await showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Couldn't save that"),
        content: Text(error),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({required this.user, required this.onTap});

  final User user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Account',
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size(44, 44),
        onPressed: onTap,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.c(AppColors.raised),
            shape: BoxShape.circle,
            border: Border.all(color: context.c(AppColors.hairline)),
          ),
          child: Text(
            user.initials,
            style: AppText.footnote.copyWith(
              fontWeight: FontWeight.w500,
              color: context.c(AppColors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpace.page),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.wifi_exclamationmark,
            size: 28,
            color: context.c(AppColors.textMuted),
          ),
          const SizedBox(height: AppSpace.x3),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppText.callout.copyWith(color: context.c(AppColors.textSecondary)),
          ),
          const SizedBox(height: AppSpace.x4),
          AppButton.secondary(label: 'Try again', onPressed: onRetry, expand: false),
        ],
      ),
    );
  }
}

/// One short fade and rise on first load, staggered by [delay] steps of 50ms.
class _Entrance extends StatelessWidget {
  const _Entrance({required this.child, this.delay = 0});

  final Widget child;
  final int delay;

  @override
  Widget build(BuildContext context) {
    final total = AppMotion.enter + Duration(milliseconds: 50 * delay);
    final start = (50 * delay) / total.inMilliseconds;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: AppMotion.curve),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 8 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}
