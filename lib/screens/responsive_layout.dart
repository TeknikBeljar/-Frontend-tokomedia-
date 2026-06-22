import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/constants.dart';
import 'mobile/home_mobile.dart';
import 'web/home_web.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      return const HomeMobile();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppBreakpoints.desktop) {
          return const HomeWeb();
        }
        return const HomeMobile();
      },
    );
  }
}
