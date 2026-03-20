import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/models/common/theme_type.dart';
import 'package:piliotto/pages/fav/index.dart';
import 'package:piliotto/pages/history/index.dart';
import 'package:piliotto/pages/later/index.dart';
import 'controller.dart';

class MinePage extends StatefulWidget {
  final bool showBackButton;
  const MinePage({super.key, this.showBackButton = false});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  final MineController mineController = Get.put(MineController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    mineController.userLogin.listen((status) {
      if (mounted) {
        setState(() {});
      }
    });
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
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(context, theme),
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _buildBanner(theme),
                Positioned(
                  top: 200 - 45,
                  left: 20,
                  child: _buildAvatar(theme),
                ),
                _buildContent(context, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme) {
    return SliverAppBar(
      leading: widget.showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            )
          : null,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          onPressed: () => mineController.onChangeTheme(),
          icon: Obx(() => Icon(
                mineController.themeType.value == ThemeType.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
                size: 22,
              )),
        ),
        IconButton(
          onPressed: () => Get.toNamed('/setting', preventDuplicates: false),
          icon: const Icon(Icons.settings_outlined, size: 22),
        ),
        const SizedBox(width: 4),
      ],
      floating: true,
      pinned: true,
      snap: true,
    );
  }

  Widget _buildBanner(ThemeData theme) {
    return Obx(() {
      final cover = mineController.userInfo.value.cover;
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
      onTap: () => mineController.onLogin(),
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
          final face = mineController.userInfo.value.face;
          if (face != null && face.isNotEmpty) {
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

  Widget _buildContent(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 155),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserInfoSection(context, theme),
          const SizedBox(height: 16),
          Obx(() => _buildUserStats(theme)),
          const SizedBox(height: 24),
          _buildMenuItems(context, theme),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 115, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() => Text(
                mineController.userInfo.value.uname ?? '点击头像登录',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              )),
          const SizedBox(height: 4),
          Obx(() {
            if (mineController.userLogin.value) {
              return Text(
                'UID: ${mineController.userInfo.value.mid}',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(height: 12),
          Obx(() {
            if (mineController.userLogin.value) {
              return FilledButton(
                onPressed: () => Get.toNamed('/member', parameters: {
                  'mid': mineController.userInfo.value.mid.toString(),
                }, arguments: {
                  'heroTag': 'mine',
                  'face': mineController.userInfo.value.face,
                }),
                child: const Text('编辑资料'),
              );
            }
            return FilledButton(
              onPressed: () => Get.toNamed('/loginPage'),
              child: const Text('立即登录'),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildUserStats(ThemeData theme) {
    return Row(
      children: [
        _buildStatItem(
          theme,
          '关注',
          mineController.userStat.value.following?.toString() ?? '0',
          () => mineController.pushFollow(),
        ),
        const SizedBox(width: 24),
        _buildStatItem(
          theme,
          '粉丝',
          mineController.userStat.value.follower?.toString() ?? '0',
          () => mineController.pushFans(),
        ),
        const SizedBox(width: 24),
        _buildStatItem(
          theme,
          '动态',
          mineController.userStat.value.dynamicCount?.toString() ?? '0',
          () => mineController.pushDynamic(),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        _buildMenuItem(
          context,
          theme,
          Icons.dynamic_feed_outlined,
          '我的动态',
          () => mineController.pushDynamic(),
        ),
        _buildMenuItem(
          context,
          theme,
          Icons.play_circle_outlined,
          '我的投稿',
          () {},
        ),
        _buildMenuItem(
          context,
          theme,
          Icons.favorite_border_outlined,
          '我的收藏',
          () => Get.to(const FavPage()),
        ),
        _buildMenuItem(
          context,
          theme,
          Icons.history_outlined,
          '历史记录',
          () => Get.to(const HistoryPage()),
        ),
        _buildMenuItem(
          context,
          theme,
          Icons.watch_later_outlined,
          '稍后再看',
          () => Get.to(const LaterPage()),
        ),
      ],
    );
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
