import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/models/common/theme_type.dart';
import 'package:piliotto/pages/mine/provider.dart';

class UserDrawer extends ConsumerWidget {
  const UserDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(mineProvider);
    final notifier = ref.read(mineProvider.notifier);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, theme, state, notifier),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildUserStats(theme, state, notifier),
                    const Divider(height: 1),
                    _buildMenuItems(context, theme, notifier),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, ThemeData theme, MineState state, MineNotifier notifier) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => notifier.onChangeTheme(),
                icon: Icon(
                  state.themeType == ThemeType.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  size: 20,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/setting');
                },
                icon: Icon(
                  Icons.settings_outlined,
                  size: 20,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildAvatar(theme, state, notifier, context),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.userInfo.uname ?? '点击头像登录',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (state.userLogin)
                      Text(
                        'UID: ${state.userInfo.mid}',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSecondaryContainer
                              .withAlpha(180),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!state.userLogin)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/loginPage');
                },
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.onSecondaryContainer,
                  foregroundColor: theme.colorScheme.secondaryContainer,
                ),
                child: const Text('立即登录'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(
      ThemeData theme, MineState state, MineNotifier notifier, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        notifier.onLogin();
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.surface,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withAlpha(30),
              blurRadius: 8,
              spreadRadius: 1,
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
                  width: 56,
                  height: 56,
                  type: 'avatar',
                ),
              );
            }
            return CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.surface,
              child: Icon(
                Icons.person,
                size: 32,
                color: theme.colorScheme.primary,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserStats(ThemeData theme, MineState state, MineNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            theme,
            state.userStat.following?.toString() ?? '0',
            '关注',
            () => notifier.pushFollow(),
          ),
          _buildStatDivider(theme),
          _buildStatItem(
            theme,
            state.userStat.follower?.toString() ?? '0',
            '粉丝',
            () => notifier.pushFans(),
          ),
          _buildStatDivider(theme),
          _buildStatItem(
            theme,
            state.userStat.dynamicCount?.toString() ?? '0',
            '动态',
            () => notifier.pushDynamic(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    String value,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
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

  Widget _buildStatDivider(ThemeData theme) {
    return Container(
      height: 32,
      width: 1,
      color: theme.colorScheme.outlineVariant,
    );
  }

  Widget _buildMenuItems(
      BuildContext context, ThemeData theme, MineNotifier notifier) {
    return Column(
      children: [
        _buildMenuItem(
          context,
          theme,
          Icons.history_outlined,
          '历史记录',
          () => context.push('/history'),
        ),
        _buildMenuItem(
          context,
          theme,
          Icons.star_outline,
          '我的收藏',
          () => context.push('/fav'),
        ),
        _buildMenuItem(
          context,
          theme,
          Icons.dynamic_feed_outlined,
          '我的动态',
          () => notifier.pushDynamic(),
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
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        size: 18,
        color: theme.colorScheme.outline,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
