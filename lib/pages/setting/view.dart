import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/pages/setting/index.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingController settingController = Get.put(SettingController());
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    Widget buildSettingItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
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
            () => Get.toNamed('/playSetting'),
          ),
          buildSettingItem(
            Icons.style_outlined,
            '外观设置',
            '应用主题和显示设置',
            () => Get.toNamed('/styleSetting'),
          ),
          buildSettingItem(
            Icons.more_horiz_outlined,
            '其他设置',
            '更多应用配置选项',
            () => Get.toNamed('/extraSetting'),
          ),
          Obx(
            () => Visibility(
              visible: settingController.userLogin.value,
              child: buildSettingItem(
                Icons.logout_outlined,
                '退出登录',
                '退出当前账号',
                () => settingController.loginOut(),
              ),
            ),
          ),
          buildSettingItem(
            Icons.info_outlined,
            '关于',
            '应用版本和相关信息',
            () => Get.toNamed('/about'),
          ),
        ],
      ),
    );
  }
}
