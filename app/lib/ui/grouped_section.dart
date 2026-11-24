import 'package:flutter/cupertino.dart';

import '../core/theme/app_theme.dart';

/// iOS inset grouped list: optional header, rows on one card, optional footer.
class GroupedSection extends StatelessWidget {
  const GroupedSection({
    super.key,
    required this.children,
    this.header,
    this.footer,
  });

  final String? header;
  final String? footer;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final muted = context.c(AppColors.textMuted);
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(Padding(
          // Divider starts where the row text starts.
          padding: const EdgeInsets.only(left: AppSpace.x4 + 28 + AppSpace.x3),
          child: Container(height: 0.5, color: context.c(AppColors.hairline)),
        ));
      }
      rows.add(children[i]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.x4, 0, AppSpace.x4, AppSpace.x2,
            ),
            child: Text(header!, style: AppText.footnote.copyWith(color: muted)),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.c(AppColors.card),
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: context.c(AppColors.hairline)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Column(children: rows),
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.x4, AppSpace.x2, AppSpace.x4, 0,
            ),
            child: Text(footer!, style: AppText.footnote.copyWith(color: muted)),
          ),
      ],
    );
  }
}

/// One 44+ tall row. Icon column is always 28 wide so labels line up.
class GroupedRow extends StatelessWidget {
  const GroupedRow({
    super.key,
    required this.title,
    this.icon,
    this.leading,
    this.trailing,
    this.value,
    this.onTap,
    this.destructive = false,
    this.showChevron = false,
  });

  final String title;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final String? value;
  final VoidCallback? onTap;
  final bool destructive;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final titleColor = destructive
        ? context.c(AppColors.negative)
        : context.c(AppColors.textPrimary);
    final muted = context.c(AppColors.textMuted);

    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.x4,
          vertical: AppSpace.x3,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: leading ??
                  (icon == null
                      ? null
                      : Icon(icon, size: 20, color: destructive ? titleColor : muted)),
            ),
            const SizedBox(width: AppSpace.x3),
            Expanded(
              child: Text(title, style: AppText.body.copyWith(color: titleColor)),
            ),
            if (value != null) ...[
              const SizedBox(width: AppSpace.x3),
              Flexible(
                child: Text(
                  value!,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.callout.copyWith(color: muted),
                ),
              ),
            ],
            if (trailing != null) ...[
              const SizedBox(width: AppSpace.x3),
              trailing!,
            ],
            if (showChevron) ...[
              const SizedBox(width: AppSpace.x2),
              Icon(CupertinoIcons.chevron_forward, size: 16, color: muted),
            ],
          ],
        ),
      ),
    );

    if (onTap == null) return content;
    return _Pressable(onTap: onTap!, child: content);
  }
}

/// Row highlight on press, the iOS way: a surface step, no ripple.
class _Pressable extends StatefulWidget {
  const _Pressable({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: AppMotion.quick,
        color: _down ? context.c(AppColors.raised) : const Color(0x00000000),
        child: widget.child,
      ),
    );
  }
}
