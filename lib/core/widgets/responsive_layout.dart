import 'package:flutter/widgets.dart';

enum ScreenSize { mobile, tablet, desktop }

class ResponsiveLayout {
  static const double mobileBreakpoint = 650;
  static const double desktopBreakpoint = 1100;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= mobileBreakpoint &&
      MediaQuery.sizeOf(context).width < desktopBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktopBreakpoint;

  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= desktopBreakpoint) return ScreenSize.desktop;
    if (width >= mobileBreakpoint) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }
}
