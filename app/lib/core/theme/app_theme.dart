import 'package:flutter/cupertino.dart';

/// Design tokens. Every size in the app comes from here.
///
/// Graphite neutrals, one amber accent (iOS system orange), system type.
/// Light and dark follow the device setting.
abstract final class AppSpace {
  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x5 = 20;
  static const double x6 = 24;
  static const double x8 = 32;
  static const double x10 = 40;
  static const double x12 = 48;

  /// Horizontal page edge, matches iOS inset grouped lists.
  static const double page = 20;
}

abstract final class AppRadius {
  static const double control = 12;
  static const double card = 16;
  static const double small = 6;
}

abstract final class AppMotion {
  static const Curve curve = Cubic(0.22, 1, 0.36, 1);
  static const Duration quick = Duration(milliseconds: 160);
  static const Duration enter = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 900);
}

abstract final class AppColors {
  static const page = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFF2F2F4),
    darkColor: Color(0xFF0F0F10),
  );
  static const card = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFFFFFF),
    darkColor: Color(0xFF19191B),
  );
  static const raised = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFF4F4F5),
    darkColor: Color(0xFF232325),
  );
  static const textPrimary = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF171717),
    darkColor: Color(0xFFEDEDED),
  );
  static const textSecondary = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF525252),
    darkColor: Color(0xFFA1A1A6),
  );
  static const textMuted = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF737373),
    darkColor: Color(0xFF85858B),
  );

  /// Primary text at 8%.
  static const hairline = CupertinoDynamicColor.withBrightness(
    color: Color(0x14171717),
    darkColor: Color(0x14EDEDED),
  );

  /// The one accent. Darker on light so it reads as ink.
  static const accent = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFC2560A),
    darkColor: Color(0xFFFF9F0A),
  );

  /// Text set on top of an accent fill.
  static const onAccent = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFFFFFF),
    darkColor: Color(0xFF1A1205),
  );

  static const positive = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF16A34A),
    darkColor: Color(0xFF4CC38A),
  );
  static const negative = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFDC2626),
    darkColor: Color(0xFFE5484D),
  );
}

abstract final class AppText {
  static const _tabular = [FontFeature.tabularFigures()];

  static const largeTitle = TextStyle(
    fontSize: 34,
    height: 1.12,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
  );
  static const title = TextStyle(
    fontSize: 22,
    height: 1.2,
    fontWeight: FontWeight.w500,
  );
  static const body = TextStyle(
    fontSize: 17,
    height: 1.3,
    fontWeight: FontWeight.w400,
  );
  static const bodyStrong = TextStyle(
    fontSize: 17,
    height: 1.3,
    fontWeight: FontWeight.w500,
  );
  static const callout = TextStyle(
    fontSize: 15,
    height: 1.35,
    fontWeight: FontWeight.w400,
  );
  static const footnote = TextStyle(
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );
  static const figure = TextStyle(
    fontSize: 28,
    height: 1,
    fontWeight: FontWeight.w500,
    fontFeatures: _tabular,
  );
  static const heroFigure = TextStyle(
    fontSize: 64,
    height: 1,
    fontWeight: FontWeight.w500,
    letterSpacing: -1.6,
    fontFeatures: _tabular,
  );
  static const otpDigit = TextStyle(
    fontSize: 24,
    height: 1,
    fontWeight: FontWeight.w500,
    fontFeatures: _tabular,
  );
  static const tabular = _tabular;
}

CupertinoThemeData buildAppTheme() {
  return const CupertinoThemeData(
    primaryColor: AppColors.accent,
    primaryContrastingColor: AppColors.onAccent,
    scaffoldBackgroundColor: AppColors.page,
    barBackgroundColor: CupertinoDynamicColor.withBrightness(
      color: Color(0xF0F2F2F4),
      darkColor: Color(0xF00F0F10),
    ),
    textTheme: CupertinoTextThemeData(
      primaryColor: AppColors.accent,
    ),
  );
}

extension AppColorX on BuildContext {
  Color c(CupertinoDynamicColor color) => color.resolveFrom(this);
}
