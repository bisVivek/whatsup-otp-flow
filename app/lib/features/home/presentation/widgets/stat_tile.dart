import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/dashboard.dart';

/// Label, figure, and what the figure compares to. Nothing else.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.stat});

  final Stat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.x4),
      decoration: BoxDecoration(
        color: context.c(AppColors.card),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: context.c(AppColors.hairline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stat.label,
            maxLines: 2,
            style: AppText.footnote.copyWith(color: context.c(AppColors.textSecondary)),
          ),
          const Spacer(),
          const SizedBox(height: AppSpace.x3),
          Text(
            stat.value,
            style: AppText.figure.copyWith(color: context.c(AppColors.textPrimary)),
          ),
          const SizedBox(height: AppSpace.x1),
          Text(
            stat.note,
            maxLines: 2,
            style: AppText.footnote.copyWith(color: context.c(AppColors.textMuted)),
          ),
        ],
      ),
    );
  }
}

/// Stats as equal tiles on wide screens, a compact table on phones,
/// where three tiles would be too narrow to read.
class StatRow extends StatelessWidget {
  const StatRow({super.key, required this.stats});

  final List<Stat> stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 520) {
          return SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < stats.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpace.x3),
                  Expanded(child: StatTile(stat: stats[i])),
                ],
              ],
            ),
          );
        }
        return _StatTable(stats: stats);
      },
    );
  }
}

class _StatTable extends StatelessWidget {
  const _StatTable({required this.stats});

  final List<Stat> stats;

  @override
  Widget build(BuildContext context) {
    final hairline = context.c(AppColors.hairline);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.c(AppColors.card),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: hairline),
      ),
      child: Column(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.only(left: AppSpace.x4),
                child: Container(height: 0.5, color: hairline),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.x5,
                vertical: AppSpace.x3,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stats[i].label,
                          style: AppText.body.copyWith(
                            color: context.c(AppColors.textPrimary),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          stats[i].note,
                          style: AppText.footnote.copyWith(
                            color: context.c(AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpace.x3),
                  Text(
                    stats[i].value,
                    style: AppText.title.copyWith(
                      color: context.c(AppColors.textPrimary),
                      fontFeatures: AppText.tabular,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
