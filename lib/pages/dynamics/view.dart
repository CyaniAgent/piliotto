import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/skeleton/dynamic_card.dart';
import 'package:piliotto/common/widgets/no_data.dart';
import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/responsive_util.dart';

import 'controller.dart';
import 'widgets/dynamic_panel.dart';

class DynamicsPage extends StatefulWidget {
  const DynamicsPage({super.key});

  @override
  State<DynamicsPage> createState() => _DynamicsPageState();
}

class _DynamicsPageState extends State<DynamicsPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final DynamicsController _dynamicsController = Get.put(DynamicsController());
  late TabController _tabController;
  int _previousTabIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _dynamicsController.queryFollowDynamic();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTapTab(int index) {
    feedBack();
    if (index == _previousTabIndex) {
      _dynamicsController.scrollToTop();
    }
    _previousTabIndex = index;
    _tabController.animateTo(index);
    final tabs = ['latest', 'popular'];
    _dynamicsController.onTabChanged(tabs[index]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isWideScreen = ResponsiveUtil.isLg || ResponsiveUtil.isXl;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: top + 6),
          _buildHeader(theme, colorScheme, isWideScreen),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: Align(
              alignment: Alignment.center,
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '最新'),
                  Tab(text: '热门'),
                ],
                isScrollable: true,
                dividerColor: Colors.transparent,
                enableFeedback: true,
                splashBorderRadius: BorderRadius.circular(10),
                tabAlignment: TabAlignment.center,
                onTap: _onTapTab,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _TabPage(
                  tab: 'latest',
                  dynamicsController: _dynamicsController,
                ),
                _TabPage(
                  tab: 'popular',
                  dynamicsController: _dynamicsController,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      ThemeData theme, ColorScheme colorScheme, bool isWideScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Text(
            '动态',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (isWideScreen)
            Obx(() => IconButton(
                  onPressed: () => _dynamicsController.toggleWideScreenLayout(),
                  onLongPress: () => _showWaterfallConfigDialog(context),
                  icon: Icon(
                    _dynamicsController.wideScreenLayout.value == 'center'
                        ? Icons.view_column_outlined
                        : Icons.view_agenda_outlined,
                    color: colorScheme.onSurface,
                  ),
                  tooltip:
                      _dynamicsController.wideScreenLayout.value == 'center'
                          ? '切换为瀑布流布局'
                          : '切换为居中布局',
                )),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.edit_outlined,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _showWaterfallConfigDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    _dynamicsController.updateWaterfallCache(screenWidth);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('瀑布流设置'),
        content: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Obx(() {
            _dynamicsController.updateWaterfallCache(screenWidth);
            final autoCrossAxisCount =
                _dynamicsController.cachedAutoCrossAxisCount;
            final autoItemWidth =
                _dynamicsController.getAutoItemWidth(screenWidth, 12.0);
            final limitWidth = _dynamicsController.waterfallLimitWidth.value;
            final useCustomWidth =
                _dynamicsController.waterfallUseCustomItemWidth.value;
            final customWidth =
                _dynamicsController.waterfallCustomItemWidth.value;
            final crossAxisCount =
                _dynamicsController.waterfallCrossAxisCount.value;

            final columnItems = List.generate(
              autoCrossAxisCount - 1,
              (index) => DropdownMenuItem(
                value: index + 2,
                child: Text('${index + 2} 列'),
              ),
            );

            final effectiveCrossAxisCount =
                crossAxisCount.clamp(2, autoCrossAxisCount);

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: const Text('限制宽度'),
                  subtitle: const Text('启用后可自定义列数'),
                  value: limitWidth,
                  onChanged: _dynamicsController.toggleWaterfallLimitWidth,
                ),
                SwitchListTile(
                  title: const Text('自定义卡片宽度'),
                  subtitle: Text(useCustomWidth
                      ? '当前: ${customWidth.toStringAsFixed(0)}px'
                      : '自动计算: ${autoItemWidth.toStringAsFixed(0)}px'),
                  value: useCustomWidth,
                  onChanged:
                      _dynamicsController.toggleWaterfallUseCustomItemWidth,
                ),
                if (useCustomWidth) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('卡片宽度: '),
                      Expanded(
                        child: Slider(
                          value: customWidth,
                          min: 200,
                          max: 600,
                          divisions: 40,
                          label: '${customWidth.toStringAsFixed(0)}px',
                          onChanged:
                              _dynamicsController.setWaterfallCustomItemWidth,
                        ),
                      ),
                    ],
                  ),
                ],
                const Divider(),
                Text(
                  '当前屏幕自动计算列数: $autoCrossAxisCount',
                  style: TextStyle(
                    color: colorScheme.outline,
                    fontSize: 12,
                  ),
                ),
                if (limitWidth) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('瀑布流列数: '),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        value: effectiveCrossAxisCount,
                        items: columnItems,
                        onChanged: (value) {
                          if (value != null) {
                            _dynamicsController
                                .setWaterfallCrossAxisCount(value);
                          }
                        },
                        underline: const SizedBox(),
                      ),
                    ],
                  ),
                ],
              ],
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

class _TabPage extends StatefulWidget {
  final String tab;
  final DynamicsController dynamicsController;

  const _TabPage({
    required this.tab,
    required this.dynamicsController,
  });

  @override
  State<_TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<_TabPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isWideScreen = ResponsiveUtil.isLg || ResponsiveUtil.isXl;
    final screenWidth = MediaQuery.of(context).size.width;

    return Obx(() {
      final currentTab = widget.dynamicsController.currentTab.value;
      final isCurrentTab = currentTab == widget.tab;

      final cachedList = widget.dynamicsController.getTabData(widget.tab);
      final hasLoaded = widget.dynamicsController.hasTabLoaded(widget.tab);
      final wideScreenLayout = widget.dynamicsController.wideScreenLayout.value;

      if (cachedList.isEmpty && !hasLoaded) {
        if (widget.dynamicsController.tabLoadingStates[widget.tab]!.value &&
            isCurrentTab) {
          return _buildSkeletonList(
              isWideScreen, screenWidth, wideScreenLayout);
        } else {
          return NoData(
            onRefresh: () => widget.dynamicsController.onRefresh(),
          );
        }
      }

      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification &&
              notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 200) {
            EasyThrottle.throttle(
                'queryFollowDynamic_${widget.tab}', const Duration(seconds: 1),
                () {
              widget.dynamicsController.queryFollowDynamic(type: 'onLoad');
            });
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: () => widget.dynamicsController.onRefresh(),
          child: _buildContentList(
            cachedList,
            colorScheme,
            isWideScreen,
            screenWidth,
            wideScreenLayout,
          ),
        ),
      );
    });
  }

  Widget _buildContentList(
    List<dynamic> cachedList,
    ColorScheme colorScheme,
    bool isWideScreen,
    double screenWidth,
    String wideScreenLayout,
  ) {
    if (isWideScreen && wideScreenLayout == 'waterfall') {
      return _buildWaterfallList(cachedList, colorScheme, screenWidth);
    }

    return _buildCenteredList(
        cachedList, colorScheme, isWideScreen, screenWidth);
  }

  Widget _buildCenteredList(
    List<dynamic> cachedList,
    ColorScheme colorScheme,
    bool isWideScreen,
    double screenWidth,
  ) {
    const contentMaxWidth = 600.0;
    final scrollController =
        widget.dynamicsController.tabScrollControllers[widget.tab];

    return ListView.builder(
      controller: scrollController,
      padding:
          _buildCenteredListPadding(isWideScreen, screenWidth, contentMaxWidth),
      itemCount: cachedList.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildNewDynamicsBanner(
              colorScheme, isWideScreen, contentMaxWidth);
        }
        if (index == cachedList.length) {
          return _buildLoadingIndicator(colorScheme);
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          width: isWideScreen ? contentMaxWidth : null,
          child: DynamicPanel(
            item: cachedList[index - 1],
            onTap: () =>
                widget.dynamicsController.pushDetail(cachedList[index - 1], 1),
            onCommentTap: () => widget.dynamicsController
                .pushDetail(cachedList[index - 1], 1, action: 'comment'),
          ),
        );
      },
    );
  }

  Widget _buildNewDynamicsBanner(
      ColorScheme colorScheme, bool isWideScreen, double contentMaxWidth) {
    return Obx(() {
      final count = widget.dynamicsController.newDynamicsCount.value;
      if (count == 0 || widget.tab != 'latest') {
        return const SizedBox.shrink();
      }

      return Container(
        width: isWideScreen ? contentMaxWidth : null,
        margin: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => widget.dynamicsController.loadNewDynamics(),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_upward_rounded,
                    size: 18,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$count 条新动态',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildWaterfallList(
    List<dynamic> cachedList,
    ColorScheme colorScheme,
    double screenWidth,
  ) {
    const crossAxisSpacing = 12.0;
    widget.dynamicsController.updateWaterfallCache(screenWidth);

    final effectiveCrossAxisCount =
        widget.dynamicsController.cachedEffectiveCrossAxisCount;
    final itemWidth = widget.dynamicsController.cachedItemWidth;
    final limitWidth = widget.dynamicsController.waterfallLimitWidth.value;

    final scrollController =
        widget.dynamicsController.tabScrollControllers[widget.tab];

    final gridContent = SliverMasonryGrid.count(
      crossAxisCount: effectiveCrossAxisCount,
      mainAxisSpacing: 12,
      crossAxisSpacing: crossAxisSpacing,
      childCount: cachedList.length + 1,
      itemBuilder: (context, index) {
        if (index == cachedList.length) {
          return _buildLoadingIndicator(colorScheme);
        }
        return DynamicPanel(
          item: cachedList[index],
          onTap: () =>
              widget.dynamicsController.pushDetail(cachedList[index], 1),
          onCommentTap: () => widget.dynamicsController
              .pushDetail(cachedList[index], 1, action: 'comment'),
        );
      },
    );

    const maxContentWidth = 1600.0;
    final effectiveScreenWidth =
        screenWidth > maxContentWidth ? maxContentWidth : screenWidth;
    final sidePadding = screenWidth > maxContentWidth
        ? (screenWidth - maxContentWidth) / 2
        : 0.0;

    if (limitWidth) {
      final gridWidth = effectiveCrossAxisCount * itemWidth +
          (effectiveCrossAxisCount - 1) * crossAxisSpacing;
      final horizontalPadding = (effectiveScreenWidth - gridWidth) / 2;

      return CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: _buildWaterfallNewDynamicsBanner(colorScheme),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
                horizontal:
                    horizontalPadding.clamp(12, double.infinity) + sidePadding),
            sliver: gridContent,
          ),
        ],
      );
    }

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: _buildWaterfallNewDynamicsBanner(colorScheme),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 12 + sidePadding),
          sliver: gridContent,
        ),
      ],
    );
  }

  Widget _buildWaterfallNewDynamicsBanner(ColorScheme colorScheme) {
    return Obx(() {
      final count = widget.dynamicsController.newDynamicsCount.value;
      if (count == 0 || widget.tab != 'latest') {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => widget.dynamicsController.loadNewDynamics(),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_upward_rounded,
                    size: 18,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$count 条新动态',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSkeletonList(
      bool isWideScreen, double screenWidth, String wideScreenLayout) {
    if (isWideScreen && wideScreenLayout == 'waterfall') {
      return _buildWaterfallSkeletonList(screenWidth);
    }

    return _buildCenteredSkeletonList(isWideScreen, screenWidth);
  }

  Widget _buildCenteredSkeletonList(bool isWideScreen, double screenWidth) {
    const contentMaxWidth = 600.0;

    return ListView.builder(
      padding:
          _buildCenteredListPadding(isWideScreen, screenWidth, contentMaxWidth),
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: const DynamicCardSkeleton(),
      ),
    );
  }

  Widget _buildWaterfallSkeletonList(double screenWidth) {
    const crossAxisSpacing = 12.0;
    widget.dynamicsController.updateWaterfallCache(screenWidth);

    final effectiveCrossAxisCount =
        widget.dynamicsController.cachedEffectiveCrossAxisCount;
    final itemWidth = widget.dynamicsController.cachedItemWidth;
    final limitWidth = widget.dynamicsController.waterfallLimitWidth.value;

    if (limitWidth) {
      final gridWidth = effectiveCrossAxisCount * itemWidth +
          (effectiveCrossAxisCount - 1) * crossAxisSpacing;
      final horizontalPadding = (screenWidth - gridWidth) / 2;

      return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding.clamp(12, double.infinity)),
        child: WaterfallSkeleton(crossAxisCount: effectiveCrossAxisCount),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: 80,
      ),
      child: WaterfallSkeleton(crossAxisCount: effectiveCrossAxisCount),
    );
  }

  EdgeInsets _buildCenteredListPadding(
      bool isWideScreen, double screenWidth, double maxWidth) {
    if (isWideScreen) {
      final horizontalPadding = (screenWidth - maxWidth) / 2;
      return EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 80,
      );
    }
    return const EdgeInsets.only(
      left: 12,
      right: 12,
      bottom: 80,
    );
  }

  Widget _buildLoadingIndicator(ColorScheme colorScheme) {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: widget.dynamicsController.tabLoadingStates[widget.tab]!.value
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '加载中...',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  )
                : Text(
                    widget.dynamicsController.hasMore.value ? '' : '没有更多了',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.outline,
                    ),
                  ),
          ),
        ));
  }
}
