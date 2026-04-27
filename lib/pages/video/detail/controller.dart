import 'dart:async';
import 'dart:io';
import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/repositories/i_video_repository.dart';
import 'package:piliotto/repositories/i_danmaku_repository.dart';

import 'package:piliotto/models/video/reply/item.dart';
import 'package:piliotto/models/common/reply_type.dart';
import 'package:piliotto/pages/video/detail/reply_reply/view.dart';
import 'package:piliotto/plugin/pl_player/index.dart';
import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:piliotto/services/loggeer.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../../api/models/video.dart';
import '../../../plugin/pl_player/models/bottom_control_type.dart';
import 'widgets/header_control.dart';

class VideoDetailController extends GetxController
    with GetSingleTickerProviderStateMixin {
  /// 路由传参
  int vid = int.tryParse(
          Get.parameters['vid'] ?? Get.arguments?['vid']?.toString() ?? '0') ??
      0;
  String heroTag = Get.arguments?['heroTag'] ?? '';
  // 视频详情
  late Video videoItem;
  // 视频类型 默认投稿视频
  String videoType = Get.arguments?['videoType'] ?? 'video';

  /// tabs相关配置
  late TabController tabCtr;
  RxList<String> tabs = <String>['简介', '评论'].obs;

  // 请求状态
  RxBool isLoading = false.obs;

  // 是否开始自动播放 存在多p的情况下，第二p需要为true
  RxBool autoPlay = true.obs;
  // 视频资源是否有效
  RxBool isEffective = true.obs;
  // 封面图的展示
  RxBool isShowCover = true.obs;

  /// 本地存储
  Box userInfoCache = GStrorage.userInfo;
  Box localCache = GStrorage.localCache;
  Box setting = GStrorage.setting;

  // 评论id 请求楼中楼评论使用
  int fRpid = 0;

  ReplyItemModel? firstFloor;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  // 宽屏模式下右侧内容区域的Scaffold key
  final GlobalKey<ScaffoldState> rightContentScaffoldKey =
      GlobalKey<ScaffoldState>();
  RxString bgCover = ''.obs;
  RxString cover = ''.obs;
  late PlPlayerController plPlayerController;

  final IVideoRepository _videoRepo = Get.find<IVideoRepository>();
  final IDanmakuRepository _danmakuRepo = Get.find<IDanmakuRepository>();

  late String videoUrl;
  late Duration defaultST;
  // 亮度
  double? brightness;
  // 默认记录历史记录
  bool enableHeart = true;
  dynamic userInfo;
  late bool isFirstTime = true;
  Floating? floating;
  late PreferredSizeWidget headerControl;
  // 回复底部面板控制器
  PersistentBottomSheetController? replyReplyBottomSheetCtr;

  late bool enableRelatedVideo;
  RxList<BottomControlType> bottomList = [
    BottomControlType.playOrPause,
    BottomControlType.time,
    BottomControlType.space,
    BottomControlType.fit,
    BottomControlType.fullscreen,
  ].obs;
  RxDouble sheetHeight = 0.0.obs;
  ScrollController? replyScrollController;

  // 弹幕数量
  final RxInt _danmakuCount = 0.obs;
  int get danmakuCount => _danmakuCount.value;

  @override
  void onInit() {
    super.onInit();
    // 创建独立的播放器实例
    plPlayerController = PlPlayerController();

    final Map argMap = Get.arguments;
    userInfo = userInfoCache.get('userInfoCache');
    if (argMap.containsKey('videoItem')) {
      var args = argMap['videoItem'];
      updateCover(args.pic);
    } else if (argMap.containsKey('pic')) {
      updateCover(argMap['pic']);
    }

    tabCtr = TabController(length: 2, vsync: this);
    autoPlay.value =
        setting.get(SettingBoxKey.autoPlayEnable, defaultValue: true);
    enableRelatedVideo =
        setting.get(SettingBoxKey.enableRelatedVideo, defaultValue: true);
    if (userInfo == null ||
        localCache.get(LocalCacheKey.historyPause) == true) {
      enableHeart = false;
    }

    ///
    if (Platform.isAndroid) {
      floating = Floating();
    }

    getVideoDetail();
    headerControl = HeaderControl(
      controller: plPlayerController,
      videoDetailCtr: this,
      floating: floating,
      vid: vid,
      videoType: videoType,
    );

    tabCtr.addListener(() {});
  }

  void showReplyReplyPanel(int oid, int fRpid, dynamic firstFloor, dynamic currentReply, bool loadMore) {
    // 判断是否为宽屏模式
    final bool isWideScreen = Get.size.width > 768;
    // 宽屏模式使用右侧内容区域的 Scaffold，窄屏使用主 Scaffold
    final scaffold = isWideScreen ? rightContentScaffoldKey : scaffoldKey;

    replyReplyBottomSheetCtr =
        scaffold.currentState?.showBottomSheet((BuildContext context) {
      return VideoReplyReplyPanel(
        vid: oid,
        parentVcid: fRpid,
        closePanel: () => {
          fRpid = 0,
        },
        firstFloor: firstFloor,
        replyType: ReplyType.video,
        source: 'videoDetail',
        sheetHeight: isWideScreen ? null : sheetHeight.value,
        currentReply: currentReply,
        loadMore: loadMore,
      );
    });
    replyReplyBottomSheetCtr?.closed.then((value) {
      fRpid = 0;
    });
  }

  // 获取视频详情
  Future getVideoDetail() async {
    isLoading.value = true;
    final logger = getLogger();
    logger.d('开始获取视频详情，vid: $vid');
    try {
      logger.d('调用 OttohubVideoRepository.getVideoDetail($vid)');
      videoItem = await _videoRepo.getVideoDetail(vid);
      logger.d('获取视频详情成功: ${videoItem.title}');
      updateCover(videoItem.coverUrl);
      videoUrl = videoItem.videoUrl ?? '';
      logger.d('生成视频URL: $videoUrl');

      // 检查视频URL是否有效
      if (videoUrl.isEmpty) {
        logger.e('视频URL为空，视频无效');
        isEffective.value = false;
        SmartDialog.showToast('视频URL无效');
        return;
      }

      defaultST = Duration.zero;
      if (autoPlay.value) {
        logger.d('开始初始化播放器');
        await playerInit();
        logger.d('播放器初始化成功');
        isShowCover.value = false;
      }
    } catch (e) {
      logger.e('获取视频详情失败：${e.toString()}');
      SmartDialog.showToast('获取视频详情失败：${e.toString()}');
      isEffective.value = false;
    } finally {
      isLoading.value = false;
      logger.d('视频详情获取完成');
    }
  }

  Future<void> playerInit({
    String? video,
    Duration? seekToTime,
    Duration? duration,
    bool? autoplay,
  }) async {
    final logger = getLogger();
    logger.d('开始初始化播放器，视频URL: ${video ?? videoUrl}');

    /// 设置/恢复 屏幕亮度
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      if (brightness != null) {
        ScreenBrightness().setApplicationScreenBrightness(brightness!);
      } else {
        ScreenBrightness().resetApplicationScreenBrightness();
      }
    }
    logger.d('调用 plPlayerController.setDataSource');
    await plPlayerController.setDataSource(
      DataSource(
        videoSource: video ?? videoUrl,
        type: DataSourceType.network,
      ),
      seekTo: seekToTime ?? defaultST,
      duration: duration ?? Duration(seconds: (videoItem.duration ?? 0)),
      vid: videoItem.vid,
      enableHeart: enableHeart,
      isFirstTime: isFirstTime,
      autoplay: autoplay ?? autoPlay.value,
    );
    logger.d('setDataSource 完成');

    /// 开启自动全屏时，在player初始化完成后立即传入headerControl
    plPlayerController.headerControl = headerControl;
    logger.d('设置 headerControl');

    logger.d('设置 headerControl');
  }

  // mob端全屏状态关闭二级回复
  void hiddenReplyReplyPanel() {
    if (replyReplyBottomSheetCtr != null) {
      replyReplyBottomSheetCtr!.close();
    }
    // replyReplyBottomSheetCtr is null
  }

  // 获取弹幕
  Future getDanmaku() async {
    try {
      final logger = getLogger();
      logger.d('开始获取弹幕，vid: $vid');
      final danmakus = await _danmakuRepo.getDanmakus(vid);
      _danmakuCount.value = danmakus.length;
      logger.d('获取弹幕成功，数量: ${danmakus.length}');
      if (plPlayerController.danmakuController != null) {
        plPlayerController.danmakuController!.clear();
        for (var danmaku in danmakus) {
          DanmakuItemType type = DanmakuItemType.scroll;
          if (danmaku.mode == 'top') {
            type = DanmakuItemType.top;
          } else if (danmaku.mode == 'bottom') {
            type = DanmakuItemType.bottom;
          }
          Color color = _parseDanmakuColor(danmaku.color);
          DanmakuContentItem item = DanmakuContentItem(
            danmaku.text,
            color: color,
            type: type,
          );
          plPlayerController.danmakuController!.addDanmaku(item);
        }
        logger.d('弹幕数据已添加到播放器');
      } else {
        logger.w('弹幕控制器未初始化');
      }
    } catch (e) {
      final logger = getLogger();
      logger.e('获取弹幕失败：${e.toString()}');
    }
  }

  Color _parseDanmakuColor(String colorStr) {
    if (colorStr.isEmpty) {
      return Colors.white;
    }
    try {
      String hex = colorStr.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
      return Colors.white;
    } catch (e) {
      return Colors.white;
    }
  }

  /// 发送弹幕
  void showShootDanmakuSheet() {
    final TextEditingController textController = TextEditingController();
    bool isSending = false;
    String danmakuMode = 'scroll';
    String danmakuColor = 'ffffff';
    String danmakuFontSize = '25px';

    final List<Map<String, dynamic>> modeOptions = [
      {'value': 'scroll', 'label': '滚动', 'icon': Icons.swap_horiz},
      {'value': 'top', 'label': '顶部', 'icon': Icons.vertical_align_top},
      {'value': 'bottom', 'label': '底部', 'icon': Icons.vertical_align_bottom},
    ];

    final List<Map<String, dynamic>> colorOptions = [
      {'value': 'ffffff', 'color': Colors.white},
      {'value': 'ff0000', 'color': Colors.red},
      {'value': 'ff9900', 'color': Colors.orange},
      {'value': 'ffff00', 'color': Colors.yellow},
      {'value': '00ff00', 'color': Colors.green},
      {'value': '00ffff', 'color': Colors.cyan},
      {'value': '0099ff', 'color': Colors.blue},
      {'value': 'ff00ff', 'color': Colors.purple},
    ];

    final List<Map<String, dynamic>> fontSizeOptions = [
      {'value': '18px', 'label': '小'},
      {'value': '25px', 'label': '中'},
      {'value': '36px', 'label': '大'},
    ];

    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final theme = Theme.of(context);
            final bottomPadding = MediaQuery.of(context).padding.bottom;
            final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

            return AnimatedPadding(
              padding: EdgeInsets.only(
                bottom: keyboardHeight > 0 ? keyboardHeight : bottomPadding,
              ),
              duration: const Duration(milliseconds: 100),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '发送弹幕',
                            style: theme.textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                            style: IconButton.styleFrom(
                              foregroundColor: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              constraints: const BoxConstraints(
                                minHeight: 40,
                                maxHeight: 100,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: textController,
                                maxLines: 3,
                                minLines: 1,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: '发一条弹幕喵~',
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.outline,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  counterText: '',
                                ),
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
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
                                      await _danmakuRepo.sendDanmaku(
                                        vid: vid,
                                        text: msg,
                                        time: plPlayerController
                                            .position.value.inSeconds,
                                        mode: danmakuMode,
                                        color: danmakuColor,
                                        fontSize: danmakuFontSize,
                                        render: '',
                                      );
                                      SmartDialog.showToast('发送成功');
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    } catch (e) {
                                      SmartDialog.showToast(
                                          '发送失败：${e.toString()}');
                                    } finally {
                                      setState(() {
                                        isSending = false;
                                      });
                                    }
                                  },
                            icon: isSending
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  )
                                : const Icon(Icons.send_rounded, size: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '弹幕类型',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: modeOptions.map((option) {
                          final isSelected = danmakuMode == option['value'];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    option['icon'] as IconData,
                                    size: 16,
                                    color: isSelected
                                        ? theme.colorScheme.onSecondaryContainer
                                        : theme.colorScheme.outline,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(option['label'] as String),
                                ],
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    danmakuMode = option['value'] as String;
                                  });
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '弹幕颜色',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: colorOptions.map((option) {
                          final isSelected = danmakuColor == option['value'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                danmakuColor = option['value'] as String;
                              });
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: option['color'] as Color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline
                                          .withValues(alpha: 0.3),
                                  width: isSelected ? 3 : 1,
                                ),
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      size: 18,
                                      color: theme.colorScheme.primary,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '字体大小',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: fontSizeOptions.map((option) {
                          final isSelected = danmakuFontSize == option['value'];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(option['label'] as String),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    danmakuFontSize = option['value'] as String;
                                  });
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void updateCover(String? pic) {
    if (pic != null) {
      cover.value = pic;
    }
  }

  void onControllerCreated(ScrollController controller) {
    replyScrollController = controller;
  }

  void onTapTabbar(int index) {
    if (tabCtr.animation!.isCompleted && index == 1 && tabCtr.index == 1) {
      replyScrollController?.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  @override
  void onClose() {
    super.onClose();
    plPlayerController.dispose();
  }
}
