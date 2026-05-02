import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:piliotto/pages/setting/widgets/switch_item.dart';
import 'package:piliotto/plugin/pl_player/index.dart';
import 'package:piliotto/plugin/pl_player/models/play_speed.dart';
import 'package:piliotto/utils/storage.dart';

class PlaySpeedPage extends StatefulWidget {
  const PlaySpeedPage({super.key});

  @override
  State<PlaySpeedPage> createState() => _PlaySpeedPageState();
}

class _PlaySpeedPageState extends State<PlaySpeedPage> {
  late double playSpeedDefault;
  late List<double> playSpeedSystem;
  late double longPressSpeedDefault;
  late List customSpeedsList;
  late bool enableAutoLongPressSpeed;
  List<Map<dynamic, dynamic>> sheetMenu = [
    {
      'id': 1,
      'title': '设置为默认倍速',
      'leading': const Icon(
        Icons.speed,
        size: 21,
      ),
      'show': true,
    },
    {
      'id': 2,
      'title': '设置为默认长按倍速',
      'leading': const Icon(
        Icons.speed_sharp,
        size: 21,
      ),
      'show': true,
    },
    {
      'id': -1,
      'title': '删除该项',
      'leading': const Icon(
        Icons.delete_outline,
        size: 21,
      ),
      'show': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    try {
      playSpeedSystem =
          GStrorage.video.get(VideoBoxKey.playSpeedSystem, defaultValue: playSpeed);
      playSpeedDefault =
          GStrorage.video.get(VideoBoxKey.playSpeedDefault, defaultValue: 1.0);
      longPressSpeedDefault =
          GStrorage.video.get(VideoBoxKey.longPressSpeedDefault, defaultValue: 2.0);
      customSpeedsList =
          GStrorage.video.get(VideoBoxKey.customSpeedsList, defaultValue: []);
      enableAutoLongPressSpeed = GStrorage.setting
          .get(SettingBoxKey.enableAutoLongPressSpeed, defaultValue: false);
    } catch (_) {
      playSpeedSystem = playSpeed;
      playSpeedDefault = 1.0;
      longPressSpeedDefault = 2.0;
      customSpeedsList = [];
      enableAutoLongPressSpeed = false;
    }
    // 开启动态长按倍速时不展示
    if (enableAutoLongPressSpeed) {
      Map newItem = sheetMenu[1];
      newItem['show'] = false;
      setState(() {
        sheetMenu[1] = newItem;
      });
    }
  }

  // 添加自定义倍速
  void onAddSpeed() {
    double customSpeed = 1.0;
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('添加倍速'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // const Text('输入你想要的视频倍速，例如：1.0'),
              const SizedBox(height: 12),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '自定义倍速',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
                onChanged: (e) {
                  customSpeed = double.parse(e);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => SmartDialog.dismiss(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                customSpeedsList.add(customSpeed);
                try {
                  await GStrorage.video.put(
                      VideoBoxKey.customSpeedsList, customSpeedsList);
                } catch (_) {}
                setState(() {});
                SmartDialog.dismiss();
              },
              child: const Text('确认添加'),
            )
          ],
        );
      },
    );
  }

  // 设定倍速弹窗
  void showBottomSheet(String type, int i) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.only(top: 10),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            //重要
            itemCount: sheetMenu.length,
            itemBuilder: (BuildContext context, int index) {
              return sheetMenu[index]['show']
                  ? ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        menuAction(type, i, sheetMenu[index]['id']);
                      },
                      minLeadingWidth: 0,
                      iconColor: Theme.of(context).colorScheme.onSurface,
                      leading: sheetMenu[index]['leading'],
                      title: Text(
                        sheetMenu[index]['title'],
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    )
                  : const SizedBox();
            },
          ),
        );
      },
    );
  }

  void menuAction(String type, int index, int id) async {
    double chooseSpeed = 1.0;
    chooseSpeed =
        type == 'system' ? playSpeedSystem[index] : customSpeedsList[index];
    if (id == 1) {
      playSpeedDefault = chooseSpeed;
      try {
        GStrorage.video.put(VideoBoxKey.playSpeedDefault, playSpeedDefault);
      } catch (_) {}
    } else if (id == 2) {
      longPressSpeedDefault = chooseSpeed;
      try {
        GStrorage.video.put(
            VideoBoxKey.longPressSpeedDefault, longPressSpeedDefault);
      } catch (_) {}
    } else if (id == -1) {
      late List speedsList =
          type == 'system' ? playSpeedSystem : customSpeedsList;
      if (speedsList[index] == playSpeedDefault) {
        SmartDialog.showToast('默认倍速不可删除');
      }
      if (speedsList[index] == longPressSpeedDefault) {
        longPressSpeedDefault = 2.0;
        try {
          GStrorage.video.put(
              VideoBoxKey.longPressSpeedDefault, longPressSpeedDefault);
        } catch (_) {}
      }
      speedsList.removeAt(index);
      try {
        await GStrorage.video.put(
            type == 'system'
                ? VideoBoxKey.playSpeedSystem
                : VideoBoxKey.customSpeedsList,
            speedsList);
      } catch (_) {}
    }
    setState(() {});
    SmartDialog.showToast('操作成功');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        centerTitle: false,
        title: Text(
          '倍速设置',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 14, right: 14, top: 6, bottom: 0),
              child: Text(
                '点击下方按钮设置默认（长按）倍速',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            ListTile(
              dense: false,
              title: const Text('默认倍速'),
              subtitle: Text(playSpeedDefault.toString()),
            ),
            SetSwitchItem(
              title: '动态长按倍速',
              subTitle: '根据默认倍速长按时自动双倍',
              setKey: SettingBoxKey.enableAutoLongPressSpeed,
              defaultVal: enableAutoLongPressSpeed,
              callFn: (val) {
                Map newItem = sheetMenu[1];
                val ? newItem['show'] = false : newItem['show'] = true;
                setState(() {
                  sheetMenu[1] = newItem;
                  enableAutoLongPressSpeed = val;
                });
              },
            ),
            !enableAutoLongPressSpeed
                ? ListTile(
                    dense: false,
                    title: const Text('默认长按倍速'),
                    subtitle: Text(longPressSpeedDefault.toString()),
                  )
                : const SizedBox(),
            if (playSpeedSystem.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(
                  left: 14,
                  right: 14,
                  bottom: 10,
                  top: 20,
                ),
                child: Text(
                  '系统预设倍速',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 18,
                  right: 18,
                  bottom: 30,
                ),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 8,
                  runSpacing: 2,
                  children: [
                    for (int i = 0; i < playSpeedSystem.length; i++) ...[
                      FilledButton.tonal(
                        onPressed: () => showBottomSheet('system', i),
                        child: Text(playSpeedSystem[i].toString()),
                      ),
                    ]
                  ],
                ),
              )
            ],
            Padding(
                padding: const EdgeInsets.only(
                  left: 14,
                  right: 14,
                ),
                child: Row(
                  children: [
                    Text(
                      '自定义倍速',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () => onAddSpeed(),
                      child: const Text('添加'),
                    )
                  ],
                )),
            Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                bottom: MediaQuery.of(context).padding.bottom + 40,
              ),
              child: customSpeedsList.isNotEmpty
                  ? Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 8,
                      runSpacing: 2,
                      children: [
                        for (int i = 0; i < customSpeedsList.length; i++) ...[
                          FilledButton.tonal(
                            onPressed: () => showBottomSheet('custom', i),
                            child: Text(customSpeedsList[i].toString()),
                          ),
                        ]
                      ],
                    )
                  : SizedBox(
                      height: 80,
                      child: Center(
                        child: Text(
                          '未添加',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.outline),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
