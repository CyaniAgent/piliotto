import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:piliotto/pages/setting/widgets/select_dialog.dart';
import 'package:piliotto/plugin/pl_player/index.dart';
import 'package:piliotto/utils/global_data_cache.dart';
import 'package:piliotto/utils/storage.dart';

import 'widgets/switch_item.dart';

class PlaySetting extends StatefulWidget {
  const PlaySetting({super.key});

  @override
  State<PlaySetting> createState() => _PlaySettingState();
}

class _PlaySettingState extends State<PlaySetting> {
  late int defaultFullScreenMode;
  late int defaultBtmProgressBehavior;

  @override
  void initState() {
    super.initState();
    defaultFullScreenMode = GStrorage.setting.get(SettingBoxKey.fullScreenMode,
        defaultValue: FullScreenMode.values.first.code);
    defaultBtmProgressBehavior = GStrorage.setting.get(
        SettingBoxKey.btmProgressBehavior,
        defaultValue: BtmProgresBehavior.values.first.code);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = Theme.of(context).textTheme.titleMedium!;
    TextStyle subTitleStyle = Theme.of(context)
        .textTheme
        .labelMedium!
        .copyWith(color: Theme.of(context).colorScheme.outline);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          '播放设置',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            dense: false,
            onTap: () => context.push('/playSpeedSet'),
            title: Text('倍速设置', style: titleStyle),
            subtitle: Text('设置视频播放速度', style: subTitleStyle),
          ),
          ListTile(
            dense: false,
            onTap: () => context.push('/playerGestureSet'),
            title: Text('手势设置', style: titleStyle),
            subtitle: Text('设置播放器手势', style: subTitleStyle),
          ),
          const SetSwitchItem(
            title: '自动播放',
            subTitle: '进入详情页自动播放',
            setKey: SettingBoxKey.autoPlayEnable,
            defaultVal: true,
          ),
          const SetSwitchItem(
            title: '后台播放',
            subTitle: '进入后台时继续播放',
            setKey: SettingBoxKey.enableBackgroundPlay,
            defaultVal: false,
          ),
          if (Platform.isAndroid)
            const SetSwitchItem(
              title: '自动PiP播放',
              subTitle: '进入后台时画中画播放',
              setKey: SettingBoxKey.autoPiP,
              defaultVal: false,
            ),
          const SetSwitchItem(
            title: '自动全屏',
            subTitle: '视频开始播放时进入全屏',
            setKey: SettingBoxKey.enableAutoEnter,
            defaultVal: false,
          ),
          const SetSwitchItem(
            title: '自动退出',
            subTitle: '视频结束播放时退出全屏',
            setKey: SettingBoxKey.enableAutoExit,
            defaultVal: false,
          ),
          const SetSwitchItem(
            title: '开启硬解',
            subTitle: '以较低功耗播放视频',
            setKey: SettingBoxKey.enableHA,
            defaultVal: false,
          ),
          const SetSwitchItem(
            title: '亮度记忆',
            subTitle: '返回时自动调整视频亮度',
            setKey: SettingBoxKey.enableAutoBrightness,
            defaultVal: false,
          ),
          const SetSwitchItem(
            title: '弹幕开关',
            subTitle: '展示弹幕',
            setKey: SettingBoxKey.enableShowDanmaku,
            defaultVal: false,
          ),
          SetSwitchItem(
              title: '控制栏动画',
              subTitle: '播放器控制栏显示动画效果',
              setKey: SettingBoxKey.enablePlayerControlAnimation,
              defaultVal: true,
              callFn: (bool val) {
                GlobalDataCache().enablePlayerControlAnimation = val;
              }),
          ListTile(
            dense: false,
            title: Text('默认全屏方式', style: titleStyle),
            subtitle: Text(
              '当前全屏方式：${FullScreenModeCode.fromCode(defaultFullScreenMode)!.description}',
              style: subTitleStyle,
            ),
            onTap: () async {
              int? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<int>(
                      title: '默认全屏方式',
                      value: defaultFullScreenMode,
                      values: FullScreenMode.values.map((e) {
                        return {'title': e.description, 'value': e.code};
                      }).toList());
                },
              );
              if (result != null) {
                defaultFullScreenMode = result;
                try {
                  GStrorage.setting.put(SettingBoxKey.fullScreenMode, result);
                } catch (_) {}
                setState(() {});
              }
            },
          ),
          ListTile(
            dense: false,
            title: Text('底部进度条展示', style: titleStyle),
            subtitle: Text(
              '当前展示方式：${BtmProgresBehaviorCode.fromCode(defaultBtmProgressBehavior)!.description}',
              style: subTitleStyle,
            ),
            onTap: () async {
              int? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<int>(
                      title: '底部进度条展示',
                      value: defaultBtmProgressBehavior,
                      values: BtmProgresBehavior.values.map((e) {
                        return {'title': e.description, 'value': e.code};
                      }).toList());
                },
              );
              if (result != null) {
                defaultBtmProgressBehavior = result;
                try {
                  GStrorage.setting
                      .put(SettingBoxKey.btmProgressBehavior, result);
                } catch (_) {}
                setState(() {});
              }
            },
          ),
        ],
      ),
    );
  }
}
