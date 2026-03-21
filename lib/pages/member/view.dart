import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/pages/member/index.dart';
import 'package:piliotto/utils/utils.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({super.key});

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  late String heroTag;
  late MemberController _memberController;
  late Future _futureBuilderFuture;
  final ScrollController _scrollController = ScrollController();
  late int mid;

  @override
  void initState() {
    super.initState();
    mid = int.parse(Get.parameters['mid']!);
    heroTag = Get.arguments['heroTag'] ?? Utils.makeHeroTag(mid);
    _memberController = Get.put(MemberController(), tag: heroTag);
    _futureBuilderFuture = _memberController.getInfo();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
          final hasError = snapshot.hasError ||
              (snapshot.data != null &&
                  (snapshot.data as Map?)?['status'] != 'success');
          final hasData = snapshot.data != null &&
              (snapshot.data as Map?)?['status'] == 'success';

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAppBar(context, theme, isLoading),
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildBanner(theme),
                    if (hasData || isLoading) ...[
                      Positioned(
                        top: 200 - 45,
                        left: 20,
                        child: _buildAvatar(theme),
                      ),
                      _buildContent(context, theme, isLoading, hasData),
                    ],
                    if (hasError && !isLoading) _buildErrorContent(theme),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorContent(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 200),
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: TextStyle(
                fontSize: 18,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '无法获取用户信息',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _futureBuilderFuture = _memberController.getInfo();
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

  Widget _buildAppBar(BuildContext context, ThemeData theme, bool isLoading) {
    return SliverAppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Get.back(),
      ),
      actions: [
        if (!isLoading && _memberController.memberInfo.value.name != null) ...[
          IconButton(
            onPressed: () => Get.toNamed(
                '/memberSearch?mid=$mid&uname=${_memberController.memberInfo.value.name}'),
            icon: const Icon(Icons.search_outlined),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              if (_memberController.ownerMid != _memberController.mid) ...[
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
                )
              ],
              PopupMenuItem(
                onTap: () => _memberController.shareUser(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.share_outlined, size: 19),
                    const SizedBox(width: 10),
                    Text(_memberController.ownerMid != _memberController.mid
                        ? '分享用户'
                        : '分享我的主页'),
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
    );
  }

  Widget _buildBanner(ThemeData theme) {
    return Obx(() {
      final cover = _memberController.memberInfo.value.cover;
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          image: cover != null && cover.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(cover),
                  fit: BoxFit.cover,
                )
              : null,
        ),
      );
    });
  }

  Widget _buildAvatar(ThemeData theme) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.surface,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withAlpha(50),
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
                src: face,
                width: 90,
                height: 90,
                type: 'avatar',
              ),
            );
          }
          return CircleAvatar(
            radius: 45,
            backgroundColor: theme.colorScheme.surface,
            child: Icon(
              Icons.person,
              size: 50,
              color: theme.colorScheme.primary,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    bool isLoading,
    bool hasData,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 155),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserInfoSection(context, theme, isLoading, hasData),
          if (hasData) ...[
            const SizedBox(height: 16),
            _buildUserStats(theme),
            const SizedBox(height: 24),
            _buildMenuItems(context, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildUserInfoSection(
    BuildContext context,
    ThemeData theme,
    bool isLoading,
    bool hasData,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 115, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            Container(
              width: 150,
              height: 24,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            )
          else
            Obx(() => Text(
                  _memberController.memberInfo.value.name ?? '',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                )),
          const SizedBox(height: 4),
          if (isLoading)
            Container(
              width: 100,
              height: 14,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            )
          else
            Text(
              'UID: $mid',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 12),
          if (hasData)
            Obx(() {
              if (_memberController.isOwner.value) {
                return const SizedBox.shrink();
              }
              return Row(
                children: [
                  FilledButton(
                    onPressed: _memberController.actionRelationMod,
                    child: Obx(
                        () => Text(_memberController.attributeText.value)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      Get.toNamed(
                        '/whisperDetail',
                        parameters: {
                          'name':
                              _memberController.memberInfo.value.name ?? '',
                          'face': _memberController.face.value,
                          'mid': mid.toString(),
                          'heroTag': heroTag,
                        },
                      );
                    },
                    child: const Text('发消息'),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildUserStats(ThemeData theme) {
    return Obx(() {
      final info = _memberController.memberInfo.value;
      return Row(
        children: [
          _buildStatItem(theme, '关注', info.attention?.toString() ?? '0'),
          const SizedBox(width: 24),
          _buildStatItem(theme, '粉丝', info.fans?.toString() ?? '0'),
          const SizedBox(width: 24),
          _buildStatItem(theme, '动态', info.archiveCount?.toString() ?? '0'),
        ],
      );
    });
  }

  Widget _buildStatItem(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItems(BuildContext context, ThemeData theme) {
    return Obx(() => Column(
          children: [
            _buildMenuItem(
              context,
              theme,
              Icons.dynamic_feed_outlined,
              '${_memberController.isOwner.value ? '我' : 'Ta'}的动态',
              _memberController.pushDynamicsPage,
            ),
            _buildMenuItem(
              context,
              theme,
              Icons.play_circle_outlined,
              '${_memberController.isOwner.value ? '我' : 'Ta'}的投稿',
              _memberController.pushArchivesPage,
            ),
            _buildMenuItem(
              context,
              theme,
              Icons.favorite_border_outlined,
              '${_memberController.isOwner.value ? '我' : 'Ta'}的收藏',
              _memberController.pushfavPage,
            ),
            _buildMenuItem(
              context,
              theme,
              Icons.article_outlined,
              '${_memberController.isOwner.value ? '我' : 'Ta'}的专栏',
              _memberController.pushArticlePage,
            ),
          ],
        ));
  }

  Widget _buildMenuItem(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        size: 24,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_outlined, size: 19),
    );
  }
}
