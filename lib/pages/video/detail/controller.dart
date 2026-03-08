import 'dart:async';
import 'dart:io';
import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/services/ottohub_service.dart';
import 'package:piliotto/models/common/reply_type.dart';
import 'package:piliotto/models/common/search_type.dart';
import 'package:piliotto/models/video/reply/item.dart';
import 'package:piliotto/models/video/later.dart';
import 'package:piliotto/plugin/pl_player/index.dart';
import 'package:piliotto/services/loggeer.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../../api/models/video.dart';
import '../../../plugin/pl_player/models/bottom_control_type.dart';
import 'introduction/controller.dart';
import 'reply/controller.dart';
import 'reply_reply/view.dart';
import 'widgets/header_control.dart';
import 'widgets/watch_later_list.dart';

class VideoDetailController extends GetxController
    with GetSingleTickerProviderStateMixin {
  /// 路由传参
  int vid = int.parse(Get.parameters['vid']!);
  String heroTag = Get.arguments['heroTag'];
  // 视频详情
  late Video videoItem;
  // 视频类型 默认投稿视频
  SearchType videoType = Get.arguments['videoType'] ?? SearchType.video;
  // 页面来源 稍后再看 收藏夹
  RxString sourceType = 'normal'.obs;

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
  final scaffoldKey = GlobalKey<ScaffoldState>();
  RxString bgCover = ''.obs;
  RxString cover = ''.obs;
  PlPlayerController plPlayerController = PlPlayerController();

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
  List subtitles = [];
  RxList<BottomControlType> bottomList = [
    BottomControlType.playOrPause,
    BottomControlType.time,
    BottomControlType.space,
    BottomControlType.fit,
    BottomControlType.fullscreen,
  ].obs;
  RxDouble sheetHeight = 0.0.obs;
  ScrollController? replyScrollController;
  List<MediaVideoItemModel> mediaList = <MediaVideoItemModel>[];
  RxBool isWatchLaterVisible = false.obs;
  RxString watchLaterTitle = ''.obs;

  @override
  void onInit() {
    super.onInit();
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

    sourceType.value = argMap['sourceType'] ?? 'normal';
    isWatchLaterVisible.value =
        sourceType.value == 'watchLater' || sourceType.value == 'fav';
    if (sourceType.value == 'watchLater') {
      watchLaterTitle.value = '稍后再看';
      fetchMediaList();
    }
    if (sourceType.value == 'fav') {
      watchLaterTitle.value = argMap['favTitle'];
      queryFavVideoList();
    }
    tabCtr.addListener(() {
      onTabChanged();
    });
  }

  showReplyReplyPanel(oid, fRpid, firstFloor, currentReply, loadMore) {
    replyReplyBottomSheetCtr =
        scaffoldKey.currentState?.showBottomSheet((BuildContext context) {
      return VideoReplyReplyPanel(
        oid: oid,
        rpid: fRpid,
        closePanel: () => {
          fRpid = 0,
        },
        firstFloor: firstFloor,
        replyType: ReplyType.video,
        source: 'videoDetail',
        sheetHeight: sheetHeight.value,
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
      logger.d('调用 OttohubService.getVideoDetail($vid)');
      videoItem = await OttohubService.getVideoDetail(vid);
      logger.d('获取视频详情成功: ${videoItem.title}');
      updateCover(videoItem.coverUrl);
      videoUrl = "https://ottohub.cn/api/video/play?vid=$vid";
      logger.d('生成视频URL: $videoUrl');
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

  Future playerInit({
    video,
    seekToTime,
    duration,
    bool? autoplay,
  }) async {
    final logger = getLogger();
    logger.d('开始初始化播放器，视频URL: ${video ?? videoUrl}');

    /// 设置/恢复 屏幕亮度
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      if (brightness != null) {
        ScreenBrightness().setScreenBrightness(brightness!);
      } else {
        ScreenBrightness().resetScreenBrightness();
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
      enableHeart: enableHeart,
      isFirstTime: isFirstTime,
      autoplay: autoplay ?? autoPlay.value,
    );
    logger.d('setDataSource 完成');

    /// 开启自动全屏时，在player初始化完成后立即传入headerControl
    plPlayerController.headerControl = headerControl;
    logger.d('设置 headerControl');

    plPlayerController.subtitles.value = subtitles;
    logger.d('设置字幕');
  }

  // mob端全屏状态关闭二级回复
  hiddenReplyReplyPanel() {
    if (replyReplyBottomSheetCtr != null) {
      replyReplyBottomSheetCtr!.close();
    }
    // replyReplyBottomSheetCtr is null
  }

  // 获取字幕配置
  Future getSubtitle() async {
    // Ottohub API 暂不支持字幕
    subtitles = [];
  }

  // 获取弹幕
  Future getDanmaku(List subtitles) async {
    // Ottohub API 暂不支持弹幕
  }

  setSubtitleContent() {
    plPlayerController.subtitleContent.value = '';
    plPlayerController.subtitles.value = subtitles;
  }

  clearSubtitleContent() {
    plPlayerController.subtitleContent.value = '';
    plPlayerController.subtitles.value = [];
  }

  /// 发送弹幕
  void showShootDanmakuSheet() {
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
                            vid: vid,
                            text: msg,
                            time: plPlayerController.position.value.inSeconds,
                            mode: '1',
                            color: 'ffffff',
                            fontSize: '25',
                            render: '1',
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

  void toggeleWatchLaterVisible(bool val) {
    if (sourceType.value == 'watchLater' || sourceType.value == 'fav') {
      isWatchLaterVisible.value = !isWatchLaterVisible.value;
    }
  }

  // 获取稍后再看列表
  Future fetchMediaList() async {
    // Ottohub API 暂不支持获取稍后再看列表
    mediaList = [];
  }

  // 稍后再看面板展开
  showMediaListPanel() {
    replyReplyBottomSheetCtr =
        scaffoldKey.currentState?.showBottomSheet((BuildContext context) {
      return MediaListPanel(
        sheetHeight: sheetHeight.value,
        mediaList: mediaList,
        changeMediaList: changeMediaList,
        panelTitle: watchLaterTitle.value,
        vid: vid,
        mediaId: Get.arguments['mediaId'],
        hasMore: mediaList.length != Get.arguments['count'],
      );
    });
    replyReplyBottomSheetCtr?.closed.then((value) {
      isWatchLaterVisible.value = true;
    });
  }

  // 切换稍后再看
  Future changeMediaList(vidVal, coverVal) async {
    final VideoIntroController videoIntroCtr =
        Get.find<VideoIntroController>(tag: heroTag);
    vid = vidVal;
    cover.value = coverVal;
    await getVideoDetail();
    clearSubtitleContent();
    await getSubtitle();
    setSubtitleContent();
    // 重新请求评论
    try {
      /// 未渲染回复组件时可能异常
      final VideoReplyController videoReplyCtr =
          Get.find<VideoReplyController>(tag: heroTag);
      videoReplyCtr.vid = vidVal;
      videoReplyCtr.queryReplyList(type: 'init');
    } catch (_) {}
    videoIntroCtr.vid = vidVal;
    replyReplyBottomSheetCtr!.close();
    await videoIntroCtr.queryVideoIntro();
  }

  // 获取收藏夹视频列表
  Future queryFavVideoList() async {
    // Ottohub API 暂不支持获取收藏夹视频列表
    mediaList = [];
  }

  // 监听tabBarView切换
  void onTabChanged() {
    isWatchLaterVisible.value = tabCtr.index == 0;
  }

  @override
  void onClose() {
    super.onClose();
    plPlayerController.dispose();
    tabCtr.removeListener(onTabChanged);
  }
}
