import 'dart:io';

import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:piliotto/providers/repository_provider.dart';

import 'package:piliotto/pages/video/detail/introduction/widgets/menu_row.dart';
import 'package:piliotto/plugin/pl_player/index.dart';
import 'package:piliotto/plugin/pl_player/models/play_repeat.dart';
import 'package:piliotto/utils/route_arguments.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:piliotto/services/shutdown_timer_service.dart';
import 'package:piliotto/pages/video/detail/provider.dart';
import 'package:piliotto/pages/video/detail/introduction/provider.dart';

class HeaderControl extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  const HeaderControl({
    this.controller,
    this.videoDetailNotifier,
    this.floating,
    this.vid,
    this.videoType,
    this.showSubtitleBtn,
    super.key,
  });
  final PlPlayerController? controller;
  final VideoDetailNotifier? videoDetailNotifier;
  final Floating? floating;
  final int? vid;
  final String? videoType;
  final bool? showSubtitleBtn;

  @override
  ConsumerState<HeaderControl> createState() => _HeaderControlState();

  @override
  Size get preferredSize => const Size(double.infinity, kToolbarHeight);
}

class _HeaderControlState extends ConsumerState<HeaderControl> {
  static const TextStyle subTitleStyle = TextStyle(fontSize: 12);
  static const TextStyle titleStyle = TextStyle(fontSize: 14);
  Size get preferredSize => const Size(double.infinity, kToolbarHeight);
  late List<double> speedsList;
  double buttonSpace = 8;
  bool isFullScreen = false;
  late String heroTag;

  @override
  void initState() {
    super.initState();
    speedsList =
        widget.controller?.speedsList ?? [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    fullScreenStatusListener();
    heroTag = routeArguments['heroTag'] ?? '';
  }

  void fullScreenStatusListener() {
    if (widget.controller != null) {
      widget.controller!.isFullScreen.listen((bool val) {
        isFullScreen = val;
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

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
                            .withValues(alpha: 0.5),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(3))),
                  ),
                ),
              ),
              Expanded(
                  child: Material(
                child: ListView(
                  children: [
                    ListTile(
                      onTap: () =>
                          {Navigator.of(context).pop(), scheduleExit()},
                      dense: true,
                      leading:
                          const Icon(Icons.hourglass_top_outlined, size: 20),
                      title: const Text('定时关闭', style: titleStyle),
                    ),
                    ListTile(
                      onTap: () =>
                          {Navigator.of(context).pop(), showSetRepeat()},
                      dense: true,
                      leading: const Icon(Icons.repeat, size: 20),
                      title: const Text('播放顺序', style: titleStyle),
                      subtitle: Text(widget.controller!.playRepeat.description,
                          style: subTitleStyle),
                    ),
                    ListTile(
                      onTap: () =>
                          {Navigator.of(context).pop(), showSetDanmaku()},
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

  void showShootDanmakuSheet() {
    if (widget.controller == null || widget.vid == null) {
      SmartDialog.showToast('无法发送弹幕');
      return;
    }
    final TextEditingController textController = TextEditingController();
    bool isSending = false;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
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
              onPressed: () => Navigator.of(dialogContext).pop(),
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
                          isSending = true;
                        });
                        try {
                          final danmakuRepo =
                              ref.read(danmakuRepositoryProvider);
                          await danmakuRepo.sendDanmaku(
                            vid: widget.vid!,
                            text: msg,
                            time: widget.controller!.position.value.inSeconds,
                            mode: 'scroll',
                            color: 'ffffff',
                            fontSize: '25px',
                            render: '',
                          );
                          SmartDialog.showToast('发送成功');
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        } catch (e) {
                          SmartDialog.showToast('发送失败：${e.toString()}');
                        } finally {
                          setState(() {
                            isSending = false;
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
      builder: (BuildContext sheetContext) {
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
                            Navigator.of(sheetContext).pop();
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
                          activeThumbColor:
                              Theme.of(context).colorScheme.primary,
                          activeTrackColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          inactiveThumbColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          inactiveTrackColor:
                              Theme.of(context).colorScheme.surface,
                          splashRadius: 10.0,
                          value: shutdownTimerService.waitForPlayingCompleted,
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
                            },
                            text: " 暂停视频 ",
                            selectStatus: !shutdownTimerService.exitApp,
                          ),
                          const Spacer(),
                          ActionRowLineItem(
                            onTap: () {
                              shutdownTimerService.exitApp = true;
                              setState(() {});
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

  void showSetSpeedSheet() {
    if (widget.controller == null) {
      SmartDialog.showToast('无法设置播放速度');
      return;
    }
    final double currentSpeed = widget.controller!.playbackSpeed;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
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
                        await widget.controller!.setPlaybackSpeed(i);
                        if (context.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                      },
                      child: Text(i.toString()),
                    ),
                  ] else ...[
                    FilledButton.tonal(
                      onPressed: () async {
                        await widget.controller!.setPlaybackSpeed(i);
                        if (context.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
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
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                '取消',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                await widget.controller!.setDefaultSpeed();
                if (context.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('默认速度'),
            ),
          ],
        );
      },
    );
  }

  void _updateDanmakuOption() {
    if (widget.controller?.danmakuController != null) {
      final currentOption = widget.controller!.danmakuController!.option;
      final newOption = currentOption.copyWith(
        duration: widget.controller!.danmakuDurationVal /
            widget.controller!.playbackSpeed,
        opacity: widget.controller!.opacityVal,
        fontSize: 15 * widget.controller!.fontSizeVal,
        area: widget.controller!.showArea,
        strokeWidth: widget.controller!.strokeWidth,
        hideTop: widget.controller!.blockTypes.contains(5),
        hideScroll: widget.controller!.blockTypes.contains(2),
        hideBottom: widget.controller!.blockTypes.contains(4),
      );
      widget.controller!.danmakuController!.updateOption(newOption);
    }
  }

  void _saveDanmakuStatus() {
    final setting = GStrorage.setting;
    setting.put(
        SettingBoxKey.enableShowDanmaku, widget.controller!.isOpenDanmu.value);
  }

  void showSetDanmaku() async {
    if (widget.controller == null) {
      SmartDialog.showToast('无法设置弹幕');
      return;
    }
    final List<Map<String, dynamic>> blockTypesList = [
      {'value': 5, 'label': '顶部'},
      {'value': 2, 'label': '滚动'},
      {'value': 4, 'label': '底部'},
      {'value': 6, 'label': '彩色'},
    ];
    final List blockTypes = widget.controller!.blockTypes;
    final List<Map<String, dynamic>> showAreas = [
      {'value': 0.25, 'label': '1/4屏'},
      {'value': 0.5, 'label': '半屏'},
      {'value': 0.75, 'label': '3/4屏'},
      {'value': 1.0, 'label': '满屏'},
    ];
    double showArea = widget.controller!.showArea;
    double opacityVal = widget.controller!.opacityVal;
    double fontSizeVal = widget.controller!.fontSizeVal;
    double danmakuDurationVal = widget.controller!.danmakuDurationVal;
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
                              _updateDanmakuOption();
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
                              _updateDanmakuOption();
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
                          _updateDanmakuOption();
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
                          _updateDanmakuOption();
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
                          _updateDanmakuOption();
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  Text('弹幕时长 ${danmakuDurationVal.toStringAsFixed(1)} 秒'),
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
                        label: '${danmakuDurationVal.toStringAsFixed(1)}秒',
                        onChanged: (double val) {
                          danmakuDurationVal = val;
                          widget.controller!.danmakuDurationVal =
                              danmakuDurationVal;
                          _updateDanmakuOption();
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

  void showSetRepeat() async {
    if (widget.controller == null) {
      SmartDialog.showToast('无法设置播放顺序');
      return;
    }
    showModalBottomSheet(
      context: context,
      elevation: 0,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
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
                          Navigator.of(sheetContext).pop();
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
                          Navigator.of(sheetContext).pop();
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
                          Navigator.of(sheetContext).pop();
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
              icon: const FaIcon(
                FontAwesomeIcons.arrowLeft,
                size: 15,
                color: Colors.white,
              ),
              fuc: () => context.pop(),
            ),
          ],
        ),
      );
    }
    final playerController = widget.controller!;
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
            icon: const FaIcon(
              FontAwesomeIcons.arrowLeft,
              size: 15,
              color: Colors.white,
            ),
            fuc: () {
              if (widget.controller!.isFullScreen.value) {
                widget.controller!.triggerFullScreen(status: false);
              } else {
                if (MediaQuery.of(context).orientation ==
                    Orientation.landscape) {
                  SystemChrome.setPreferredOrientations(
                      [DeviceOrientation.portraitUp]);
                }
                context.pop();
              }
            },
          ),
          SizedBox(width: buttonSpace),
          if (isFullScreen && isLandscape && widget.videoType == 'video') ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Consumer(
                    builder: (context, ref, child) {
                      final introState =
                          ref.watch(videoIntroProvider(widget.vid ?? 0));
                      return Text(
                        introState.videoDetail?.title ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          ] else ...[
            ComBtn(
              icon: const FaIcon(
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
          if (isFullScreen) ...[
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
              child: Obx(() => IconButton(
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(EdgeInsets.zero),
                    ),
                    onPressed: () {
                      playerController.isOpenDanmu.value =
                          !playerController.isOpenDanmu.value;
                      _saveDanmakuStatus();
                    },
                    icon: Icon(
                      playerController.isOpenDanmu.value
                          ? Icons.subtitles_outlined
                          : Icons.subtitles_off_outlined,
                      size: 19,
                      color: Colors.white,
                    ),
                  )),
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
                  } on PlatformException {
                    canUsePiP = false;
                  }
                  if (canUsePiP && widget.floating != null) {
                    final videoState = ref.read(videoDetailProvider);
                    final videoWidth = videoState.videoItem?.videoWidth ?? 16;
                    final videoHeight = videoState.videoItem?.videoHeight ?? 9;
                    final Rational aspectRatio =
                        Rational(videoWidth, videoHeight);
                    await widget.floating!
                        .enable(ImmediatePiP(aspectRatio: aspectRatio));
                  }
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
          Obx(() => SizedBox(
                width: 45,
                height: 34,
                child: TextButton(
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(EdgeInsets.zero),
                  ),
                  onPressed: () => showSetSpeedSheet(),
                  child: Text(
                    '${playerController.playbackSpeed}X',
                    style: textStyle,
                  ),
                ),
              )),
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
