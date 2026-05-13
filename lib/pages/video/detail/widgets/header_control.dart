import 'dart:io';

import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/repositories/i_danmaku_repository.dart';

import 'package:piliotto/pages/video/detail/index.dart';
import 'package:piliotto/pages/video/detail/introduction/controller.dart';
import 'package:piliotto/pages/video/detail/introduction/widgets/menu_row.dart';
import 'package:piliotto/plugin/pl_player/index.dart';
import 'package:piliotto/plugin/pl_player/models/bottom_control_type.dart';
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

  void showSettingSheet() {
    if (widget.videoDetailCtr == null) {
      SmartDialog.showToast('无法打开设置');
      return;
    }

    final videoDetailCtr = widget.videoDetailCtr!;
    final bool isWideScreen = Get.size.width > 768;

    Widget buildNavigatorContent(BuildContext outerContext) {
      return Container(
        height: isWideScreen ? null : videoDetailCtr.sheetHeight.value,
        color: Theme.of(outerContext).colorScheme.surface,
        child: Navigator(
          initialRoute: '/',
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute(
              builder: (BuildContext pageContext) {
                return _buildPageWithAppBar(
                  routeSettings.name ?? '/',
                  pageContext,
                  onClose: () => Navigator.pop(outerContext),
                );
              },
            );
          },
        ),
      );
    }

    if (isFullScreen.value) {
      widget.controller?.pause();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: buildNavigatorContent(dialogContext),
            ),
          );
        },
      ).then((_) {
        widget.controller?.play();
      });
    } else {
      final scaffold = isWideScreen
          ? videoDetailCtr.rightContentScaffoldKey
          : videoDetailCtr.scaffoldKey;

      scaffold.currentState?.showBottomSheet((BuildContext sheetContext) {
        return buildNavigatorContent(sheetContext);
      });
    }
  }

  String _getRouteTitle(String? name) {
    switch (name) {
      case '/':
        return '播放设置';
      case '/scheduleExit':
        return '定时关闭';
      case '/repeat':
        return '播放顺序';
      case '/danmaku':
        return '弹幕设置';
      case '/bottomControl':
        return '底部按钮设置';
      default:
        return '';
    }
  }

  Widget _buildPageWithAppBar(String routeName, BuildContext pageContext,
      {VoidCallback? onClose}) {
    final title = _getRouteTitle(routeName);
    final isMainPage = routeName == '/';

    return Column(
      children: [
        AppBar(
          toolbarHeight: 45,
          automaticallyImplyLeading: false,
          centerTitle: false,
          leading: isMainPage
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back, size: 20),
                  onPressed: () => Navigator.of(pageContext).pop(),
                ),
          title: Text(
            title,
            style: Theme.of(pageContext).textTheme.titleSmall,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: onClose,
            ),
            const SizedBox(width: 14),
          ],
        ),
        Expanded(child: _buildRouteContent(routeName)),
      ],
    );
  }

  Widget _buildRouteContent(String name) {
    switch (name) {
      case '/':
        return _buildSettingsMainPage();
      case '/scheduleExit':
        return _buildScheduleExitPage();
      case '/repeat':
        return _buildRepeatPage();
      case '/danmaku':
        return _buildDanmakuPage();
      case '/bottomControl':
        return _buildBottomControlPage();
      default:
        return const SizedBox();
    }
  }

  Widget _buildSettingsMainPage() {
    return Builder(
      builder: (BuildContext navContext) {
        return Material(
          child: ListView(
            children: [
              ListTile(
                onTap: () =>
                    Navigator.of(navContext).pushNamed('/scheduleExit'),
                dense: true,
                leading: const Icon(Icons.hourglass_top_outlined, size: 20),
                title: const Text('定时关闭', style: titleStyle),
              ),
              ListTile(
                onTap: () => Navigator.of(navContext).pushNamed('/repeat'),
                dense: true,
                leading: const Icon(Icons.repeat, size: 20),
                title: const Text('播放顺序', style: titleStyle),
                subtitle: Text(widget.controller!.playRepeat.description,
                    style: subTitleStyle),
              ),
              ListTile(
                onTap: () {
                  Navigator.of(navContext).pushNamed('/danmaku').then((_) {
                    widget.controller?.cacheDanmakuOption();
                  });
                },
                dense: true,
                leading: const Icon(Icons.subtitles_outlined, size: 20),
                title: const Text('弹幕设置', style: titleStyle),
              ),
              ListTile(
                onTap: () =>
                    Navigator.of(navContext).pushNamed('/bottomControl'),
                dense: true,
                leading: const Icon(Icons.settings_outlined, size: 20),
                title: const Text('底部按钮设置', style: titleStyle),
              ),
            ],
          ),
        );
      },
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
                          await Get.find<IDanmakuRepository>().sendDanmaku(
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

  Widget _buildScheduleExitPage() {
    const List<int> scheduleTimeChoices = [
      -1,
      15,
      30,
      60,
    ];
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 30),
                const Center(child: Text('定时关闭', style: titleStyle)),
                const SizedBox(height: 10),
                for (final int choice in scheduleTimeChoices) ...<Widget>[
                  ListTile(
                    onTap: () {
                      shutdownTimerService.scheduledExitInMinutes = choice;
                      shutdownTimerService.startShutdownTimer();
                    },
                    contentPadding: const EdgeInsets.only(),
                    dense: true,
                    title: Text(choice == -1 ? "禁用" : "$choice分钟后"),
                    trailing:
                        shutdownTimerService.scheduledExitInMinutes == choice
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
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                    activeTrackColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    inactiveThumbColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    inactiveTrackColor: Theme.of(context).colorScheme.surface,
                    splashRadius: 10.0,
                    value: shutdownTimerService.waitForPlayingCompleted,
                    onChanged: (value) => setState(() =>
                        shutdownTimerService.waitForPlayingCompleted = value),
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
                const SizedBox(height: 20),
              ]),
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

  Widget _buildDanmakuPage() {
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

    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return SingleChildScrollView(
        padding: const EdgeInsets.only(left: 14, right: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('按类型屏蔽'),
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 18),
              child: Row(
                children: <Widget>[
                  for (final Map<String, dynamic> i
                      in blockTypesList) ...<Widget>[
                    ActionRowLineItem(
                      onTap: () async {
                        final bool isChoose = blockTypes.contains(i['value']);
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
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6.0),
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
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6.0),
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
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6.0),
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
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                ),
                child: Slider(
                  min: 2,
                  max: 16,
                  value: danmakuDurationVal,
                  divisions: 28,
                  label: '${danmakuDurationVal.toStringAsFixed(1)}秒',
                  onChanged: (double val) {
                    danmakuDurationVal = val;
                    widget.controller!.danmakuDurationVal = danmakuDurationVal;
                    _updateDanmakuOption();
                    setState(() {});
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }

  Widget _buildRepeatPage() {
    return ListView(
      children: <Widget>[
        ListTile(
          onTap: () {
            widget.controller!.setPlayRepeat(PlayRepeat.singleCycle);
          },
          dense: true,
          contentPadding: const EdgeInsets.only(left: 20, right: 20),
          title: const Text('单曲循环'),
          trailing: widget.controller!.playRepeat == PlayRepeat.singleCycle
              ? Icon(Icons.done, color: Theme.of(context).colorScheme.primary)
              : const SizedBox(),
        ),
        ListTile(
          onTap: () {
            widget.controller!.setPlayRepeat(PlayRepeat.listCycle);
          },
          dense: true,
          contentPadding: const EdgeInsets.only(left: 20, right: 20),
          title: const Text('列表循环'),
          trailing: widget.controller!.playRepeat == PlayRepeat.listCycle
              ? Icon(Icons.done, color: Theme.of(context).colorScheme.primary)
              : const SizedBox(),
        ),
        ListTile(
          onTap: () {
            widget.controller!.setPlayRepeat(PlayRepeat.listOrder);
          },
          dense: true,
          contentPadding: const EdgeInsets.only(left: 20, right: 20),
          title: const Text('顺序播放'),
          trailing: widget.controller!.playRepeat == PlayRepeat.listOrder
              ? Icon(Icons.done, color: Theme.of(context).colorScheme.primary)
              : const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildBottomControlPage() {
    final videoDetailCtr = widget.videoDetailCtr!;
    return _BottomControlSettingSheet(
      videoDetailCtr: videoDetailCtr,
      scrollController: ScrollController(),
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
              fuc: () {
                Get.back();
              },
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
                  } on PlatformException {
                    canUsePiP = false;
                  }
                  if (canUsePiP && widget.floating != null) {
                    final videoWidth =
                        widget.videoDetailCtr?.videoItem.videoWidth ?? 16;
                    final videoHeight =
                        widget.videoDetailCtr?.videoItem.videoHeight ?? 9;
                    final Rational aspectRatio =
                        Rational(videoWidth, videoHeight);
                    await widget.floating!
                        .enable(ImmediatePiP(aspectRatio: aspectRatio));
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
                  '${playerController.playbackSpeed}X',
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

class _BottomControlSettingSheet extends StatefulWidget {
  final VideoDetailController videoDetailCtr;
  final ScrollController scrollController;

  const _BottomControlSettingSheet({
    required this.videoDetailCtr,
    required this.scrollController,
  });

  @override
  State<_BottomControlSettingSheet> createState() =>
      _BottomControlSettingSheetState();
}

class _BottomControlSettingSheetState extends State<_BottomControlSettingSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late List<BottomControlType> _halfScreenList;
  late List<BottomControlType> _fullScreenList;

  static const List<BottomControlType> _availableButtons = [
    BottomControlType.playOrPause,
    BottomControlType.time,
    BottomControlType.space,
    BottomControlType.episode,
    BottomControlType.fit,
    BottomControlType.speed,
    BottomControlType.fullscreen,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLists();
  }

  void _loadLists() {
    _halfScreenList = List<BottomControlType>.from(
        widget.videoDetailCtr.halfScreenBottomList);
    _fullScreenList = List<BottomControlType>.from(
        widget.videoDetailCtr.fullScreenBottomList);
  }

  void _saveLists() {
    widget.videoDetailCtr.halfScreenBottomList.value =
        List<BottomControlType>.from(_halfScreenList);
    widget.videoDetailCtr.fullScreenBottomList.value =
        List<BottomControlType>.from(_fullScreenList);
    widget.videoDetailCtr.saveBottomLists();

    if (widget.videoDetailCtr.plPlayerController.isFullScreen.value) {
      widget.videoDetailCtr.switchToFullScreen();
    } else {
      widget.videoDetailCtr.switchToHalfScreen();
    }
  }

  List<BottomControlType> _getList(int tabIndex) =>
      tabIndex == 0 ? _halfScreenList : _fullScreenList;

  void _addButton(int tabIndex, BottomControlType button) {
    setState(() {
      _getList(tabIndex).add(button);
    });
    _saveLists();
  }

  void _removeButton(int tabIndex, int index) {
    final list = _getList(tabIndex);
    if (index >= 0 && index < list.length) {
      setState(() {
        list.removeAt(index);
      });
      _saveLists();
    }
  }

  void _reorderButton(int tabIndex, int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final list = _getList(tabIndex);
      if (oldIndex >= 0 && oldIndex < list.length) {
        final item = list.removeAt(oldIndex);
        list.insert(newIndex, item);
      }
    });
    _saveLists();
  }

  void _showAddButtonDialog(int tabIndex) {
    final currentList = _getList(tabIndex);
    final availableToAdd =
        _availableButtons.where((btn) => !currentList.contains(btn)).toList();

    if (availableToAdd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已添加所有可用按钮')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '添加按钮',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableToAdd.map((btn) {
                  return ActionChip(
                    label: Text(btn.description),
                    onPressed: () {
                      _addButton(tabIndex, btn);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '半屏'),
            Tab(text: '全屏'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildButtonList(0),
              _buildButtonList(1),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showAddButtonDialog(_tabController.index),
                  icon: const Icon(Icons.add),
                  label: const Text('添加按钮'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButtonList(int tabIndex) {
    final list = _getList(tabIndex);

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '暂无按钮',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
            const SizedBox(height: 8),
            Text(
              '点击下方按钮添加',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      scrollController: widget.scrollController,
      itemCount: list.length,
      onReorder: (oldIndex, newIndex) =>
          _reorderButton(tabIndex, oldIndex, newIndex),
      itemBuilder: (context, index) {
        final button = list[index];
        return ListTile(
          key: ValueKey('${tabIndex}_$index'),
          title: Text(button.description),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _removeButton(tabIndex, index),
              ),
              const Icon(Icons.drag_handle),
            ],
          ),
        );
      },
    );
  }
}
