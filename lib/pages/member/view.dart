import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/mixins/scroll_to_top.dart';
import 'package:piliotto/common/skeleton/video_card_h.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/common/widgets/no_data.dart';
import 'package:piliotto/common/widgets/page_widgets.dart';
import 'package:piliotto/common/widgets/video_card_h.dart';
import 'package:piliotto/pages/dynamics/widgets/dynamic_panel.dart';
import 'package:piliotto/pages/fav/index.dart';
import 'package:piliotto/pages/member/index.dart';
import 'package:piliotto/pages/member_dynamics/index.dart';
import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/responsive_util.dart';
import 'package:piliotto/utils/utils.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({super.key});

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage>
    with TickerProviderStateMixin, ScrollToTopMixin {
  late String heroTag;
  late MemberController _memberController;
  late MemberDynamicsController _dynamicsController;
  late FavController _favController;
  late Future _futureBuilderFuture;
  final ScrollController _scrollController = ScrollController();
  late int mid;
  TabController? _tabController;
  List<String> _tabs = [];
  int _previousTabIndex = 0;
  final RxBool _hasVideoContent = false.obs;
  final RxBool _hasDynamicContent = false.obs;
  final RxBool _hasFavoriteContent = false.obs;

  @override
  void initState() {
    super.initState();
    mid = int.parse(Get.parameters['mid']!);
    heroTag = Get.arguments['heroTag'] ?? Utils.makeHeroTag(mid);
    _memberController = Get.put(MemberController(), tag: heroTag);
    _dynamicsController = Get.put(MemberDynamicsController(), tag: heroTag);
    _favController = Get.put(FavController(), tag: heroTag);
    _futureBuilderFuture = _initData();
  }

  Future<void> _initData() async {
    await _memberController.getInfo();
    await Future.wait([
      _memberController.getMemberArchive('init'),
      _dynamicsController.getMemberDynamic('init'),
      if (_memberController.isOwner.value) _favController.queryFavorites(),
    ]);
    _updateTabs();
  }

  void _updateTabs() {
    _hasVideoContent.value = _memberController.archiveList.isNotEmpty;
    _hasDynamicContent.value = _dynamicsController.dynamicsList.isNotEmpty;
    _hasFavoriteContent.value = _favController.favoriteList.isNotEmpty;

    final newTabs = <String>[];
    if (_hasVideoContent.value) newTabs.add('视频');
    if (_hasDynamicContent.value) newTabs.add('动态');
    if (_memberController.isOwner.value && _hasFavoriteContent.value) {
      newTabs.add('收藏');
    }

    if (newTabs.length != _tabs.length || !_listEquals(newTabs, _tabs)) {
      _tabController?.dispose();
      _tabController = TabController(length: newTabs.length, vsync: this);
      _tabs = newTabs;
      _previousTabIndex = 0;
    }
    setState(() {});
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool get _hasAnyContent =>
      _hasVideoContent.value ||
      _hasDynamicContent.value ||
      (_memberController.isOwner.value && _hasFavoriteContent.value);

  void _onTapTab(int index) {
    feedBack();
    if (index == _previousTabIndex) {
      scrollToTop(_scrollController);
    }
    _previousTabIndex = index;
    _tabController?.animateTo(index);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: FutureBuilder(
        future: _futureBuilderFuture,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState != ConnectionState.done;
          final hasError = snapshot.hasError;

          if (isLoading) {
            return _buildLoadingScaffold(theme);
          }

          if (hasError) {
            return _buildErrorScaffold(theme);
          }

          return _buildContentScaffold(context, theme);
        },
      ),
    );
  }

  Widget _buildLoadingScaffold(ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back), onPressed: () => Get.back())),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorScaffold(ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back), onPressed: () => Get.back())),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('加载失败',
                style: TextStyle(
                    fontSize: 18, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  setState(() => _futureBuilderFuture = _initData()),
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentScaffold(BuildContext context, ThemeData theme) {
    if (!_hasAnyContent) {
      return Scaffold(
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildSliverAppBar(context, theme),
          ],
          body: const NoData(),
        ),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(context, theme),
          SliverPersistentHeader(
            delegate: SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
                isScrollable: true,
                dividerColor: Colors.transparent,
                splashBorderRadius: BorderRadius.circular(10),
                tabAlignment: TabAlignment.center,
                onTap: _onTapTab,
              ),
            ),
            pinned: true,
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: _buildTabPages(),
        ),
      ),
    );
  }

  List<Widget> _buildTabPages() {
    final pages = <Widget>[];
    if (_hasVideoContent.value) {
      pages.add(_VideoTabPage(heroTag: heroTag));
    }
    if (_hasDynamicContent.value) {
      pages.add(_DynamicsTabPage(controller: _dynamicsController));
    }
    if (_memberController.isOwner.value && _hasFavoriteContent.value) {
      pages.add(_FavoriteTabPage(controller: _favController));
    }
    return pages;
  }

  Widget _buildSliverAppBar(BuildContext context, ThemeData theme) {
    return SliverAppBar(
      leading: IconButton(
        icon: Obx(() => Icon(Icons.arrow_back, color: _getIconColor(theme))),
        onPressed: () => Get.back(),
      ),
      title: ListenableBuilder(
        listenable: _scrollController,
        builder: (context, _) {
          final name = _memberController.memberInfo.value.name;
          if (name == null || name.isEmpty) return const SizedBox();

          const maxOffset = kToolbarHeight + 50.0;
          final currentOffset = _scrollController.hasClients
              ? _scrollController.offset.clamp(0.0, maxOffset)
              : 0.0;
          final opacity = (currentOffset / maxOffset).clamp(0.0, 1.0);

          return Opacity(
            opacity: opacity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: NetworkImgLayer(
                    src: _memberController.face.value,
                    width: 32,
                    height: 32,
                    type: 'avatar',
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'UID: $mid',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withAlpha(180),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        if (_memberController.memberInfo.value.name != null) ...[
          if (!_memberController.isOwner.value &&
              MediaQuery.of(context).size.width < 600)
            IconButton(
              onPressed: () => Get.toNamed('/message', parameters: {
                'mid': mid.toString(),
                'name': _memberController.memberInfo.value.name ?? '',
                'face': _memberController.face.value,
              }),
              icon: Obx(
                  () => Icon(Icons.mail_outline, color: _getIconColor(theme))),
            ),
          IconButton(
            onPressed: () => Get.toNamed(
                '/memberSearch?mid=$mid&uname=${_memberController.memberInfo.value.name}'),
            icon: Obx(
                () => Icon(Icons.search_outlined, color: _getIconColor(theme))),
          ),
          PopupMenuButton(
            icon: Obx(() => Icon(Icons.more_vert, color: _getIconColor(theme))),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              if (!_memberController.isOwner.value)
                PopupMenuItem(
                  onTap: () => _memberController.blockUser(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.block, size: 19),
                      const SizedBox(width: 10),
                      Obx(() => Text(_memberController.attribute.value != 128
                          ? '加入黑名单'
                          : '移除黑名单')),
                    ],
                  ),
                ),
              PopupMenuItem(
                onTap: () => _memberController.shareUser(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.share_outlined, size: 19),
                    const SizedBox(width: 10),
                    Text(!_memberController.isOwner.value ? '分享用户' : '分享我的主页'),
                  ],
                ),
              ),
            ],
          ),
        ],
        const SizedBox(width: 4),
      ],
      floating: true,
      pinned: true,
      snap: true,
      expandedHeight: 280,
      flexibleSpace:
          FlexibleSpaceBar(background: _buildHeaderWithUserInfo(theme)),
    );
  }

  Color _getIconColor(ThemeData theme) {
    final cover = _memberController.memberInfo.value.cover;
    final hasCover = cover != null && cover.isNotEmpty;
    return hasCover ? Colors.white : theme.colorScheme.onSurface;
  }

  Widget _buildHeaderWithUserInfo(ThemeData theme) {
    final isNarrowScreen = MediaQuery.of(context).size.width < 600;

    return Obx(() {
      final cover = _memberController.memberInfo.value.cover;
      final hasCover = cover != null && cover.isNotEmpty;
      return Container(
        height: 240,
        color: theme.colorScheme.secondaryContainer,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasCover)
              CachedNetworkImage(
                imageUrl: cover.startsWith('//') ? 'https:$cover' : cover,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 300),
                fadeOutDuration: const Duration(milliseconds: 120),
                placeholder: (context, url) => const SizedBox.shrink(),
                errorWidget: (context, url, error) => const SizedBox.shrink(),
              ),
            Container(
              color:
                  hasCover ? Colors.black.withAlpha(100) : Colors.transparent,
            ),
            SafeArea(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAvatar(theme, hasCover),
                            const SizedBox(width: 16),
                            Expanded(child: _buildUserDetails(theme, hasCover)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!_memberController.isOwner.value)
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child:
                          _buildActionButtons(theme, hasCover, isNarrowScreen),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAvatar(ThemeData theme, bool hasCover) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: hasCover ? Colors.white : theme.colorScheme.primary,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: hasCover
                ? Colors.black.withAlpha(80)
                : theme.colorScheme.shadow.withAlpha(50),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Obx(() {
        final face = _memberController.face.value;
        if (face.isNotEmpty) {
          return ClipOval(
            child: NetworkImgLayer(
                src: face, width: 70, height: 70, type: 'avatar'),
          );
        }
        return CircleAvatar(
          radius: 35,
          backgroundColor: theme.colorScheme.surface,
          child: Icon(Icons.person, size: 40, color: theme.colorScheme.primary),
        );
      }),
    );
  }

  Widget _buildUserDetails(ThemeData theme, bool hasCover) {
    final textColor = hasCover ? Colors.white : theme.colorScheme.onSurface;
    final subTextColor =
        hasCover ? Colors.white70 : theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() => Text(
              _memberController.memberInfo.value.name ?? '',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            )),
        const SizedBox(height: 4),
        Text('UID: $mid', style: TextStyle(fontSize: 13, color: subTextColor)),
        const SizedBox(height: 8),
        Obx(() => Row(
              children: [
                _buildStatItem(
                    '关注',
                    _memberController.memberInfo.value.attention?.toString() ??
                        '0',
                    textColor,
                    subTextColor),
                const SizedBox(width: 16),
                _buildStatItem(
                    '粉丝',
                    _memberController.memberInfo.value.fans?.toString() ?? '0',
                    textColor,
                    subTextColor),
              ],
            )),
      ],
    );
  }

  Widget _buildActionButtons(
      ThemeData theme, bool hasCover, bool isNarrowScreen) {
    final textColor = hasCover ? Colors.white : theme.colorScheme.onSurface;
    final subTextColor =
        hasCover ? Colors.white70 : theme.colorScheme.onSurfaceVariant;

    return Obx(() {
      if (isNarrowScreen) {
        return FilledButton(
          onPressed: _memberController.actionRelationMod,
          child: Text(_memberController.attributeText.value),
        );
      }
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton(
            onPressed: _memberController.actionRelationMod,
            child: Text(_memberController.attributeText.value),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: textColor,
              side: BorderSide(color: subTextColor),
            ),
            onPressed: () => Get.toNamed('/message', parameters: {
              'mid': mid.toString(),
              'name': _memberController.memberInfo.value.name ?? '',
              'face': _memberController.face.value,
            }),
            child: const Text('发消息'),
          ),
        ],
      );
    });
  }

  Widget _buildStatItem(
      String label, String value, Color valueColor, Color labelColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: valueColor)),
        Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
      ],
    );
  }
}

class _VideoTabPage extends StatefulWidget {
  final String heroTag;

  const _VideoTabPage({required this.heroTag});

  @override
  State<_VideoTabPage> createState() => _VideoTabPageState();
}

class _VideoTabPageState extends State<_VideoTabPage>
    with AutomaticKeepAliveClientMixin {
  late MemberController _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<MemberController>(tag: widget.heroTag);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      if (_controller.isLoadingArchive.value &&
          _controller.archiveList.isEmpty) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _controller.crossAxisCount.value,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 3 / 1,
          ),
          itemCount: 10,
          itemBuilder: (_, __) => const VideoCardHSkeleton(),
        );
      }
      if (_controller.archiveList.isEmpty) {
        return const NoData();
      }
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _controller.crossAxisCount.value,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 3 / 1,
        ),
        itemCount: _controller.archiveList.length,
        itemBuilder: (context, index) => VideoCardH(
          videoItem: _controller.archiveList[index],
          showOwner: false,
          showPubdate: true,
        ),
      );
    });
  }
}

class _DynamicsTabPage extends StatefulWidget {
  final MemberDynamicsController controller;

  const _DynamicsTabPage({required this.controller});

  @override
  State<_DynamicsTabPage> createState() => _DynamicsTabPageState();
}

class _DynamicsTabPageState extends State<_DynamicsTabPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = ResponsiveUtil.isLg || ResponsiveUtil.isXl;
    const maxContentWidth = 600.0;

    return Obx(() {
      final list = widget.controller.dynamicsList;
      if (widget.controller.isLoading.value && list.isEmpty) {
        return ListView.builder(
          padding: _buildPadding(isWideScreen, screenWidth, maxContentWidth),
          itemCount: 5,
          itemBuilder: (context, index) => Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: const DynamicPanelSkeleton(),
          ),
        );
      }
      if (list.isEmpty) {
        return const NoData();
      }
      return ListView.builder(
        controller: widget.controller.scrollController,
        padding: _buildPadding(isWideScreen, screenWidth, maxContentWidth),
        itemCount: list.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            width: isWideScreen ? maxContentWidth : null,
            child: DynamicPanel(
              item: list[index],
              onTap: () => Get.toNamed('/dynamicDetail', arguments: {
                'item': list[index],
                'floor': 1,
              }),
              onCommentTap: () => Get.toNamed('/dynamicDetail', arguments: {
                'item': list[index],
                'floor': 1,
                'action': 'comment',
              }),
            ),
          );
        },
      );
    });
  }

  EdgeInsets _buildPadding(
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
      top: 8,
      bottom: 80,
    );
  }
}

class DynamicPanelSkeleton extends StatelessWidget {
  const DynamicPanelSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 60,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 200,
            height: 14,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteTabPage extends StatefulWidget {
  final FavController controller;

  const _FavoriteTabPage({required this.controller});

  @override
  State<_FavoriteTabPage> createState() => _FavoriteTabPageState();
}

class _FavoriteTabPageState extends State<_FavoriteTabPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      if (widget.controller.isLoading.value &&
          widget.controller.favoriteList.isEmpty) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.controller.crossAxisCount.value,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 3 / 1,
          ),
          itemCount: 10,
          itemBuilder: (_, __) => const VideoCardHSkeleton(),
        );
      }
      if (widget.controller.favoriteList.isEmpty) {
        return const NoData();
      }
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        controller: widget.controller.scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.controller.crossAxisCount.value,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 3 / 1,
        ),
        itemCount: widget.controller.favoriteList.length,
        itemBuilder: (context, index) =>
            VideoCardH(videoItem: widget.controller.favoriteList[index]),
      );
    });
  }
}
