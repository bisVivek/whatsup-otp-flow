import 'package:flutter/cupertino.dart';

import '../core/theme/app_theme.dart';

/// Error or hint text that sits right under a field.
/// Reserves no space when empty and fades in when it appears.
class InlineMessage extends StatelessWidget {
  const InlineMessage({super.key, required this.message, this.isError = true});

  final String? message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError
        ? context.c(AppColors.negative)
        : context.c(AppColors.textSecondary);

    return AnimatedSize(
      duration: AppMotion.quick,
      curve: AppMotion.curve,
      alignment: Alignment.topLeft,
      child: message == null
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(top: AppSpace.x2, left: AppSpace.x1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Icon(
                      isError
                          ? CupertinoIcons.exclamationmark_circle
                          : CupertinoIcons.info_circle,
                      size: 16,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: AppSpace.x2),
                  Expanded(
                    child: Text(
                      message!,
                      style: AppText.footnote.copyWith(color: color),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
