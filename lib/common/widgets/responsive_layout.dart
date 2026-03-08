import 'dart:async';

import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/utils/responsive_util.dart';

/// 响应式布局组件
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final bool centered;

  const ResponsiveLayout({
    Key? key,
    required this.child,
    this.maxWidth = 1200,
    this.centered = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        bool isWideScreen = ResponsiveUtil.isMd;

        if (isWideScreen && centered) {
          double horizontalPadding = (screenWidth - maxWidth) / 2;
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding > 0 ? horizontalPadding : 0,
            ),
            child: child,
          );
        } else {
          return child;
        }
      },
    );
  }
}

/// 响应式网格布局组件
class ResponsiveGridView extends StatefulWidget {
  final List<Widget> children;
  final int baseCount;
  final int minCount;
  final int maxCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double aspectRatio;
  final double maxWidth;
  final bool centered;

  const ResponsiveGridView({
    Key? key,
    required this.children,
    this.baseCount = 2,
    this.minCount = 1,
    this.maxCount = 4,
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 16,
    this.aspectRatio = 16 / 9,
    this.maxWidth = 1200,
    this.centered = true,
  }) : super(key: key);

  @override
  ResponsiveGridViewState createState() => ResponsiveGridViewState();
}

class ResponsiveGridViewState extends State<ResponsiveGridView> {
  late RxInt crossAxisCount;
  late StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    crossAxisCount = ResponsiveUtil.calculateCrossAxisCount(
      baseCount: widget.baseCount,
      minCount: widget.minCount,
      maxCount: widget.maxCount,
    ).obs;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 初始计算列数
    _updateCrossAxisCount();
  }

  @override
  void didUpdateWidget(covariant ResponsiveGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 屏幕尺寸变化时更新列数（使用防抖处理）
    EasyThrottle.throttle(
        'responsiveGridViewUpdate', const Duration(milliseconds: 100), () {
      _updateCrossAxisCount();
    });
  }

  void _updateCrossAxisCount() {
    int count = ResponsiveUtil.calculateCrossAxisCount(
      baseCount: widget.baseCount,
      minCount: widget.minCount,
      maxCount: widget.maxCount,
    );
    if (crossAxisCount.value != count) {
      crossAxisCount.value = count;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      maxWidth: widget.maxWidth,
      centered: widget.centered,
      child: Obx(() {
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount.value,
            mainAxisSpacing: widget.mainAxisSpacing,
            crossAxisSpacing: widget.crossAxisSpacing,
            childAspectRatio: widget.aspectRatio,
          ),
          itemCount: widget.children.length,
          itemBuilder: (context, index) {
            return widget.children[index];
          },
        );
      }),
    );
  }
}

/// 响应式网格项组件
class ResponsiveGridItem extends StatelessWidget {
  final Widget child;
  final int crossAxisCount;
  final double aspectRatio;

  const ResponsiveGridItem({
    Key? key,
    required this.child,
    required this.crossAxisCount,
    this.aspectRatio = 16 / 9,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ResponsiveUtil.screenWidth / crossAxisCount,
      child: child,
    );
  }
}

/// 响应式文本组件
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double baseSize;

  const ResponsiveText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.baseSize = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double fontSize = ResponsiveUtil.getFontSize(baseSize);
    TextStyle responsiveStyle = (style ?? const TextStyle()).copyWith(
      fontSize: fontSize,
    );

    return Text(
      text,
      style: responsiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
