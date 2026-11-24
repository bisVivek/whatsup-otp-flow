import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../ui/brand_mark.dart';

/// Shared frame for the sign in steps: title, subtitle, form, footer.
/// Capped at 440 wide so it stays a phone form on tablets and web.
/// The footer steps aside while the keyboard is up.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
    this.showBrand = true,
  });

  final String title;
  final Widget subtitle;
  final Widget child;
  final Widget? footer;
  final bool showBrand;

  @override
  Widget build(BuildContext context) {
    final keyboardUp = MediaQuery.viewInsetsOf(context).bottom > 0;

    Widget column(List<Widget> children) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.page),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        );

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: column([
                SizedBox(height: showBrand ? AppSpace.x12 : AppSpace.x6),
                if (showBrand) ...[
                  const Align(alignment: Alignment.centerLeft, child: BrandMark()),
                  const SizedBox(height: AppSpace.x10),
                ],
                Text(
                  title,
                  style: AppText.largeTitle.copyWith(
                    color: context.c(AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: AppSpace.x2),
                DefaultTextStyle(
                  style: AppText.callout.copyWith(
                    color: context.c(AppColors.textSecondary),
                  ),
                  child: subtitle,
                ),
                const SizedBox(height: AppSpace.x8),
                child,
                const SizedBox(height: AppSpace.x6),
              ]),
            ),
          ),
          if (footer != null && !keyboardUp)
            column([
              DefaultTextStyle(
                style: AppText.footnote.copyWith(
                  color: context.c(AppColors.textMuted),
                ),
                textAlign: TextAlign.center,
                child: footer!,
              ),
              const SizedBox(height: AppSpace.x6),
            ]),
        ],
      ),
    );
  }
}
