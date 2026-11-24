import 'package:flutter/cupertino.dart';

import '../core/theme/app_theme.dart';

/// Thin progress track. Fills with a transform, not a width animation.
class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.value, this.height = 6});

  /// 0 to 1.
  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(height / 2);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: context.c(AppColors.raised)),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value.clamp(0, 1)),
              duration: AppMotion.slow,
              curve: AppMotion.curve,
              builder: (context, v, _) => Transform(
                alignment: Alignment.centerLeft,
                transform: Matrix4.diagonal3Values(v, 1, 1),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.c(AppColors.accent),
                    borderRadius: radius,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
