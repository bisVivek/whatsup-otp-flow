import 'package:flutter/cupertino.dart';

import '../core/theme/app_theme.dart';

enum StatusTone { progress, done, idle }

/// The app's one signature detail: a small dot that marks state.
/// Amber means in progress, which in this app means forever.
class StatusDot extends StatelessWidget {
  const StatusDot({super.key, this.tone = StatusTone.progress, this.size = 8});

  final StatusTone tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      StatusTone.progress => context.c(AppColors.accent),
      StatusTone.done => context.c(AppColors.positive),
      StatusTone.idle => context.c(AppColors.textMuted),
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// A dot followed by a short label, e.g. "In progress".
class StatusLabel extends StatelessWidget {
  const StatusLabel({super.key, required this.label, this.tone = StatusTone.progress});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StatusDot(tone: tone),
        const SizedBox(width: AppSpace.x2),
        Text(
          label,
          style: AppText.footnote.copyWith(color: context.c(AppColors.textSecondary)),
        ),
      ],
    );
  }
}
