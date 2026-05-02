import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/models/common/theme_type.dart';
import 'package:piliotto/pages/mine/provider.dart';
import 'package:piliotto/utils/router_helper.dart';

class MinePage extends ConsumerStatefulWidget {
  final bool showBackButton;
  const MinePage({super.key, this.showBackButton = false});

  @override
  ConsumerState<MinePage> createState() => _MinePageState();
}

class _MinePageState extends ConsumerState<MinePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(mineProvider);
    final notifier = ref.read(mineProvider.notifier);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(context, theme, state, notifier),
          SliverToBoxAdapter(
            child: _buildContent(context, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme, MineState state, MineNotifier notifier) {
    return SliverAppBar(
      leading: widget.showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: _getIconColor(theme, state),
              ),
              onPressed: () => AppRouterHelper.back(context),
            )
          : null,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          onPressed: () => notifier.onChangeTheme(),
          icon: Icon(
            state.themeType == ThemeType.light
                ? Icons.light_mode
                : state.themeType == ThemeType.dark
                    ? Icons.dark_mode
                    : Icons.brightness_auto,
            size: 22,
            color: _getIconColor(theme, state),
          ),
        ),
        IconButton(
          onPressed: () => context.push('/setting'),
          icon: Icon(
            Icons.settings_outlined,
            size: 22,
            color: _getIconColor(theme, state),
          ),
        ),
        const SizedBox(width: 4),
      ],
      floating: true,
      pinned: true,
      snap: true,
      expandedHeight: 280,
      flexibleSpace:
          FlexibleSpaceBar(background: _buildHeaderWithUserInfo(theme, state, notifier)),
    );
  }

  Color _getIconColor(ThemeData theme, MineState state) {
    final cover = state.userInfo.cover;
    final hasCover = cover != null && cover.isNotEmpty;
    return hasCover ? Colors.white : theme.colorScheme.onSurface;
  }

  Widget _buildHeaderWithUserInfo(ThemeData theme, MineState state, MineNotifier notifier) {
    final cover = state.userInfo.cover;
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
                  _buildAvatar(theme, hasCover, state, notifier),
                  const SizedBox(width: 16),
                  Expanded(child: _buildUserDetails(theme, hasCover, state, notifier)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme, bool hasCover, MineState state, MineNotifier notifier) {
    return GestureDetector(
      onTap: () => notifier.onLogin(),
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
        child: Builder(
          builder: (context) {
            final face = state.userInfo.face;
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
          },
        ),
      ),
    );
  }

  Widget _buildUserDetails(ThemeData theme, bool hasCover, MineState state, MineNotifier notifier) {
    final textColor = hasCover ? Colors.white : theme.colorScheme.onSurface;
    final subTextColor =
        hasCover ? Colors.white70 : theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          state.userInfo.uname ?? '点击头像登录',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        if (state.userLogin)
          Text(
            'UID: ${state.userInfo.mid}',
            style: TextStyle(fontSize: 13, color: subTextColor),
          ),
        const SizedBox(height: 8),
        if (state.userLogin)
          Row(
            children: [
              _buildStatItem(
                '关注',
                state.userStat.following?.toString() ?? '0',
                () => notifier.pushFollow(),
                textColor,
                subTextColor,
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                '粉丝',
                state.userStat.follower?.toString() ?? '0',
                () => notifier.pushFans(),
                textColor,
                subTextColor,
              ),
            ],
          ),
        const SizedBox(height: 12),
        if (!state.userLogin)
          FilledButton(
            onPressed: () => context.push('/loginPage'),
            child: const Text('立即登录'),
          ),
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
          () => context.push('/fav'),
        ),
        _buildMenuItem(
          context,
          theme,
          Icons.history_outlined,
          '历史记录',
          () => context.push('/history'),
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
