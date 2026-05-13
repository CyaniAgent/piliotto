import 'dart:async';
import 'dart:io';
import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/repositories/i_video_repository.dart';
import 'package:piliotto/repositories/i_danmaku_repository.dart';

import 'package:piliotto/ottohub/models/video/reply/item.dart';
import 'package:piliotto/models/common/reply_type.dart';
import 'package:piliotto/pages/video/detail/reply_reply/view.dart';
import 'package:piliotto/plugin/pl_player/index.dart';
import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:piliotto/services/loggeer.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../../ottohub/api/models/video.dart';
import '../../../plugin/pl_player/models/bottom_control_type.dart';
import 'widgets/danmaku_send_sheet.dart';
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
  Box videoStorage = GStrorage.video;

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
  
  // 半屏默认底部按钮列表
  static const List<BottomControlType> _defaultHalfScreenBottomList = [
    BottomControlType.playOrPause,
    BottomControlType.time,
    BottomControlType.space,
    BottomControlType.fit,
    BottomControlType.fullscreen,
  ];
  
  // 全屏默认底部按钮列表
  static const List<BottomControlType> _defaultFullScreenBottomList = [
    BottomControlType.playOrPause,
    BottomControlType.time,
    BottomControlType.space,
    BottomControlType.episode,
    BottomControlType.fit,
    BottomControlType.speed,
    BottomControlType.fullscreen,
  ];
  
  // 当前使用的底部按钮列表
  RxList<BottomControlType> bottomList = <BottomControlType>[].obs;
  
  // 半屏底部按钮列表
  late RxList<BottomControlType> halfScreenBottomList;
  
  // 全屏底部按钮列表
  late RxList<BottomControlType> fullScreenBottomList;
  
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

    // 初始化底部按钮列表
    _initBottomLists();

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

  /// 初始化底部按钮列表（从本地存储读取或使用默认值）
  void _initBottomLists() {
    final List<String>? halfScreenCodes = 
        videoStorage.get(VideoBoxKey.halfScreenBottomList)?.cast<String>();
    final List<String>? fullScreenCodes = 
        videoStorage.get(VideoBoxKey.fullScreenBottomList)?.cast<String>();
    
    final halfScreen = BottomControlTypeExtension.fromCodeList(halfScreenCodes);
    final fullScreen = BottomControlTypeExtension.fromCodeList(fullScreenCodes);
    
    halfScreenBottomList = (halfScreen.isEmpty 
        ? List<BottomControlType>.from(_defaultHalfScreenBottomList) 
        : halfScreen).obs;
    
    fullScreenBottomList = (fullScreen.isEmpty 
        ? List<BottomControlType>.from(_defaultFullScreenBottomList) 
        : fullScreen).obs;
    
    bottomList.value = List<BottomControlType>.from(halfScreenBottomList);
  }

  /// 保存按钮列表到本地存储
  void saveBottomLists() {
    videoStorage.put(
      VideoBoxKey.halfScreenBottomList,
      BottomControlTypeExtension.toCodeList(halfScreenBottomList),
    );
    videoStorage.put(
      VideoBoxKey.fullScreenBottomList,
      BottomControlTypeExtension.toCodeList(fullScreenBottomList),
    );
  }

  /// 切换到半屏按钮列表
  void switchToHalfScreen() {
    bottomList.value = List<BottomControlType>.from(halfScreenBottomList);
  }

  /// 切换到全屏按钮列表
  void switchToFullScreen() {
    bottomList.value = List<BottomControlType>.from(fullScreenBottomList);
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

  void showShootDanmakuSheet() {
    DanmakuSendSheet.show(
      vid: vid,
      currentTime: plPlayerController.position.value.inSeconds,
      onSend: ({required vid, required text, required time, required mode, required color, required fontSize}) {
        return _danmakuRepo.sendDanmaku(
          vid: vid,
          text: text,
          time: time,
          mode: mode,
          color: color,
          fontSize: fontSize,
          render: '',
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
