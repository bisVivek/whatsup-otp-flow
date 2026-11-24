import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../ui/progress_bar.dart';
import '../../../../ui/status_dot.dart';
import '../../domain/dashboard.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// The one rich moment on Home: launch progress, stuck where it always is.
class EtaCard extends StatelessWidget {
  const EtaCard({super.key, required this.progress});

  final LaunchProgress progress;

  @override
  Widget build(BuildContext context) {
    final primary = context.c(AppColors.textPrimary);
    final secondary = context.c(AppColors.textSecondary);
    final muted = context.c(AppColors.textMuted);
    final since = progress.stuckSince;

    return Container(
      padding: const EdgeInsets.all(AppSpace.x5),
      decoration: BoxDecoration(
        color: context.c(AppColors.card),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.c(AppColors.hairline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusLabel(label: progress.status),
              const Spacer(),
              Text(
                'Since ${_months[since.month - 1]} ${since.day}',
                style: AppText.footnote.copyWith(color: muted),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.x6),
          _CountUp(
            to: progress.percent,
            builder: (value) => Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('$value', style: AppText.heroFigure.copyWith(color: primary)),
                const SizedBox(width: AppSpace.x1),
                Text('%', style: AppText.title.copyWith(color: secondary)),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.x2),
          Text(progress.caption, style: AppText.callout.copyWith(color: secondary)),
          const SizedBox(height: AppSpace.x5),
          ProgressBar(value: progress.percent / 100),
          const SizedBox(height: AppSpace.x2),
          Row(
            children: [
              Text('Started', style: AppText.footnote.copyWith(color: muted)),
              const Spacer(),
              Text('Launch', style: AppText.footnote.copyWith(color: muted)),
            ],
          ),
          const SizedBox(height: AppSpace.x4),
          Container(height: 0.5, color: context.c(AppColors.hairline)),
          const SizedBox(height: AppSpace.x4),
          Row(
            children: [
              Text(
                'Days at ${progress.percent}%',
                style: AppText.callout.copyWith(color: secondary),
              ),
              const Spacer(),
              _CountUp(
                to: progress.daysStuck,
                builder: (value) => Text(
                  '$value',
                  style: AppText.bodyStrong.copyWith(
                    color: primary,
                    fontFeatures: AppText.tabular,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tweens an integer up from zero once, when the card first shows.
class _CountUp extends StatelessWidget {
  const _CountUp({required this.to, required this.builder});

  final int to;
  final Widget Function(int value) builder;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: to.toDouble()),
      duration: AppMotion.slow,
      curve: AppMotion.curve,
      builder: (context, v, _) => builder(v.round()),
    );
  }
}
