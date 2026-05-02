import 'package:flutter/widgets.dart';

class ResponsiveUtil {
  // 响应式断点
  static const double xs = 320;
  static const double sm = 640;
  static const double md = 900;
  static const double lg = 1200;
  static const double xl = 1536;

  // 获取屏幕宽度
  static double get screenWidth {
    return WidgetsBinding
            .instance.platformDispatcher.views.first.physicalSize.width /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
  }

  // 获取屏幕高度
  static double get screenHeight {
    return WidgetsBinding
            .instance.platformDispatcher.views.first.physicalSize.height /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
  }

  // 判断是否为超小屏幕
  static bool get isXs {
    return screenWidth < xs;
  }

  // 判断是否为小屏幕
  static bool get isSm {
    return screenWidth >= xs && screenWidth < sm;
  }

  // 判断是否为中等屏幕
  static bool get isMd {
    return screenWidth >= sm && screenWidth < md;
  }

  // 判断是否为大屏幕
  static bool get isLg {
    return screenWidth >= md && screenWidth < lg;
  }

  // 判断是否为超大屏幕
  static bool get isXl {
    return screenWidth >= lg;
  }

  // 根据屏幕宽度计算列数
  static int calculateCrossAxisCount({
    int baseCount = 2,
    int minCount = 1,
    int maxCount = 4,
  }) {
    if (isXl) {
      return maxCount;
    } else if (isLg) {
      return maxCount - 1;
    } else if (isMd) {
      return baseCount + 1;
    } else if (isSm) {
      return baseCount;
    } else {
      return minCount;
    }
  }

  // 计算网格项的主轴长度
  static double calculateMainAxisExtent({
    required int crossAxisCount,
    required double aspectRatio,
    double textHeight = 86,
  }) {
    double itemWidth = screenWidth / crossAxisCount;
    double imageHeight = itemWidth / aspectRatio;
    return imageHeight + textHeight;
  }

  // 获取响应式间距
  static double getSpacing([double baseSpacing = 16]) {
    if (isXl) {
      return baseSpacing * 1.5;
    } else if (isLg) {
      return baseSpacing * 1.25;
    } else if (isMd) {
      return baseSpacing;
    } else {
      return baseSpacing * 0.75;
    }
  }

  // 获取响应式字体大小
  static double getFontSize(double baseSize) {
    if (isXl) {
      return baseSize * 1.2;
    } else if (isLg) {
      return baseSize * 1.1;
    } else if (isMd) {
      return baseSize;
    } else {
      return baseSize * 0.9;
    }
  }
}
