import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/constants.dart';
import 'login_screen.dart';
import 'mobile/home_mobile.dart';
import 'web/home_web.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      return MobileAuthSession.isAuthenticated
          ? const HomeMobile()
          : const RegisterScreen();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppBreakpoints.desktop) {
          return const HomeWeb();
        }
        return MobileAuthSession.isAuthenticated
            ? const HomeMobile()
            : const RegisterScreen();
      },
    );
  }
}
