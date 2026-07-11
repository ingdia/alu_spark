import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double getResponsivePadding(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 600) return 20.0;
    if (width < 1024) return 32.0;
    return 48.0;
  }

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final width = getScreenWidth(context);
    if (width < 600) return baseSize;
    if (width < 1024) return baseSize * 1.1;
    return baseSize * 1.2;
  }

  static int getCrossAxisCount(BuildContext context, {int mobileCount = 2, int tabletCount = 3, int desktopCount = 4}) {
    if (isMobile(context)) return mobileCount;
    if (isTablet(context)) return tabletCount;
    return desktopCount;
  }

  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final width = getScreenWidth(context);
    if (width < 600) return baseSpacing;
    if (width < 1024) return baseSpacing * 1.2;
    return baseSpacing * 1.5;
  }

  static EdgeInsets getResponsiveEdgeInsets(BuildContext context, {double horizontal = 20, double vertical = 20}) {
    final width = getScreenWidth(context);
    double multiplier = 1.0;
    
    if (width >= 600 && width < 1024) {
      multiplier = 1.2;
    } else if (width >= 1024) {
      multiplier = 1.5;
    }
    
    return EdgeInsets.symmetric(
      horizontal: horizontal * multiplier,
      vertical: vertical * multiplier,
    );
  }

  static double getMaxContentWidth(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 600) return width;
    if (width < 1024) return 600.0;
    return 800.0;
  }

  static Widget responsiveContainer(
    BuildContext context, {
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }
}