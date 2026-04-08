/// Responsive design utilities
library responsive;

import 'package:flutter/material.dart';

/// Breakpoints for responsive design
class BreakPoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double wide = 1440;
}

/// Extension on BuildContext for responsive queries
extension ResponsiveContext on BuildContext {
  /// Get device size
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Get device width
  double get screenWidth => screenSize.width;

  /// Get device height
  double get screenHeight => screenSize.height;

  /// Check if device is mobile
  bool get isMobile => screenWidth < BreakPoints.tablet;

  /// Check if device is tablet
  bool get isTablet =>
      screenWidth >= BreakPoints.tablet && screenWidth < BreakPoints.desktop;

  /// Check if device is desktop
  bool get isDesktop => screenWidth >= BreakPoints.desktop;

  /// Get responsive padding
  EdgeInsets get responsivePadding {
    if (isMobile) return const EdgeInsets.all(12);
    if (isTablet) return const EdgeInsets.all(16);
    return const EdgeInsets.all(24);
  }

  /// Get responsive column count for grid
  int get gridColumns {
    if (isMobile) return 1;
    if (isTablet) return 2;
    return 3;
  }

  /// Get safe area insets
  EdgeInsets get safeAreaInsets => MediaQuery.paddingOf(this);

  /// Get viewInsets (keyboard height, etc)
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  /// Check if keyboard is visible
  bool get isKeyboardVisible => viewInsets.bottom > 0;

  /// Get text scale factor
  double get textScaleFactor => MediaQuery.textScaleFactorOf(this);

  /// Get device pixel ratio
  double get devicePixelRatio => MediaQuery.devicePixelRatioOf(this);

  /// Check if device is in landscape
  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;

  /// Check if device is in portrait
  bool get isPortrait =>
      MediaQuery.orientationOf(this) == Orientation.portrait;
}
