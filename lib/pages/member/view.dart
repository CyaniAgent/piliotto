import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/skeleton/video_card_h.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/common/widgets/no_data.dart';
import 'package:piliotto/common/widgets/video_card_h.dart';
import 'package:piliotto/pages/dynamics/widgets/dynamic_panel.dart';
import 'package:piliotto/pages/fav/index.dart';
import 'package:piliotto/pages/member/index.dart';
import 'package:piliotto/pages/member_dynamics/index.dart';
import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/utils.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({super.key});

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> with TickerProviderStateMixin {
  late String heroTag;
  late MemberController _memberController;
  late MemberDynamicsController _dynamicsController;
  late Future _futureBuilderFuture;
  final ScrollController _scrollController = ScrollController();
  late int mid;
  late TabController _tabController;
  late List<String> _tabs;

  @override
  void initState() {
    super.initState();
    mid = int.parse(Get.parameters['mid']!);
    heroTag = Get.arguments['heroTag'] ?? Utils.makeHeroTag(mid);
    _memberController = Get.put(MemberController(), tag: heroTag);
    _dynamicsController = Get.put(MemberDynamicsController(), tag: heroTag);
    _futureBuilderFuture = _initData();
  }

  Future<void> _initData() async {
    await _memberController.getInfo();
    _tabs = _memberController.isOwner.value ? ['视频', '动态', '收藏'] : ['视频', '动态'];
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    await _memberController.getMemberArchive('init');
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    feedBack();
    _loadTabData(_tabController.index);
  }

  Future<void> _loadTabData(int index) async {
    if (_memberController.isOwner.value) {
      switch (index) {
        case 1:
          _dynamicsController.getMemberDynamic('onRefresh');
          break;
      }
    } else {
      switch (index) {
        case 1:
          _dynamicsController.getMemberDynamic('onRefresh');
          break;
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
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
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.back())),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorScaffold(ThemeData theme) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.back())),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('加载失败', style: TextStyle(fontSize: 18, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => setState(() => _futureBuilderFuture = _initData()),
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentScaffold(BuildContext context, ThemeData theme) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(context, theme),
          SliverPersistentHeader(
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
                isScrollable: false,
                dividerColor: Colors.transparent,
                tabAlignment: TabAlignment.center,
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
    if (_memberController.isOwner.value) {
      return [
        _VideoTabPage(heroTag: heroTag),
        _DynamicsTabPage(controller: _dynamicsController),
        const _FavoriteTabPage(),
      ];
    } else {
      return [
        _VideoTabPage(heroTag: heroTag),
        _DynamicsTabPage(controller: _dynamicsController),
      ];
    }
  }

  Widget _buildSliverAppBar(BuildContext context, ThemeData theme) {
    return SliverAppBar(
      leading: IconButton(
        icon: Obx(() => Icon(Icons.arrow_back, color: _getIconColor(theme))),
        onPressed: () => Get.back(),
      ),
      actions: [
        if (_memberController.memberInfo.value.name != null) ...[
          IconButton(
            onPressed: () => Get.toNamed('/memberSearch?mid=$mid&uname=${_memberController.memberInfo.value.name}'),
            icon: Obx(() => Icon(Icons.search_outlined, color: _getIconColor(theme))),
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
                      Obx(() => Text(_memberController.attribute.value != 128 ? '加入黑名单' : '移除黑名单')),
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
      flexibleSpace: FlexibleSpaceBar(background: _buildHeaderWithUserInfo(theme)),
    );
  }

  Color _getIconColor(ThemeData theme) {
    final cover = _memberController.memberInfo.value.cover;
    final hasCover = cover != null && cover.isNotEmpty;
    return hasCover ? Colors.white : theme.colorScheme.onSurface;
  }

  Widget _buildHeaderWithUserInfo(ThemeData theme) {
    return Obx(() {
      final cover = _memberController.memberInfo.value.cover;
      final hasCover = cover != null && cover.isNotEmpty;
      return Container(
        height: 280,
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildAvatar(theme, hasCover),
                    const SizedBox(width: 16),
                    Expanded(child: _buildUserDetails(theme, hasCover)),
                  ],
                ),
              ],
            ),
          ),
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
            color: hasCover ? Colors.black.withAlpha(80) : theme.colorScheme.shadow.withAlpha(50),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Obx(() {
        final face = _memberController.face.value;
        if (face.isNotEmpty) {
          return ClipOval(
            child: NetworkImgLayer(src: face, width: 70, height: 70, type: 'avatar'),
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
    final subTextColor = hasCover ? Colors.white70 : theme.colorScheme.onSurfaceVariant;
    
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
                _buildStatItem('关注', _memberController.memberInfo.value.attention?.toString() ?? '0', textColor, subTextColor),
                const SizedBox(width: 16),
                _buildStatItem('粉丝', _memberController.memberInfo.value.fans?.toString() ?? '0', textColor, subTextColor),
              ],
            )),
        if (!_memberController.isOwner.value) ...[
          const SizedBox(height: 12),
          Obx(() => Row(
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
                    onPressed: () => Get.toNamed('/whisperDetail', parameters: {
                      'name': _memberController.memberInfo.value.name ?? '',
                      'face': _memberController.face.value,
                      'mid': mid.toString(),
                      'heroTag': heroTag,
                    }),
                    child: const Text('发消息'),
                  ),
                ],
              )),
        ],
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor, Color labelColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: valueColor)),
        Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
      ],
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Theme.of(context).colorScheme.surface, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}

class _VideoTabPage extends StatefulWidget {
  final String heroTag;

  const _VideoTabPage({required this.heroTag});

  @override
  State<_VideoTabPage> createState() => _VideoTabPageState();
}

class _VideoTabPageState extends State<_VideoTabPage> with AutomaticKeepAliveClientMixin {
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
      if (_controller.isLoadingArchive.value && _controller.archiveList.isEmpty) {
        return ListView.builder(itemCount: 10, itemBuilder: (_, __) => const VideoCardHSkeleton());
      }
      if (_controller.archiveList.isEmpty) {
        return const NoData();
      }
      return ListView.builder(
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

class _DynamicsTabPageState extends State<_DynamicsTabPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      final list = widget.controller.dynamicsList;
      if (list.isEmpty) {
        return const NoData();
      }
      return ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) => DynamicPanel(item: list[index]),
      );
    });
  }
}

class _FavoriteTabPage extends StatefulWidget {
  const _FavoriteTabPage();

  @override
  State<_FavoriteTabPage> createState() => _FavoriteTabPageState();
}

class _FavoriteTabPageState extends State<_FavoriteTabPage> with AutomaticKeepAliveClientMixin {
  FavController? _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(FavController());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Obx(() {
      if (_controller!.isLoading.value && _controller!.favoriteList.isEmpty) {
        return ListView.builder(itemCount: 10, itemBuilder: (_, __) => const VideoCardHSkeleton());
      }
      if (_controller!.favoriteList.isEmpty) {
        return const NoData();
      }
      return ListView.builder(
        controller: _controller!.scrollController,
        itemCount: _controller!.favoriteList.length,
        itemBuilder: (context, index) => VideoCardH(videoItem: _controller!.favoriteList[index]),
      );
    });
  }
}
