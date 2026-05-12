import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class LimitedWaterfall<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final int maxCrossAxisCount;
  final double maxItemWidth;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final Widget? header;
  final Widget? footer;
  final bool centerContent;
  final double? maxWidth;

  const LimitedWaterfall({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.maxCrossAxisCount = 3,
    this.maxItemWidth = 400,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 12,
    this.padding,
    this.controller,
    this.header,
    this.footer,
    this.centerContent = true,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveMaxWidth = maxWidth ?? screenWidth;
    final effectivePadding = padding ?? EdgeInsets.zero;

    final availableWidth = effectiveMaxWidth - effectivePadding.horizontal;
    final crossAxisCount = _calculateCrossAxisCount(availableWidth);

    final gridWidth = crossAxisCount * maxItemWidth + (crossAxisCount - 1) * crossAxisSpacing;
    final shouldCenter = centerContent && gridWidth < effectiveMaxWidth;

    final slivers = <Widget>[
      if (header != null) SliverToBoxAdapter(child: header),
      SliverMasonryGrid.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childCount: items.length + (footer != null ? 1 : 0),
        itemBuilder: (context, index) {
          if (footer != null && index == items.length) {
            return footer;
          }
          return itemBuilder(context, items[index], index);
        },
      ),
    ];

    if (shouldCenter) {
      return CustomScrollView(
        controller: controller,
        slivers: [
          SliverPadding(
            padding: effectivePadding,
            sliver: SliverCenter(
              maxWidth: gridWidth,
              sliver: SliverMainAxisGroup(
                slivers: slivers,
              ),
            ),
          ),
        ],
      );
    }

    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverPadding(
          padding: effectivePadding,
          sliver: SliverMainAxisGroup(
            slivers: slivers,
          ),
        ),
      ],
    );
  }

  int _calculateCrossAxisCount(double availableWidth) {
    final countByWidth = (availableWidth / maxItemWidth).floor();
    final count = countByWidth.clamp(1, maxCrossAxisCount);
    return count;
  }
}

class SliverCenter extends StatelessWidget {
  final double maxWidth;
  final Widget sliver;

  const SliverCenter({
    super.key,
    required this.maxWidth,
    required this.sliver,
  });

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.crossAxisExtent;
        if (screenWidth <= maxWidth) {
          return sliver;
        }

        final horizontalPadding = (screenWidth - maxWidth) / 2;
        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: sliver,
        );
      },
    );
  }
}

class LimitedWaterfallGrid<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final int crossAxisCount;
  final double maxItemWidth;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final Widget? header;
  final Widget? footer;
  final bool centerContent;

  const LimitedWaterfallGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.maxItemWidth = 400,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 12,
    this.padding,
    this.controller,
    this.header,
    this.footer,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final effectivePadding = padding ?? EdgeInsets.zero;

    final availableWidth = screenWidth - effectivePadding.horizontal;
    final effectiveCrossAxisCount = _calculateEffectiveCrossAxisCount(availableWidth);

    final gridWidth = effectiveCrossAxisCount * maxItemWidth + (effectiveCrossAxisCount - 1) * crossAxisSpacing;
    final shouldCenter = centerContent && gridWidth < availableWidth;

    final slivers = <Widget>[
      if (header != null) SliverToBoxAdapter(child: header),
      SliverMasonryGrid.count(
        crossAxisCount: effectiveCrossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childCount: items.length + (footer != null ? 1 : 0),
        itemBuilder: (context, index) {
          if (footer != null && index == items.length) {
            return footer;
          }
          return itemBuilder(context, items[index], index);
        },
      ),
    ];

    if (shouldCenter) {
      return CustomScrollView(
        controller: controller,
        slivers: [
          SliverPadding(
            padding: effectivePadding,
            sliver: SliverCenter(
              maxWidth: gridWidth,
              sliver: SliverMainAxisGroup(
                slivers: slivers,
              ),
            ),
          ),
        ],
      );
    }

    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverPadding(
          padding: effectivePadding,
          sliver: SliverMainAxisGroup(
            slivers: slivers,
          ),
        ),
      ],
    );
  }

  int _calculateEffectiveCrossAxisCount(double availableWidth) {
    final maxPossibleCount = (availableWidth / maxItemWidth).floor();
    return maxPossibleCount.clamp(1, crossAxisCount);
  }
}
