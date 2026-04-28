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
    _dynamicsController.updateCrossAxisCount();
    EasyThrottle.throttle(
        'dynamicsPageDidChange', const Duration(milliseconds: 100), () {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTapTab(int index) {
    feedBack();
    final tabs = ['latest', 'popular'];
    _tabController.animateTo(index);
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
  late ScrollController _centeredScrollController;
  late ScrollController _waterfallScrollController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _centeredScrollController = ScrollController();
    _waterfallScrollController = ScrollController();
  }

  @override
  void dispose() {
    _centeredScrollController.dispose();
    _waterfallScrollController.dispose();
    super.dispose();
  }

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
        if (widget.dynamicsController.isLoadingDynamic.value && isCurrentTab) {
          return _buildSkeletonList(
              isWideScreen, screenWidth, wideScreenLayout);
        } else {
          return const NoData();
        }
      }

      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification &&
              notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 200) {
            EasyThrottle.throttle(
                'queryFollowDynamic_${widget.tab}', const Duration(seconds: 1), () {
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

    return ListView.builder(
      controller: _centeredScrollController,
      padding:
          _buildCenteredListPadding(isWideScreen, screenWidth, contentMaxWidth),
      itemCount: cachedList.length + 1,
      itemBuilder: (context, index) {
        if (index == cachedList.length) {
          return _buildLoadingIndicator(colorScheme);
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          width: isWideScreen ? contentMaxWidth : null,
          child: DynamicPanel(
            item: cachedList[index],
            onTap: () => widget.dynamicsController.pushDetail(cachedList[index], 1),
            onCommentTap: () => widget.dynamicsController.pushDetail(cachedList[index], 1, action: 'comment'),
          ),
        );
      },
    );
  }

  Widget _buildWaterfallList(
    List<dynamic> cachedList,
    ColorScheme colorScheme,
    double screenWidth,
  ) {
    int crossAxisCount;
    if (screenWidth >= 1200) {
      crossAxisCount = 4;
    } else if (screenWidth >= 900) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    return MasonryGridView.count(
      controller: _waterfallScrollController,
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: 80,
      ),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: cachedList.length + 1,
      itemBuilder: (context, index) {
        if (index == cachedList.length) {
          return _buildLoadingIndicator(colorScheme);
        }
        return DynamicPanel(
          item: cachedList[index],
          onTap: () => widget.dynamicsController.pushDetail(cachedList[index], 1),
          onCommentTap: () => widget.dynamicsController.pushDetail(cachedList[index], 1, action: 'comment'),
        );
      },
    );
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
    int crossAxisCount;
    if (screenWidth >= 1200) {
      crossAxisCount = 4;
    } else if (screenWidth >= 900) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: 80,
      ),
      child: WaterfallSkeleton(crossAxisCount: crossAxisCount),
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
            child: widget.dynamicsController.isLoadingDynamic.value
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
