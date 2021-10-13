import 'dart:ui';

import 'package:flutter/material.dart';

class Adapt {
  static MediaQueryData mediaQuery = MediaQueryData.fromWindow(window);
  static Size _screenSize = mediaQuery.size;
  static double _width = _screenSize.width;
  static double _height = _screenSize.height;
  static double _topBarH = mediaQuery.padding.top;
  static double _botBarH = mediaQuery.padding.bottom;
  static double _pixelRatio = mediaQuery.devicePixelRatio;
  static double _smallestWidth = _width > _height ? _height : _width;
  static bool _isLargeScreen = _smallestWidth > 820;
  static bool _isMediumScreen = _smallestWidth > 600 && _smallestWidth <= 820;
  static bool _isLandscape = mediaQuery.orientation == Orientation.landscape;
  static var _ratio;

  double? wp(percentage) {
    double? result = (percentage * _screenSize.width) / 100;
    return result;
  }

  double? hp(percentage) {
    double? result = (percentage * _screenSize.height) / 100;
    return result;
  }

  static init(int number) {
    int uiWidth = number is int ? number : 375;
    _ratio = _width / uiWidth;
  }

  static px(number) {
    if (!(_ratio is double || _ratio is int)) {
      Adapt.init(375);
    }
    return number * _ratio;
  }

  static onepx() {
    return 1 / _pixelRatio;
  }

  static screenW() {
    return _width;
  }

  static screenH() {
    return _height;
  }

  static padTopH() {
    return _topBarH;
  }

  static padBotH() {
    return _botBarH;
  }

  static isLargeScreen() => _isLargeScreen;

  static isMediumScreen() => _isMediumScreen;

  static isSmallScreen() => !_isLargeScreen && !_isMediumScreen;

  static double roundToNearestNumber(double number) {
    try {
      double result = double.parse(number.toString());
      result = result.roundToDouble();
      if (result == 0) result = 1;
      return result;
    } catch (e) {
      return 5;
    }
  }

  static bool isLandscape() => _isLandscape;
}
