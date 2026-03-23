import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/models/common/theme_type.dart';
import 'package:piliotto/pages/fav/index.dart';
import 'package:piliotto/pages/history/index.dart';
import 'package:piliotto/pages/mine/controller.dart';

class UserDrawer extends StatelessWidget {
  const UserDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final MineController mineController = Get.put(MineController());

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, theme, mineController),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildUserStats(theme, mineController),
                    const Divider(height: 1),
                    _buildMenuItems(context, theme, mineController),
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
      BuildContext context, ThemeData theme, MineController mineController) {
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
                onPressed: () => mineController.onChangeTheme(),
                icon: Obx(() => Icon(
                      mineController.themeType.value == ThemeType.dark
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      size: 20,
                      color: theme.colorScheme.onSecondaryContainer,
                    )),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.toNamed('/setting', preventDuplicates: false);
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
              _buildAvatar(theme, mineController, context),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                          mineController.userInfo.value.uname ?? '点击头像登录',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                          overflow: TextOverflow.ellipsis,
                        )),
                    const SizedBox(height: 4),
                    Obx(() {
                      if (mineController.userLogin.value) {
                        return Text(
                          'UID: ${mineController.userInfo.value.mid}',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSecondaryContainer
                                .withAlpha(180),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (!mineController.userLogin.value) {
              return SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Get.toNamed('/loginPage');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.onSecondaryContainer,
                    foregroundColor: theme.colorScheme.secondaryContainer,
                  ),
                  child: const Text('立即登录'),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildAvatar(
      ThemeData theme, MineController mineController, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        mineController.onLogin();
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
        child: Obx(() {
          final face = mineController.userInfo.value.face;
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
        }),
      ),
    );
  }

  Widget _buildUserStats(ThemeData theme, MineController mineController) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                theme,
                mineController.userStat.value.following?.toString() ?? '0',
                '关注',
                () => mineController.pushFollow(),
              ),
              _buildStatDivider(theme),
              _buildStatItem(
                theme,
                mineController.userStat.value.follower?.toString() ?? '0',
                '粉丝',
                () => mineController.pushFans(),
              ),
              _buildStatDivider(theme),
              _buildStatItem(
                theme,
                mineController.userStat.value.dynamicCount?.toString() ?? '0',
                '动态',
                () => mineController.pushDynamic(),
              ),
            ],
          ),
        ));
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
      BuildContext context, ThemeData theme, MineController mineController) {
    return Column(
      children: [
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
          Icons.star_outline,
          '我的收藏',
          () => Get.to(const FavPage()),
        ),
        _buildMenuItem(
          context,
          theme,
          Icons.dynamic_feed_outlined,
          '我的动态',
          () => mineController.pushDynamic(),
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
