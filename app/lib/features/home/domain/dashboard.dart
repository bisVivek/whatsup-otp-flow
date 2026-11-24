/// Everything Home shows. All copy comes from the server so it can change
/// without a release, which is fitting, since nothing else does.
class Dashboard {
  const Dashboard({
    required this.title,
    required this.quip,
    required this.progress,
    required this.stats,
    required this.roadmap,
    required this.notifyLaunch,
  });

  final String title;
  final String quip;
  final LaunchProgress progress;
  final List<Stat> stats;
  final List<RoadmapItem> roadmap;
  final bool notifyLaunch;

  Dashboard copyWith({bool? notifyLaunch}) => Dashboard(
        title: title,
        quip: quip,
        progress: progress,
        stats: stats,
        roadmap: roadmap,
        notifyLaunch: notifyLaunch ?? this.notifyLaunch,
      );

  factory Dashboard.fromJson(Map<String, dynamic> json) => Dashboard(
        title: json['title'] as String,
        quip: json['quip'] as String,
        progress: LaunchProgress.fromJson(json['progress'] as Map<String, dynamic>),
        stats: (json['stats'] as List)
            .map((e) => Stat.fromJson(e as Map<String, dynamic>))
            .toList(),
        roadmap: (json['roadmap'] as List)
            .map((e) => RoadmapItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        notifyLaunch: json['notify_launch'] as bool? ?? false,
      );
}

class LaunchProgress {
  const LaunchProgress({
    required this.percent,
    required this.status,
    required this.caption,
    required this.stuckSince,
    required this.daysStuck,
  });

  final int percent;
  final String status;
  final String caption;
  final DateTime stuckSince;
  final int daysStuck;

  factory LaunchProgress.fromJson(Map<String, dynamic> json) => LaunchProgress(
        percent: (json['percent'] as num).toInt(),
        status: json['status'] as String,
        caption: json['caption'] as String,
        stuckSince: DateTime.parse(json['stuck_since'] as String),
        daysStuck: (json['days_stuck'] as num).toInt(),
      );
}

class Stat {
  const Stat({required this.label, required this.value, required this.note});

  final String label;
  final String value;
  final String note;

  factory Stat.fromJson(Map<String, dynamic> json) => Stat(
        label: json['label'] as String,
        value: json['value'] as String,
        note: json['note'] as String,
      );
}

enum RoadmapState { shipped, building, planned }

class RoadmapItem {
  const RoadmapItem({
    required this.title,
    required this.status,
    required this.state,
  });

  final String title;
  final String status;
  final RoadmapState state;

  factory RoadmapItem.fromJson(Map<String, dynamic> json) => RoadmapItem(
        title: json['title'] as String,
        status: json['status'] as String,
        state: RoadmapState.values.firstWhere(
          (s) => s.name == json['state'],
          orElse: () => RoadmapState.planned,
        ),
      );
}
