import 'dart:io';

import 'package:flutter/material.dart';

class Dimens {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double defaultSize;
  static late double screenPaddingTop;
  static late Orientation orientation;
  static late double sizeRatio;

  static late double topSafeAreaPadding;
  static late double bottomSafeAreaPadding;
  static late double devicePixelRatio;

  static const double kPadding32 = 32.0;
  static const double kPadding24 = 24.0;
  static const double kPadding16 = 16.0;
  static const double kPadding12 = 12.0;
  static const double kPadding8 = 8.0;
  static const double kPadding4 = 4.0;
  static const Radius kRadius24 = Radius.circular(24);
  static const Radius kRadius16 = Radius.circular(16);
  static const Radius kRadius12 = Radius.circular(12);
  static const Radius kRadius8 = Radius.circular(8);

  static const double screenWidthInDesign = 375.0;
  static const double screenHeightInDesign = 812.0;

  static late double appBarHeight;
  static late double statusBarHeight;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    sizeRatio = screenWidth / screenHeight;
    orientation = _mediaQueryData.orientation;
    devicePixelRatio = _mediaQueryData.devicePixelRatio;

    topSafeAreaPadding = _mediaQueryData.padding.top;
    bottomSafeAreaPadding = _mediaQueryData.padding.bottom;

    if (Platform.isIOS) {
      screenPaddingTop = topSafeAreaPadding;
    } else {
      screenPaddingTop = topSafeAreaPadding + 6;
    }
    statusBarHeight = MediaQuery.of(context).padding.top;
    appBarHeight = statusBarHeight + AppBar().preferredSize.height;
  }

  static bool isIphoneX() {
    if (Platform.isIOS && screenHeight >= 812.0) {
      return true;
    }
    return false;
  }

  // Get the proportionate height as per screen size
  static double getInScreenSize(double inputWidth,
      {double? max, double? min, bool fitHeight = false}) {
    double newSize = (inputWidth / screenWidthInDesign) * screenWidth;
    if (max != null && newSize > max) {
      return max;
    }
    if (min != null && newSize < min) {
      return min;
    }
    if (fitHeight) {
      double designRatio = screenWidthInDesign / screenHeightInDesign;
      double deviceRatio = screenWidth / screenHeight;
      if (deviceRatio <= designRatio) {
        return newSize;
      } else {
        return (inputWidth / screenHeightInDesign) * screenHeight;
      }
    }
    return newSize;
  }
}
