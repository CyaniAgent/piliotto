import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:piliotto/pages/setting/provider.dart';

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingState = ref.watch(settingProvider);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    Widget buildSettingItem(
        IconData icon, String title, String subtitle, VoidCallback onTap) {
      return ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          size: 24,
          color: colorScheme.primary,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 16,
        title: Text(
          '设置',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: ListView(
        children: [
          buildSettingItem(
            Icons.play_arrow_outlined,
            '播放设置',
            '视频播放相关配置',
            () => context.push('/playSetting'),
          ),
          buildSettingItem(
            Icons.style_outlined,
            '外观设置',
            '应用主题和显示设置',
            () => context.push('/styleSetting'),
          ),
          buildSettingItem(
            Icons.more_horiz_outlined,
            '其他设置',
            '更多应用配置选项',
            () => context.push('/extraSetting'),
          ),
          Visibility(
            visible: settingState.userLogin,
            child: buildSettingItem(
              Icons.logout_outlined,
              '退出登录',
              '退出当前账号',
              () => ref.read(settingProvider.notifier).loginOut(context),
            ),
          ),
          buildSettingItem(
            Icons.info_outlined,
            '关于',
            '应用版本和相关信息',
            () => context.push('/about'),
          ),
        ],
      ),
    );
  }
}
