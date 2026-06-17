import 'package:flutter/widgets.dart';

import '../config/constants.dart';

class ResponsiveUtils {
  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < AppBreakpoints.tablet;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop;
  }

  static double maxContentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1280) {
      return 1180;
    }
    return width - 32;
  }
}
