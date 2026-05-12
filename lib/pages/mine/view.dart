import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/models/common/theme_type.dart';
import 'package:piliotto/pages/fav/index.dart';
import 'package:piliotto/pages/history/index.dart';
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
            child: _buildContent(context, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme) {
    return SliverAppBar(
      leading: widget.showBackButton
          ? IconButton(
              icon: Obx(() => Icon(
                    Icons.arrow_back,
                    color: _getIconColor(theme),
                  )),
              onPressed: () => Get.back(),
            )
          : null,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          onPressed: () => mineController.onChangeTheme(),
          icon: Obx(() => Icon(
                mineController.themeType.value == ThemeType.light
                    ? Icons.light_mode
                    : mineController.themeType.value == ThemeType.dark
                        ? Icons.dark_mode
                        : Icons.brightness_auto,
                size: 22,
                color: _getIconColor(theme),
              )),
        ),
        IconButton(
          onPressed: () => Get.toNamed('/setting', preventDuplicates: false),
          icon: Obx(() => Icon(
                Icons.settings_outlined,
                size: 22,
                color: _getIconColor(theme),
              )),
        ),
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
    final cover = mineController.userInfo.value.cover;
    final hasCover = cover != null && cover.isNotEmpty;
    return hasCover ? Colors.white : theme.colorScheme.onSurface;
  }

  Widget _buildHeaderWithUserInfo(ThemeData theme) {
    return Obx(() {
      final cover = mineController.userInfo.value.cover;
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
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Row(
                children: [
                  _buildAvatar(theme, hasCover),
                  const SizedBox(width: 16),
                  Expanded(child: _buildUserDetails(theme, hasCover)),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAvatar(ThemeData theme, bool hasCover) {
    return GestureDetector(
      onTap: () => mineController.onLogin(),
      child: Container(
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
          final face = mineController.userInfo.value.face;
          if (face != null && face.isNotEmpty) {
            return ClipOval(
              child: NetworkImgLayer(
                src: face,
                width: 80,
                height: 80,
                type: 'avatar',
              ),
            );
          }
          return CircleAvatar(
            radius: 40,
            backgroundColor: theme.colorScheme.surface,
            child: Icon(
              Icons.person,
              size: 45,
              color: theme.colorScheme.primary,
            ),
          );
        }),
      ),
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
              mineController.userInfo.value.uname ?? '点击头像登录',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            )),
        const SizedBox(height: 4),
        Obx(() {
          if (mineController.userLogin.value) {
            return Text(
              'UID: ${mineController.userInfo.value.mid}',
              style: TextStyle(fontSize: 13, color: subTextColor),
            );
          }
          return const SizedBox.shrink();
        }),
        const SizedBox(height: 8),
        Obx(() {
          if (mineController.userLogin.value) {
            return Row(
              children: [
                _buildStatItem(
                  '关注',
                  mineController.userStat.value.following?.toString() ?? '0',
                  () => mineController.pushFollow(),
                  textColor,
                  subTextColor,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  '粉丝',
                  mineController.userStat.value.follower?.toString() ?? '0',
                  () => mineController.pushFans(),
                  textColor,
                  subTextColor,
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
        const SizedBox(height: 12),
        Obx(() {
          if (!mineController.userLogin.value) {
            return FilledButton(
              onPressed: () => Get.toNamed('/loginPage'),
              child: const Text('立即登录'),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, VoidCallback onTap,
      Color valueColor, Color labelColor) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: valueColor),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: labelColor),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildMenuItems(context, theme),
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
