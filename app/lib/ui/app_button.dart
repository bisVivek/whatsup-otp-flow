import 'package:flutter/cupertino.dart';

import '../core/theme/app_theme.dart';

enum AppButtonVariant { primary, secondary, plain, destructive }

/// The one button. Full width by default, 50 tall like iOS.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.expand = true,
  });

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.expand = true,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.plain({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.expand = false,
  }) : variant = AppButtonVariant.plain;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;

    final (Color fill, Color ink) = switch (variant) {
      AppButtonVariant.primary => (
          context.c(AppColors.accent),
          context.c(AppColors.onAccent),
        ),
      AppButtonVariant.secondary => (
          context.c(AppColors.card),
          context.c(AppColors.textPrimary),
        ),
      AppButtonVariant.plain => (
          const Color(0x00000000),
          context.c(AppColors.accent),
        ),
      AppButtonVariant.destructive => (
          context.c(AppColors.card),
          context.c(AppColors.negative),
        ),
    };

    final isPlain = variant == AppButtonVariant.plain;

    final child = AnimatedSwitcher(
      duration: AppMotion.quick,
      child: loading
          ? CupertinoActivityIndicator(
              key: const ValueKey('spinner'),
              color: ink,
            )
          : Text(
              label,
              key: ValueKey(label),
              style: (isPlain ? AppText.callout : AppText.bodyStrong)
                  .copyWith(color: ink),
            ),
    );

    final button = CupertinoButton(
      onPressed: enabled ? onPressed : null,
      color: isPlain ? null : fill,
      disabledColor: isPlain
          ? const Color(0x00000000)
          : fill.withValues(alpha: 0.5),
      minimumSize: Size(isPlain ? 0 : 44, isPlain ? 32 : 50),
      padding: isPlain
          ? const EdgeInsets.symmetric(horizontal: AppSpace.x1)
          : const EdgeInsets.symmetric(horizontal: AppSpace.x5),
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: child,
    );

    final bordered = variant == AppButtonVariant.secondary ||
            variant == AppButtonVariant.destructive
        ? DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.control),
              border: Border.all(color: context.c(AppColors.hairline)),
            ),
            position: DecorationPosition.foreground,
            child: button,
          )
        : button;

    return expand ? SizedBox(width: double.infinity, child: bordered) : bordered;
  }
}
