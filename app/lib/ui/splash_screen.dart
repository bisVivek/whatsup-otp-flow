import 'package:flutter/cupertino.dart';

import 'brand_mark.dart';

/// Shown for the moment it takes to check a stored session.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      child: Center(child: BrandMark()),
    );
  }
}
