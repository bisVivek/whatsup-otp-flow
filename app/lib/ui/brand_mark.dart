import 'package:flutter/cupertino.dart';

import '../core/theme/app_theme.dart';
import 'status_dot.dart';

/// The wordmark: the product name with its in-progress dot.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Soon',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Soon',
            style: AppText.bodyStrong.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: context.c(AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: AppSpace.x1),
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: StatusDot(size: 6),
          ),
        ],
      ),
    );
  }
}
