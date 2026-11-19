import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../util/const/ui/ui_constants.dart';

class FullscreenPostLayout {
  const FullscreenPostLayout._();

  static bool isLandscape(BoxConstraints constraints) =>
      constraints.maxWidth > constraints.maxHeight;

  static double actionRailWidth(BoxConstraints constraints) {
    if (!isLandscape(constraints)) {
      return UIConstants.fullscreenEngagementRailWidth;
    }

    return math.min(
      constraints.maxWidth *
          UIConstants.fullscreenLandscapeActionRailWidthFactor,
      UIConstants.fullscreenLandscapeActionRailMaxWidth,
    );
  }
}
