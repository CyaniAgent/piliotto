import 'dart:io';

import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/services/ottohub_service.dart';

import 'package:piliotto/pages/dlna/index.dart';
import 'package:piliotto/pages/video/detail/index.dart';
import 'package:piliotto/pages/video/detail/introduction/controller.dart';
import 'package:piliotto/pages/video/detail/introduction/widgets/menu_row.dart';
import 'package:piliotto/plugin/pl_player/index.dart';
import 'package:piliotto/plugin/pl_player/models/play_repeat.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:piliotto/services/shutdown_timer_service.dart';

class HeaderControl extends StatefulWidget implements PreferredSizeWidget {
  const HeaderControl({
    this.controller,
    this.videoDetailCtr,
    this.floating,
    this.vid,
    this.videoType,
    this.showSubtitleBtn,
    super.key,
  });
  final PlPlayerController? controller;
  final VideoDetailController? videoDetailCtr;
  final Floating? floating;
  final int? vid;
  final String? videoType;
  final bool? showSubtitleBtn;

  @override
  State<HeaderControl> createState() => _HeaderControlState();

  @override
  Size get preferredSize => const Size(double.infinity, kToolbarHeight);
}

class _HeaderControlState extends State<HeaderControl> {
  static const TextStyle subTitleStyle = TextStyle(fontSize: 12);
  static const TextStyle titleStyle = TextStyle(fontSize: 14);
  Size get preferredSize => const Size(double.infinity, kToolbarHeight);
  final Box<dynamic> localCache = GStrorage.localCache;
  final Box<dynamic> videoStorage = GStrorage.video;
  late List<double> speedsList;
  double buttonSpace = 8;
  RxBool isFullScreen = false.obs;
  late String heroTag;
  VideoIntroController? videoIntroController;

  @override
  void initState() {
    super.initState();
    speedsList =
        widget.controller?.speedsList ?? [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    fullScreenStatusListener();
    heroTag = Get.arguments?['heroTag'] ?? '';
    if (widget.vid != null) {
      videoIntroController =
          Get.put(VideoIntroController(vid: widget.vid!), tag: heroTag);
    }
  }

  void fullScreenStatusListener() {
    if (widget.videoDetailCtr?.plPlayerController != null) {
      widget.videoDetailCtr!.plPlayerController.isFullScreen.listen((bool val) {
        isFullScreen.value = val;
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  /// 设置面板
  void showSettingSheet() {
    showModalBottomSheet(
      elevation: 0,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          width: double.infinity,
          height: 460,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          margin: const EdgeInsets.all(12),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 35,
                child: Center(
                  child: Container(
                    width: 32,
                    height: 3,
                    decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondaryContainer
                            .withValues(alpha: 0.5 * 255),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(3))),
                  ),
                ),
              ),
              Expanded(
                  child: Material(
                child: ListView(
                  children: [
                    // ListTile(
                    //   onTap: () {},
                    //   dense: true,
                    //   enabled: false,
                    //   leading:
                    //       const Icon(Icons.network_cell_outlined, size: 20),
                    //   title: Text('省流模式', style: titleStyle),
                    //   subtitle: Text('低画质 ｜ 减少视频缓存', style: subTitleStyle),
                    //   trailing: Transform.scale(
                    //     scale: 0.75,
                    //     child: Switch(
                    //       thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                    //           (Set<MaterialState> states) {
                    //         if (states.isNotEmpty &&
                    //             states.first == MaterialState.selected) {
                    //           return const Icon(Icons.done);
                    //         }
                    //         return null; // All other states will use the default thumbIcon.
                    //       }),
                    //       value: false,
                    //       onChanged: (value) => {},
                    //     ),
                    //   ),
                    // ),
                    ListTile(
                      onTap: () => {Get.back(), scheduleExit()},
                      dense: true,
                      leading:
                          const Icon(Icons.hourglass_top_outlined, size: 20),
                      title: const Text('定时关闭', style: titleStyle),
                    ),

                    ListTile(
                      onTap: () => {Get.back(), showSetRepeat()},
                      dense: true,
                      leading: const Icon(Icons.repeat, size: 20),
                      title: const Text('播放顺序', style: titleStyle),
                      subtitle: Text(widget.controller!.playRepeat.description,
                          style: subTitleStyle),
                    ),
                    ListTile(
                      onTap: () => {Get.back(), showSetDanmaku()},
                      dense: true,
                      leading: const Icon(Icons.subtitles_outlined, size: 20),
                      title: const Text('弹幕设置', style: titleStyle),
                    ),
                  ],
                ),
              ))
            ],
          ),
        );
      },
      clipBehavior: Clip.hardEdge,
      isScrollControlled: true,
    );
  }

  /// 发送弹幕
  void showShootDanmakuSheet() {
    if (widget.controller == null || widget.vid == null) {
      SmartDialog.showToast('无法发送弹幕');
      return;
    }
    final TextEditingController textController = TextEditingController();
    bool isSending = false; // 追踪是否正在发送
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('发送弹幕'),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return TextField(
              controller: textController,
            );
          }),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                '取消',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return TextButton(
                onPressed: isSending
                    ? null
                    : () async {
                        final String msg = textController.text;
                        if (msg.isEmpty) {
                          SmartDialog.showToast('弹幕内容不能为空');
                          return;
                        } else if (msg.length > 100) {
                          SmartDialog.showToast('弹幕内容不能超过100个字符');
                          return;
                        }
                        setState(() {
                          isSending = true; // 开始发送，更新状态
                        });
                        try {
                          await OttohubService.sendDanmaku(
                            vid: widget.vid!,
                            text: msg,
                            time: widget.controller!.position.value.inSeconds,
                            mode: 'scroll',
                            color: 'ffffff',
                            fontSize: '25px',
                            render: '',
                          );
                          SmartDialog.showToast('发送成功');
                          Get.back();
                        } catch (e) {
                          SmartDialog.showToast('发送失败：${e.toString()}');
                        } finally {
                          setState(() {
                            isSending = false; // 发送结束，更新状态
                          });
                        }
                      },
                child: Text(isSending ? '发送中...' : '发送'),
              );
            })
          ],
        );
      },
    );
  }

  /// 定时关闭
  void scheduleExit() async {
    const List<int> scheduleTimeChoices = [
      -1,
      15,
      30,
      60,
    ];
    showModalBottomSheet(
      context: context,
      elevation: 0,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            width: double.infinity,
            height: 500,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.only(left: 14, right: 14),
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 30),
                      const Center(child: Text('定时关闭', style: titleStyle)),
                      const SizedBox(height: 10),
                      for (final int choice in scheduleTimeChoices) ...<Widget>[
                        ListTile(
                          onTap: () {
                            shutdownTimerService.scheduledExitInMinutes =
                                choice;
                            shutdownTimerService.startShutdownTimer();
                            Get.back();
                          },
                          contentPadding: const EdgeInsets.only(),
                          dense: true,
                          title: Text(choice == -1 ? "禁用" : "$choice分钟后"),
                          trailing: shutdownTimerService
                                      .scheduledExitInMinutes ==
                                  choice
                              ? Icon(
                                  Icons.done,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : const SizedBox(),
                        )
                      ],
                      const SizedBox(height: 6),
                      const Center(
                          child: SizedBox(
                        width: 100,
                        child: Divider(height: 1),
                      )),
                      const SizedBox(height: 10),
                      ListTile(
                        onTap: () {
                          shutdownTimerService.waitForPlayingCompleted =
                              !shutdownTimerService.waitForPlayingCompleted;
                          setState(() {});
                        },
                        dense: true,
                        contentPadding: const EdgeInsets.only(),
                        title: const Text("额外等待视频播放完毕", style: titleStyle),
                        trailing: Switch(
                          // thumb color (round icon)
                          activeThumbColor:
                              Theme.of(context).colorScheme.primary,
                          activeTrackColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          inactiveThumbColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          inactiveTrackColor:
                              Theme.of(context).colorScheme.surface,
                          splashRadius: 10.0,
                          // boolean variable value
                          value: shutdownTimerService.waitForPlayingCompleted,
                          // changes the state of the switch
                          onChanged: (value) => setState(() =>
                              shutdownTimerService.waitForPlayingCompleted =
                                  value),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          const Text('倒计时结束:', style: titleStyle),
                          const Spacer(),
                          ActionRowLineItem(
                            onTap: () {
                              shutdownTimerService.exitApp = false;
                              setState(() {});
                              // Get.back();
                            },
                            text: " 暂停视频 ",
                            selectStatus: !shutdownTimerService.exitApp,
                          ),
                          const Spacer(),
                          // const SizedBox(width: 10),
                          ActionRowLineItem(
                            onTap: () {
                              shutdownTimerService.exitApp = true;
                              setState(() {});
                              // Get.back();
                            },
                            text: " 退出APP ",
                            selectStatus: shutdownTimerService.exitApp,
                          )
                        ],
                      ),
                    ]),
              ),
            ),
          );
        });
      },
    );
  }

  /// 选择字幕
  void showSubtitleDialog() async {
    if (widget.controller == null || widget.videoDetailCtr == null) {
      SmartDialog.showToast('无法设置字幕');
      return;
    }
    int tempThemeValue = widget.controller!.subTitleCode.value;
    final List subtitles = widget.videoDetailCtr!.subtitles;
    int len = subtitles.length;
    if (subtitles.firstWhereOrNull((element) => element.id == tempThemeValue) ==
        null) {
      tempThemeValue = -1;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('选择字幕'),
            contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 18),
            content: StatefulBuilder(
              builder: (context, StateSetter setState) {
                return len == 0
                    ? const SizedBox(
                        height: 60,
                        child: Center(
                          child: Text('没有字幕'),
                        ),
                      )
                    : SingleChildScrollView(
                        child: RadioGroup<int>(
                          groupValue: tempThemeValue,
                          onChanged: (int? value) {
                            if (value != null) {
                              tempThemeValue = value;
                              widget.controller?.toggleSubtitle(value);
                              Get.back();
                            }
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const RadioListTile<int>(
                                value: -1,
                                title: Text('关闭字幕'),
                              ),
                              ...widget.videoDetailCtr!.subtitles
                                  .map((e) => RadioListTile<int>(
                                        value: e.id,
                                        title: Text(e.title),
                                      ))
                                  .toList(),
                            ],
                          ),
                        ),
                      );
              },
            ),
          );
        });
  }

  /// 选择倍速
  void showSetSpeedSheet() {
    if (widget.controller == null) {
      SmartDialog.showToast('无法设置播放速度');
      return;
    }
    final double currentSpeed = widget.controller!.playbackSpeed;
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('播放速度'),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Wrap(
              spacing: 8,
              runSpacing: 2,
              children: [
                for (final double i in speedsList) ...<Widget>[
                  if (i == currentSpeed) ...<Widget>[
                    FilledButton(
                      onPressed: () async {
                        // setState(() => currentSpeed = i),
                        await widget.controller!.setPlaybackSpeed(i);
                        Get.back();
                      },
                      child: Text(i.toString()),
                    ),
                  ] else ...[
                    FilledButton.tonal(
                      onPressed: () async {
                        // setState(() => currentSpeed = i),
                        await widget.controller!.setPlaybackSpeed(i);
                        Get.back();
                      },
                      child: Text(i.toString()),
                    ),
                  ]
                ]
              ],
            );
          }),
          actions: <Widget>[
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                '取消',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                await widget.controller!.setDefaultSpeed();
                Get.back();
              },
              child: const Text('默认速度'),
            ),
          ],
        );
      },
    );
  }

  /// 弹幕功能
  void showSetDanmaku() async {
    if (widget.controller == null) {
      SmartDialog.showToast('无法设置弹幕');
      return;
    }
    // 屏蔽类型
    final List<Map<String, dynamic>> blockTypesList = [
      {'value': 5, 'label': '顶部'},
      {'value': 2, 'label': '滚动'},
      {'value': 4, 'label': '底部'},
      {'value': 6, 'label': '彩色'},
    ];
    final List blockTypes = widget.controller!.blockTypes;
    // 显示区域
    final List<Map<String, dynamic>> showAreas = [
      {'value': 0.25, 'label': '1/4屏'},
      {'value': 0.5, 'label': '半屏'},
      {'value': 0.75, 'label': '3/4屏'},
      {'value': 1.0, 'label': '满屏'},
    ];
    double showArea = widget.controller!.showArea;
    // 不透明度
    double opacityVal = widget.controller!.opacityVal;
    // 字体大小
    double fontSizeVal = widget.controller!.fontSizeVal;
    // 弹幕速度
    double danmakuDurationVal = widget.controller!.danmakuDurationVal;
    // 弹幕描边
    double strokeWidth = widget.controller!.strokeWidth;

    await showModalBottomSheet(
      context: context,
      elevation: 0,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            width: double.infinity,
            height: 580,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.only(left: 14, right: 14),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 45,
                    child: Center(child: Text('弹幕设置', style: titleStyle)),
                  ),
                  const SizedBox(height: 10),
                  const Text('按类型屏蔽'),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 18),
                    child: Row(
                      children: <Widget>[
                        for (final Map<String, dynamic> i
                            in blockTypesList) ...<Widget>[
                          ActionRowLineItem(
                            onTap: () async {
                              final bool isChoose =
                                  blockTypes.contains(i['value']);
                              if (isChoose) {
                                blockTypes.remove(i['value']);
                              } else {
                                blockTypes.add(i['value']);
                              }
                              widget.controller!.blockTypes = blockTypes;
                              setState(() {});
                            },
                            text: i['label'],
                            selectStatus: blockTypes.contains(i['value']),
                          ),
                          const SizedBox(width: 10),
                        ]
                      ],
                    ),
                  ),
                  const Text('显示区域'),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 18),
                    child: Row(
                      children: [
                        for (final Map<String, dynamic> i in showAreas) ...[
                          ActionRowLineItem(
                            onTap: () {
                              showArea = i['value'];
                              widget.controller!.showArea = showArea;
                              setState(() {});
                            },
                            text: i['label'],
                            selectStatus: showArea == i['value'],
                          ),
                          const SizedBox(width: 10),
                        ]
                      ],
                    ),
                  ),
                  Text('不透明度 ${opacityVal * 100}%'),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 0,
                      bottom: 6,
                      left: 10,
                      right: 10,
                    ),
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackShape: MSliderTrackShape(),
                        thumbColor: Theme.of(context).colorScheme.primary,
                        activeTrackColor: Theme.of(context).colorScheme.primary,
                        trackHeight: 10,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6.0),
                      ),
                      child: Slider(
                        min: 0,
                        max: 1,
                        value: opacityVal,
                        divisions: 10,
                        label: '${opacityVal * 100}%',
                        onChanged: (double val) {
                          opacityVal = val;
                          widget.controller!.opacityVal = opacityVal;
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  Text('描边粗细 $strokeWidth'),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 0,
                      bottom: 6,
                      left: 10,
                      right: 10,
                    ),
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackShape: MSliderTrackShape(),
                        thumbColor: Theme.of(context).colorScheme.primary,
                        activeTrackColor: Theme.of(context).colorScheme.primary,
                        trackHeight: 10,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6.0),
                      ),
                      child: Slider(
                        min: 0,
                        max: 3,
                        value: strokeWidth,
                        divisions: 6,
                        label: '$strokeWidth',
                        onChanged: (double val) {
                          strokeWidth = val;
                          widget.controller!.strokeWidth = val;
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  Text('字体大小 ${(fontSizeVal * 100).toStringAsFixed(1)}%'),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 0,
                      bottom: 6,
                      left: 10,
                      right: 10,
                    ),
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackShape: MSliderTrackShape(),
                        thumbColor: Theme.of(context).colorScheme.primary,
                        activeTrackColor: Theme.of(context).colorScheme.primary,
                        trackHeight: 10,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6.0),
                      ),
                      child: Slider(
                        min: 0.5,
                        max: 2.5,
                        value: fontSizeVal,
                        divisions: 20,
                        label: '${(fontSizeVal * 100).toStringAsFixed(1)}%',
                        onChanged: (double val) {
                          fontSizeVal = val;
                          widget.controller!.fontSizeVal = fontSizeVal;
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  Text('弹幕时长 ${danmakuDurationVal.toString()} 秒'),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 0,
                      bottom: 6,
                      left: 10,
                      right: 10,
                    ),
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackShape: MSliderTrackShape(),
                        thumbColor: Theme.of(context).colorScheme.primary,
                        activeTrackColor: Theme.of(context).colorScheme.primary,
                        trackHeight: 10,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6.0),
                      ),
                      child: Slider(
                        min: 2,
                        max: 16,
                        value: danmakuDurationVal,
                        divisions: 28,
                        label: danmakuDurationVal.toString(),
                        onChanged: (double val) {
                          danmakuDurationVal = val;
                          widget.controller!.danmakuDurationVal =
                              danmakuDurationVal;
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    ).then((value) {
      widget.controller!.cacheDanmakuOption();
    });
  }

  /// 播放顺序
  void showSetRepeat() async {
    if (widget.controller == null) {
      SmartDialog.showToast('无法设置播放顺序');
      return;
    }
    showModalBottomSheet(
      context: context,
      elevation: 0,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          height: 250,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          margin: const EdgeInsets.all(12),
          child: Column(
            children: [
              const SizedBox(
                height: 45,
                child: Center(
                  child: Text('选择播放顺序', style: titleStyle),
                ),
              ),
              Expanded(
                child: Material(
                  child: ListView(
                    children: <Widget>[
                      ListTile(
                        onTap: () {
                          widget.controller!
                              .setPlayRepeat(PlayRepeat.singleCycle);
                          Get.back();
                        },
                        dense: true,
                        contentPadding:
                            const EdgeInsets.only(left: 20, right: 20),
                        title: const Text('单曲循环'),
                        trailing: widget.controller!.playRepeat ==
                                PlayRepeat.singleCycle
                            ? Icon(
                                Icons.done,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : const SizedBox(),
                      ),
                      ListTile(
                        onTap: () {
                          widget.controller!
                              .setPlayRepeat(PlayRepeat.listCycle);
                          Get.back();
                        },
                        dense: true,
                        contentPadding:
                            const EdgeInsets.only(left: 20, right: 20),
                        title: const Text('列表循环'),
                        trailing: widget.controller!.playRepeat ==
                                PlayRepeat.listCycle
                            ? Icon(
                                Icons.done,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : const SizedBox(),
                      ),
                      ListTile(
                        onTap: () {
                          widget.controller!
                              .setPlayRepeat(PlayRepeat.listOrder);
                          Get.back();
                        },
                        dense: true,
                        contentPadding:
                            const EdgeInsets.only(left: 20, right: 20),
                        title: const Text('顺序播放'),
                        trailing: widget.controller!.playRepeat ==
                                PlayRepeat.listOrder
                            ? Icon(
                                Icons.done,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : const SizedBox(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller == null) {
      return AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        primary: false,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            ComBtn(
              icon: const Icon(
                FontAwesomeIcons.arrowLeft,
                size: 15,
                color: Colors.white,
              ),
              fuc: () {
                Get.back();
              },
            ),
          ],
        ),
      );
    }
    final _ = widget.controller!;
    const TextStyle textStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
    );
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      primary: false,
      centerTitle: false,
      automaticallyImplyLeading: false,
      titleSpacing: 14,
      title: Row(
        children: [
          ComBtn(
            icon: const Icon(
              FontAwesomeIcons.arrowLeft,
              size: 15,
              color: Colors.white,
            ),
            fuc: () => <Set<void>>{
              if (widget.controller!.isFullScreen.value)
                <void>{widget.controller!.triggerFullScreen(status: false)}
              else
                <void>{
                  if (MediaQuery.of(context).orientation ==
                      Orientation.landscape)
                    {
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                      ])
                    },
                  Get.back()
                }
            },
          ),
          SizedBox(width: buttonSpace),
          if (isFullScreen.value &&
              isLandscape &&
              widget.videoType == 'video') ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Obx(
                    () => Text(
                      videoIntroController?.videoDetail.value.title ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ] else ...[
            ComBtn(
              icon: const Icon(
                FontAwesomeIcons.house,
                size: 15,
                color: Colors.white,
              ),
              fuc: () async {
                await widget.controller!.dispose();
                if (context.mounted) {
                  Navigator.popUntil(
                      context, (Route<dynamic> route) => route.isFirst);
                }
              },
            ),
          ],
          const Spacer(),
          // ComBtn(
          //   icon: const Icon(
          //     FontAwesomeIcons.cropSimple,
          //     size: 15,
          //     color: Colors.white,
          //   ),
          //   fuc: () => _.screenshot(),
          // ),
          ComBtn(
            icon: const Icon(
              Icons.cast,
              size: 19,
              color: Colors.white,
            ),
            fuc: () async {
              showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return LiveDlnaPage(
                      datasource: widget.videoDetailCtr?.videoUrl ?? '');
                },
              );
            },
          ),
          if (isFullScreen.value) ...[
            SizedBox(
              width: 56,
              height: 34,
              child: TextButton(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                ),
                onPressed: () => showShootDanmakuSheet(),
                child: const Text(
                  '发弹幕',
                  style: textStyle,
                ),
              ),
            ),
            SizedBox(
              width: 34,
              height: 34,
              child: Obx(
                () => IconButton(
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(EdgeInsets.zero),
                  ),
                  onPressed: () {
                    _.isOpenDanmu.value = !_.isOpenDanmu.value;
                  },
                  icon: Icon(
                    _.isOpenDanmu.value
                        ? Icons.subtitles_outlined
                        : Icons.subtitles_off_outlined,
                    size: 19,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
          SizedBox(width: buttonSpace),
          if (Platform.isAndroid) ...<Widget>[
            SizedBox(
              width: 34,
              height: 34,
              child: IconButton(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                ),
                onPressed: () async {
                  bool canUsePiP = false;
                  widget.controller!.hiddenControls(false);
                  try {
                    canUsePiP = await widget.floating?.isPipAvailable ?? false;
                  } on PlatformException catch (_) {
                    canUsePiP = false;
                  }
                  if (canUsePiP && widget.floating != null) {
                    const Rational aspectRatio = Rational(16, 9);//TODO: 从视频详情中获取视频比例
                    await widget.floating!.enable(const ImmediatePiP(aspectRatio: aspectRatio));
                  } else {}
                },
                icon: const Icon(
                  Icons.picture_in_picture_outlined,
                  size: 19,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: buttonSpace),
          ],

          /// 字幕
          if (widget.showSubtitleBtn ?? true)
            ComBtn(
              icon: const Icon(
                Icons.closed_caption_off,
                size: 22,
                color: Colors.white,
              ),
              fuc: () => showSubtitleDialog(),
            ),
          SizedBox(width: buttonSpace),
          Obx(
            () => SizedBox(
              width: 45,
              height: 34,
              child: TextButton(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                ),
                onPressed: () => showSetSpeedSheet(),
                child: Text(
                  '${_.playbackSpeed}X',
                  style: textStyle,
                ),
              ),
            ),
          ),
          SizedBox(width: buttonSpace),
          ComBtn(
            icon: const Icon(
              Icons.more_vert_outlined,
              size: 18,
              color: Colors.white,
            ),
            fuc: () => showSettingSheet(),
          ),
        ],
      ),
    );
  }
}

class MSliderTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    SliderThemeData? sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    const double trackHeight = 3;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2 + 4;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
