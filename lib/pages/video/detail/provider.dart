import 'dart:async';
import 'dart:io';
import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:piliotto/providers/repository_provider.dart';
import 'package:piliotto/repositories/i_video_repository.dart';
import 'package:piliotto/repositories/i_danmaku_repository.dart';
import 'package:piliotto/router/app_router.dart';
import 'package:piliotto/ottohub/models/video/reply/item.dart';
import 'package:piliotto/models/common/reply_type.dart';
import 'package:piliotto/pages/video/detail/reply_reply/view.dart';
import 'package:piliotto/plugin/pl_player/index.dart';
import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:piliotto/services/loggeer.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:piliotto/utils/route_arguments.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:universal_platform/universal_platform.dart';
import '../../../ottohub/api/models/video.dart';
import '../../../plugin/pl_player/models/bottom_control_type.dart';
import 'widgets/header_control.dart';

part 'provider.g.dart';

class VideoDetailState {
  final int vid;
  final String heroTag;
  final String videoType;
  final Video? videoItem;
  final bool isLoading;
  final bool autoPlay;
  final bool isEffective;
  final bool isShowCover;
  final String bgCover;
  final String cover;
  final String? videoUrl;
  final Duration defaultST;
  final double? brightness;
  final bool enableHeart;
  final dynamic userInfo;
  final bool isFirstTime;
  final bool enableRelatedVideo;
  final List<BottomControlType> bottomList;
  final double sheetHeight;
  final int danmakuCount;
  final List<String> tabs;
  final int currentTabIndex;

  const VideoDetailState({
    this.vid = 0,
    this.heroTag = '',
    this.videoType = 'video',
    this.videoItem,
    this.isLoading = false,
    this.autoPlay = true,
    this.isEffective = true,
    this.isShowCover = true,
    this.bgCover = '',
    this.cover = '',
    this.videoUrl,
    this.defaultST = Duration.zero,
    this.brightness,
    this.enableHeart = true,
    this.userInfo,
    this.isFirstTime = true,
    this.enableRelatedVideo = true,
    this.bottomList = const [
      BottomControlType.playOrPause,
      BottomControlType.time,
      BottomControlType.space,
      BottomControlType.fit,
      BottomControlType.fullscreen,
    ],
    this.sheetHeight = 0.0,
    this.danmakuCount = 0,
    this.tabs = const ['简介', '评论'],
    this.currentTabIndex = 0,
  });

  VideoDetailState copyWith({
    int? vid,
    String? heroTag,
    String? videoType,
    Video? videoItem,
    bool? isLoading,
    bool? autoPlay,
    bool? isEffective,
    bool? isShowCover,
    String? bgCover,
    String? cover,
    String? videoUrl,
    Duration? defaultST,
    double? brightness,
    bool? enableHeart,
    dynamic userInfo,
    bool? isFirstTime,
    bool? enableRelatedVideo,
    List<BottomControlType>? bottomList,
    double? sheetHeight,
    int? danmakuCount,
    List<String>? tabs,
    int? currentTabIndex,
  }) {
    return VideoDetailState(
      vid: vid ?? this.vid,
      heroTag: heroTag ?? this.heroTag,
      videoType: videoType ?? this.videoType,
      videoItem: videoItem ?? this.videoItem,
      isLoading: isLoading ?? this.isLoading,
      autoPlay: autoPlay ?? this.autoPlay,
      isEffective: isEffective ?? this.isEffective,
      isShowCover: isShowCover ?? this.isShowCover,
      bgCover: bgCover ?? this.bgCover,
      cover: cover ?? this.cover,
      videoUrl: videoUrl ?? this.videoUrl,
      defaultST: defaultST ?? this.defaultST,
      brightness: brightness ?? this.brightness,
      enableHeart: enableHeart ?? this.enableHeart,
      userInfo: userInfo ?? this.userInfo,
      isFirstTime: isFirstTime ?? this.isFirstTime,
      enableRelatedVideo: enableRelatedVideo ?? this.enableRelatedVideo,
      bottomList: bottomList ?? this.bottomList,
      sheetHeight: sheetHeight ?? this.sheetHeight,
      danmakuCount: danmakuCount ?? this.danmakuCount,
      tabs: tabs ?? this.tabs,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }
}

@riverpod
class VideoDetailNotifier extends _$VideoDetailNotifier {
  PlPlayerController? plPlayerController;
  Floating? floating;
  PreferredSizeWidget? headerControl;
  PersistentBottomSheetController? replyReplyBottomSheetCtr;
  ScrollController? replyScrollController;
  TabController? tabController;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> rightContentScaffoldKey =
      GlobalKey<ScaffoldState>();
  int fRpid = 0;
  ReplyItemModel? firstFloor;

  IVideoRepository get _videoRepo => ref.read(videoRepositoryProvider);
  IDanmakuRepository get _danmakuRepo => ref.read(danmakuRepositoryProvider);

  @override
  VideoDetailState build() {
    final vid = int.tryParse(routeArguments['vid']?.toString() ?? '0') ?? 0;
    final heroTag = routeArguments['heroTag'] ?? '';
    final videoType = routeArguments['videoType'] ?? 'video';

    plPlayerController = PlPlayerController();

    dynamic userInfo;
    try {
      userInfo = GStrorage.userInfo.get('userInfoCache');
    } catch (_) {
      userInfo = null;
    }

    bool autoPlay = true;
    bool enableRelatedVideo = true;
    try {
      autoPlay =
          GStrorage.setting.get(SettingBoxKey.autoPlayEnable, defaultValue: true);
      enableRelatedVideo =
          GStrorage.setting.get(SettingBoxKey.enableRelatedVideo, defaultValue: true);
    } catch (_) {
      autoPlay = true;
      enableRelatedVideo = true;
    }

    bool enableHeart = true;
    bool historyPause = false;
    try {
      historyPause = GStrorage.localCache.get(LocalCacheKey.historyPause) == true;
    } catch (_) {}
    if (userInfo == null || historyPause) {
      enableHeart = false;
    }

    if (Platform.isAndroid) {
      floating = Floating();
    }

    String initialCover = '';
    if (routeArguments['videoItem'] != null) {
      var args = routeArguments['videoItem'];
      initialCover = args.pic ?? '';
    } else if (routeArguments['pic'] != null) {
      initialCover = routeArguments['pic'];
    }

    final initialState = VideoDetailState(
      vid: vid,
      heroTag: heroTag,
      videoType: videoType,
      userInfo: userInfo,
      autoPlay: autoPlay,
      enableHeart: enableHeart,
      enableRelatedVideo: enableRelatedVideo,
      cover: initialCover,
    );

    headerControl = HeaderControl(
      controller: plPlayerController!,
      videoDetailNotifier: this,
      floating: floating,
      vid: vid,
      videoType: videoType,
    );

    Future.microtask(() => getVideoDetail());

    return initialState;
  }

  void initTabController(TickerProvider vsync) {
    tabController = TabController(length: 2, vsync: vsync);
  }

  void showReplyReplyPanel(int oid, int fRpid, dynamic firstFloor,
      dynamic currentReply, bool loadMore) {
    final bool isWideScreen = WidgetsBinding
                .instance.platformDispatcher.views.first.physicalSize.width /
            WidgetsBinding
                .instance.platformDispatcher.views.first.devicePixelRatio >
        768;
    final scaffold = isWideScreen ? rightContentScaffoldKey : scaffoldKey;

    replyReplyBottomSheetCtr =
        scaffold.currentState?.showBottomSheet((BuildContext context) {
      return VideoReplyReplyPanel(
        vid: oid,
        parentVcid: fRpid,
        closePanel: () => {
          this.fRpid = 0,
        },
        firstFloor: firstFloor,
        replyType: ReplyType.video,
        source: 'videoDetail',
        sheetHeight: isWideScreen ? null : state.sheetHeight,
        currentReply: currentReply,
        loadMore: loadMore,
      );
    });
    replyReplyBottomSheetCtr?.closed.then((value) {
      this.fRpid = 0;
    });
  }

  Future getVideoDetail() async {
    state = state.copyWith(isLoading: true);
    final logger = getLogger();
    logger.d('开始获取视频详情，vid: ${state.vid}');
    try {
      logger.d('调用 OttohubVideoRepository.getVideoDetail(${state.vid})');
      final videoItem = await _videoRepo.getVideoDetail(state.vid);
      logger.d('获取视频详情成功: ${videoItem.title}');
      final videoUrl = videoItem.videoUrl ?? '';
      logger.d('生成视频URL: $videoUrl');

      if (videoUrl.isEmpty) {
        logger.e('视频URL为空，视频无效');
        state = state.copyWith(isEffective: false, isLoading: false);
        SmartDialog.showToast('视频URL无效');
        return;
      }

      state = state.copyWith(
        videoItem: videoItem,
        cover: videoItem.coverUrl,
        videoUrl: videoUrl,
        isLoading: false,
      );

      if (state.autoPlay) {
        logger.d('开始初始化播放器');
        await playerInit();
        logger.d('播放器初始化成功');
        state = state.copyWith(isShowCover: false);
      }
    } catch (e) {
      logger.e('获取视频详情失败：${e.toString()}');
      SmartDialog.showToast('获取视频详情失败：${e.toString()}');
      state = state.copyWith(isEffective: false, isLoading: false);
    }
  }

  Future<void> playerInit({
    String? video,
    Duration? seekToTime,
    Duration? duration,
    bool? autoplay,
  }) async {
    final logger = getLogger();
    final videoUrl = video ?? state.videoUrl;
    logger.d('开始初始化播放器，视频URL: $videoUrl');

    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      if (state.brightness != null) {
        ScreenBrightness().setApplicationScreenBrightness(state.brightness!);
      } else {
        ScreenBrightness().resetApplicationScreenBrightness();
      }
    }

    final videoItem = state.videoItem;
    if (videoItem == null || plPlayerController == null) return;

    logger.d('调用 plPlayerController.setDataSource');
    await plPlayerController!.setDataSource(
      DataSource(
        videoSource: videoUrl ?? '',
        type: DataSourceType.network,
      ),
      seekTo: seekToTime ?? state.defaultST,
      duration: duration ?? Duration(seconds: (videoItem.duration ?? 0)),
      vid: videoItem.vid,
      enableHeart: state.enableHeart,
      isFirstTime: state.isFirstTime,
      autoplay: autoplay ?? state.autoPlay,
    );
    logger.d('setDataSource 完成');

    plPlayerController!.headerControl = headerControl;
    logger.d('设置 headerControl');
  }

  void hiddenReplyReplyPanel() {
    if (replyReplyBottomSheetCtr != null) {
      replyReplyBottomSheetCtr!.close();
    }
  }

  Future getDanmaku() async {
    try {
      final logger = getLogger();
      logger.d('开始获取弹幕，vid: ${state.vid}');
      final danmakus = await _danmakuRepo.getDanmakus(state.vid);
      state = state.copyWith(danmakuCount: danmakus.length);
      logger.d('获取弹幕成功，数量: ${danmakus.length}');
      if (plPlayerController?.danmakuController != null) {
        plPlayerController!.danmakuController!.clear();
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
          plPlayerController!.danmakuController!.addDanmaku(item);
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
      context: rootNavigatorKey.currentContext!,
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
                                        vid: state.vid,
                                        text: msg,
                                        time: plPlayerController!
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
      state = state.copyWith(cover: pic);
    }
  }

  void onControllerCreated(ScrollController controller) {
    replyScrollController = controller;
  }

  void onTapTabbar(int index) {
    if (tabController?.animation?.isCompleted == true &&
        index == 1 &&
        tabController?.index == 1) {
      replyScrollController?.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  void setAutoPlay(bool value) {
    state = state.copyWith(autoPlay: value);
  }

  void setIsShowCover(bool value) {
    state = state.copyWith(isShowCover: value);
  }

  void setIsFirstTime(bool value) {
    state = state.copyWith(isFirstTime: value);
  }

  void setDefaultST(Duration value) {
    state = state.copyWith(defaultST: value);
  }

  void setBrightness(double? value) {
    state = state.copyWith(brightness: value);
  }

  void setSheetHeight(double value) {
    state = state.copyWith(sheetHeight: value);
  }

  void setBottomList(List<BottomControlType> value) {
    state = state.copyWith(bottomList: value);
  }

  void dispose() {
    plPlayerController?.dispose();
    tabController?.dispose();
  }
}
