import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:piliotto/common/skeleton/video_card_h.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/common/widgets/no_data.dart';
import 'package:piliotto/common/widgets/video_card_h.dart';
import 'package:piliotto/pages/dynamics/widgets/dynamic_panel.dart';
import 'package:piliotto/pages/fav/index.dart';
import 'package:piliotto/pages/member/index.dart';
import 'package:piliotto/pages/member_dynamics/index.dart';
import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/responsive_util.dart';
import 'package:piliotto/utils/route_arguments.dart';
import 'package:piliotto/utils/utils.dart';

class MemberPage extends ConsumerStatefulWidget {
  const MemberPage({super.key});

  @override
  ConsumerState<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends ConsumerState<MemberPage>
    with TickerProviderStateMixin {
  late String heroTag;
  Future? _futureBuilderFuture;
  final ScrollController _scrollController = ScrollController();
  late int mid;
  late TabController _tabController;
  late List<String> _tabs;
  int _previousTabIndex = 0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    mid = int.parse(routeArguments.queryParameters['mid']!);
    heroTag = routeArguments['heroTag'] ?? Utils.makeHeroTag(mid);
    _tabs = ['视频', '动态'];
    _tabController = TabController(length: _tabs.length, vsync: this);
    _previousTabIndex = 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _futureBuilderFuture = _initData();
    }
  }

  Future<void> _initData() async {
    final notifier = ref.read(memberProvider(mid).notifier);
    await notifier.getInfo();
    final state = ref.read(memberProvider(mid));
    final newTabs = state.isOwner ? ['视频', '动态', '收藏'] : ['视频', '动态'];
    if (newTabs.length != _tabs.length) {
      _tabController.dispose();
      _tabController = TabController(length: newTabs.length, vsync: this);
      _tabs = newTabs;
    }
    await notifier.getMemberArchive('init');
  }

  void _onTapTab(int index) {
    feedBack();
    if (index == _previousTabIndex) {
      _scrollToTop();
    }
    _previousTabIndex = index;
    _tabController.animateTo(index);
    _loadTabData(index);
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      if (_scrollController.offset >= MediaQuery.of(context).size.height * 3) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut);
      }
    }
  }

  Future<void> _loadTabData(int index) async {
    final state = ref.read(memberProvider(mid));
    if (state.isOwner) {
      switch (index) {
        case 1:
          ref
              .read(memberDynamicsProvider(mid).notifier)
              .getMemberDynamic('onRefresh');
          break;
      }
    } else {
      switch (index) {
        case 1:
          ref
              .read(memberDynamicsProvider(mid).notifier)
              .getMemberDynamic('onRefresh');
          break;
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(memberProvider(mid));

    return Scaffold(
      body: FutureBuilder(
        future: _futureBuilderFuture,
        builder: (context, snapshot) {
          final isLoading = _futureBuilderFuture == null ||
              snapshot.connectionState != ConnectionState.done;
          final hasError = snapshot.hasError;

          if (isLoading) {
            return _buildLoadingScaffold(theme);
          }

          if (hasError) {
            return _buildErrorScaffold(theme);
          }

          return _buildContentScaffold(context, theme, state);
        },
      ),
    );
  }

  Widget _buildLoadingScaffold(ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop())),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorScaffold(ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop())),
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
              onPressed: () {
                setState(() {
                  _futureBuilderFuture = _initData();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentScaffold(
      BuildContext context, ThemeData theme, MemberState state) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(context, theme, state),
          SliverPersistentHeader(
            delegate: _SliverTabBarDelegate(
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
          children: _buildTabPages(state),
        ),
      ),
    );
  }

  List<Widget> _buildTabPages(MemberState state) {
    if (state.isOwner) {
      return [
        _VideoTabPage(heroTag: heroTag, mid: mid),
        _DynamicsTabPage(mid: mid),
        const _FavoriteTabPage(),
      ];
    } else {
      return [
        _VideoTabPage(heroTag: heroTag, mid: mid),
        _DynamicsTabPage(mid: mid),
      ];
    }
  }

  Widget _buildSliverAppBar(
      BuildContext context, ThemeData theme, MemberState state) {
    return SliverAppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: _getIconColor(theme, state)),
        onPressed: () => context.pop(),
      ),
      title: ListenableBuilder(
        listenable: _scrollController,
        builder: (context, _) {
          final name = state.memberInfo.name;
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
                    src: state.face,
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
        if (state.memberInfo.name != null) ...[
          if (!state.isOwner && MediaQuery.of(context).size.width < 600)
            IconButton(
              onPressed: () => context.push('/message', extra: {
                'mid': mid.toString(),
                'name': state.memberInfo.name ?? '',
                'face': state.face,
              }),
              icon:
                  Icon(Icons.mail_outline, color: _getIconColor(theme, state)),
            ),
          IconButton(
            onPressed: () => context
                .push('/memberSearch?mid=$mid&uname=${state.memberInfo.name}'),
            icon:
                Icon(Icons.search_outlined, color: _getIconColor(theme, state)),
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: _getIconColor(theme, state)),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              if (!state.isOwner)
                PopupMenuItem(
                  onTap: () =>
                      ref.read(memberProvider(mid).notifier).blockUser(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.block, size: 19),
                      const SizedBox(width: 10),
                      Text(state.attribute != 128 ? '加入黑名单' : '移除黑名单'),
                    ],
                  ),
                ),
              PopupMenuItem(
                onTap: () => ref.read(memberProvider(mid).notifier).shareUser(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.share_outlined, size: 19),
                    const SizedBox(width: 10),
                    Text(!state.isOwner ? '分享用户' : '分享我的主页'),
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
          FlexibleSpaceBar(background: _buildHeaderWithUserInfo(theme, state)),
    );
  }

  Color _getIconColor(ThemeData theme, MemberState state) {
    final cover = state.memberInfo.cover;
    final hasCover = cover != null && cover.isNotEmpty;
    return hasCover ? Colors.white : theme.colorScheme.onSurface;
  }

  Widget _buildHeaderWithUserInfo(ThemeData theme, MemberState state) {
    final isNarrowScreen = MediaQuery.of(context).size.width < 600;

    final cover = state.memberInfo.cover;
    final hasCover = cover != null && cover.isNotEmpty;
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        image: hasCover
            ? DecorationImage(
                image: NetworkImage(cover),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withAlpha(hasCover ? 100 : 0),
                  BlendMode.darken,
                ),
              )
            : null,
      ),
      child: SafeArea(
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
                      _buildAvatar(theme, state, hasCover),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildUserDetails(theme, state, hasCover)),
                    ],
                  ),
                ],
              ),
            ),
            if (!state.isOwner)
              Positioned(
                right: 16,
                bottom: 16,
                child:
                    _buildActionButtons(theme, state, hasCover, isNarrowScreen),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme, MemberState state, bool hasCover) {
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
      child: () {
        final face = state.face;
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
      }(),
    );
  }

  Widget _buildUserDetails(ThemeData theme, MemberState state, bool hasCover) {
    final textColor = hasCover ? Colors.white : theme.colorScheme.onSurface;
    final subTextColor =
        hasCover ? Colors.white70 : theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          state.memberInfo.name ?? '',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text('UID: $mid', style: TextStyle(fontSize: 13, color: subTextColor)),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildStatItem('关注', state.memberInfo.attention?.toString() ?? '0',
                textColor, subTextColor),
            const SizedBox(width: 16),
            _buildStatItem('粉丝', state.memberInfo.fans?.toString() ?? '0',
                textColor, subTextColor),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(
      ThemeData theme, MemberState state, bool hasCover, bool isNarrowScreen) {
    final textColor = hasCover ? Colors.white : theme.colorScheme.onSurface;
    final subTextColor =
        hasCover ? Colors.white70 : theme.colorScheme.onSurfaceVariant;

    if (isNarrowScreen) {
      return FilledButton(
        onPressed: () =>
            ref.read(memberProvider(mid).notifier).actionRelationMod(),
        child: Text(state.attributeText),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton(
          onPressed: () =>
              ref.read(memberProvider(mid).notifier).actionRelationMod(),
          child: Text(state.attributeText),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor,
            side: BorderSide(color: subTextColor),
          ),
          onPressed: () => context.push('/message', extra: {
            'mid': mid.toString(),
            'name': state.memberInfo.name ?? '',
            'face': state.face,
          }),
          child: const Text('发消息'),
        ),
      ],
    );
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

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => 42;

  @override
  double get maxExtent => 42;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SizedBox(
        width: double.infinity,
        height: 42,
        child: Align(
          alignment: Alignment.center,
          child: tabBar,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}

class _VideoTabPage extends ConsumerStatefulWidget {
  final String heroTag;
  final int mid;

  const _VideoTabPage({required this.heroTag, required this.mid});

  @override
  ConsumerState<_VideoTabPage> createState() => _VideoTabPageState();
}

class _VideoTabPageState extends ConsumerState<_VideoTabPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(memberProvider(widget.mid));

    if (state.isLoadingArchive && state.archiveList.isEmpty) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: state.crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 3 / 1,
        ),
        itemCount: 10,
        itemBuilder: (_, __) => const VideoCardHSkeleton(),
      );
    }
    if (state.archiveList.isEmpty) {
      return const NoData();
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: state.crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 3 / 1,
      ),
      itemCount: state.archiveList.length,
      itemBuilder: (context, index) => VideoCardH(
        videoItem: state.archiveList[index],
        showOwner: false,
        showPubdate: true,
      ),
    );
  }
}

class _DynamicsTabPage extends ConsumerStatefulWidget {
  final int mid;

  const _DynamicsTabPage({required this.mid});

  @override
  ConsumerState<_DynamicsTabPage> createState() => _DynamicsTabPageState();
}

class _DynamicsTabPageState extends ConsumerState<_DynamicsTabPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(memberDynamicsProvider(widget.mid));
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = ResponsiveUtil.isLg || ResponsiveUtil.isXl;
    const maxContentWidth = 600.0;

    final list = state.dynamicsList;
    if (list.isEmpty) {
      return const NoData();
    }
    return ListView.builder(
      controller: ref
          .read(memberDynamicsProvider(widget.mid).notifier)
          .scrollController,
      padding: _buildPadding(isWideScreen, screenWidth, maxContentWidth),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          width: isWideScreen ? maxContentWidth : null,
          child: DynamicPanel(
            item: list[index],
            onTap: () => context.push('/dynamicDetail', extra: {
              'item': list[index],
              'floor': 1,
            }),
            onCommentTap: () => context.push('/dynamicDetail', extra: {
              'item': list[index],
              'floor': 1,
              'action': 'comment',
            }),
          ),
        );
      },
    );
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

class _FavoriteTabPage extends ConsumerStatefulWidget {
  const _FavoriteTabPage();

  @override
  ConsumerState<_FavoriteTabPage> createState() => _FavoriteTabPageState();
}

class _FavoriteTabPageState extends ConsumerState<_FavoriteTabPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(favProvider.notifier).queryFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(favProvider);

    if (state.isLoading && state.favoriteList.isEmpty) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: state.crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 3 / 1,
        ),
        itemCount: 10,
        itemBuilder: (_, __) => const VideoCardHSkeleton(),
      );
    }
    if (state.favoriteList.isEmpty) {
      return const NoData();
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: state.crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 3 / 1,
      ),
      itemCount: state.favoriteList.length,
      itemBuilder: (context, index) =>
          VideoCardH(videoItem: state.favoriteList[index]),
    );
  }
}
