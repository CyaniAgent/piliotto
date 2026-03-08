import 'dart:async';
import 'dart:io';

import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:floating/floating.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/models/common/search_type.dart';
import 'package:piliotto/pages/bangumi/introduction/index.dart';
import 'package:piliotto/pages/danmaku/view.dart';
import 'package:piliotto/pages/main/index.dart';
import 'package:piliotto/pages/video/detail/reply/index.dart';
import 'package:piliotto/pages/video/detail/controller.dart';
import 'package:piliotto/pages/video/detail/introduction/index.dart';

import 'package:piliotto/plugin/pl_player/index.dart';
import 'package:piliotto/plugin/pl_player/models/play_repeat.dart';
import 'package:piliotto/services/service_locator.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:status_bar_control/status_bar_control.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../../plugin/pl_player/models/bottom_control_type.dart';
import '../../../services/shutdown_timer_service.dart';

import 'widgets/app_bar.dart';

class VideoDetailPage extends StatefulWidget {
  const VideoDetailPage({Key? key}) : super(key: key);

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();
}

class _VideoDetailPageState extends State<VideoDetailPage>
    with TickerProviderStateMixin, RouteAware, WidgetsBindingObserver {
  late VideoDetailController vdCtr;
  PlPlayerController? plPlayerController;
  final ScrollController _extendNestCtr = ScrollController();
  late StreamController<double> appbarStream;
  late VideoIntroController videoIntroController;
  late BangumiIntroController bangumiIntroController;
  late String heroTag;

  Rx<PlayerStatus> playerStatus = PlayerStatus.playing.obs;
  double doubleOffset = 0;

  final Box<dynamic> localCache = GStrorage.localCache;
  final Box<dynamic> setting = GStrorage.setting;
  late double statusBarHeight;
  final double videoHeight = Get.size.width * 9 / 16;
  late Future _futureBuilderFuture;
  // 自动退出全屏
  late bool autoExitFullcreen;
  late bool autoPlayEnable;
  late bool autoPiP;
  late Floating floating;
  RxBool isShowing = true.obs;
  // 生命周期监听
  late final AppLifecycleListener _lifecycleListener;
  late double statusHeight;

  @override
  void initState() {
    super.initState();
    getStatusHeight();
    heroTag = Get.arguments['heroTag'];
    vdCtr = Get.put(VideoDetailController(), tag: heroTag);
    vdCtr.sheetHeight.value = localCache.get('sheetHeight');
    videoIntroController = Get.put(
        VideoIntroController(bvid: Get.parameters['bvid']!),
        tag: heroTag);
    videoIntroController.videoDetail.listen((value) {
      videoPlayerServiceHandler.onVideoDetailChange(value, vdCtr.cid.value);
    });
    if (vdCtr.videoType == SearchType.media_bangumi) {
      bangumiIntroController = Get.put(BangumiIntroController(), tag: heroTag);
      bangumiIntroController.bangumiDetail.listen((value) {
        videoPlayerServiceHandler.onVideoDetailChange(value, vdCtr.cid.value);
      });
      vdCtr.cid.listen((p0) {
        videoPlayerServiceHandler.onVideoDetailChange(
            bangumiIntroController.bangumiDetail.value, p0);
      });
    }
    statusBarHeight = localCache.get('statusBarHeight');
    autoExitFullcreen =
        setting.get(SettingBoxKey.enableAutoExit, defaultValue: false);
    autoPlayEnable =
        setting.get(SettingBoxKey.autoPlayEnable, defaultValue: true);
    autoPiP = setting.get(SettingBoxKey.autoPiP, defaultValue: false);

    videoSourceInit();
    appbarStreamListen();
    fullScreenStatusListener();
    if (Platform.isAndroid) {
      floating = vdCtr.floating!;
    }
    WidgetsBinding.instance.addObserver(this);
    lifecycleListener();
  }

  // 获取视频资源，初始化播放器
  Future<void> videoSourceInit() async {
    _futureBuilderFuture = vdCtr.queryVideoUrl();
    if (vdCtr.autoPlay.value) {
      plPlayerController = vdCtr.plPlayerController;
      plPlayerController!.addStatusLister(playerListener);
    }
  }

  // 流
  appbarStreamListen() {
    appbarStream = StreamController<double>.broadcast();
    _extendNestCtr.addListener(
      () {
        final double offset = _extendNestCtr.position.pixels;
        vdCtr.sheetHeight.value =
            Get.size.height - videoHeight - statusBarHeight + offset;
        appbarStream.add(offset);
      },
    );
  }

  // 播放器状态监听
  void playerListener(PlayerStatus status) async {
    playerStatus.value = status;
    autoEnterPip(status: status);
    if (status == PlayerStatus.completed) {
      // 结束播放退出全屏
      if (autoExitFullcreen) {
        plPlayerController!.triggerFullScreen(status: false);
      }
      shutdownTimerService.handleWaitingFinished();

      /// 顺序播放 列表循环
      if (plPlayerController!.playRepeat != PlayRepeat.pause &&
          plPlayerController!.playRepeat != PlayRepeat.singleCycle) {
        if (vdCtr.videoType == SearchType.video) {
          videoIntroController.nextPlay();
        }
        if (vdCtr.videoType == SearchType.media_bangumi) {
          bangumiIntroController.nextPlay();
        }
      }

      /// 单个循环
      if (plPlayerController!.playRepeat == PlayRepeat.singleCycle) {
        plPlayerController!.seekTo(Duration.zero);
        plPlayerController!.play();
      }
      // 播放完展示控制栏
      try {
        PiPStatus currentStatus = await vdCtr.floating!.pipStatus;
        if (currentStatus == PiPStatus.disabled) {
          plPlayerController!.onLockControl(false);
        }
      } catch (_) {}
    }
    if (Platform.isAndroid) {
      floating.toggleAutoPip(
          autoEnter: status == PlayerStatus.playing && autoPiP);
    }
  }

  // 继续播放或重新播放
  void continuePlay() async {
    await _extendNestCtr.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    plPlayerController!.play();
  }

  /// 未开启自动播放时触发播放
  Future<void> handlePlay() async {
    await vdCtr.playerInit(autoplay: true);
    plPlayerController = vdCtr.plPlayerController;
    plPlayerController!.addStatusLister(playerListener);
    vdCtr.autoPlay.value = true;
    vdCtr.isShowCover.value = false;
    isShowing.value = true;
    autoEnterPip(status: PlayerStatus.playing);
  }

  void fullScreenStatusListener() {
    plPlayerController?.isFullScreen.listen((bool isFullScreen) {
      if (isFullScreen) {
        vdCtr.hiddenReplyReplyPanel();
        if (vdCtr.videoType == SearchType.video) {
          videoIntroController.hiddenEpisodeBottomSheet();
          if (videoIntroController.videoDetail.value.ugcSeason != null ||
              (videoIntroController.videoDetail.value.pages != null &&
                  videoIntroController.videoDetail.value.pages!.length > 1)) {
            vdCtr.bottomList.insert(3, BottomControlType.episode);
          }
        }
        if (vdCtr.videoType == SearchType.media_bangumi) {
          bangumiIntroController.hiddenEpisodeBottomSheet();
          if (bangumiIntroController.bangumiDetail.value.episodes != null &&
              bangumiIntroController.bangumiDetail.value.episodes!.length > 1) {
            vdCtr.bottomList.insert(3, BottomControlType.episode);
          }
        }
      } else {
        if (vdCtr.bottomList.contains(BottomControlType.episode)) {
          vdCtr.bottomList.removeAt(3);
        }
      }
      vdCtr.toggeleWatchLaterVisible(!isFullScreen);
    });
  }

  getStatusHeight() async {
    // 只在移动平台上使用StatusBarControl
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      try {
        statusHeight = await StatusBarControl.getHeight;
      } catch (e) {
        // 捕获异常，避免初始化失败
        // StatusBarControl 错误: $e
        statusHeight = 0;
      }
    } else {
      // 桌面平台默认状态栏高度为0
      statusHeight = 0;
    }
  }

  @override
  void dispose() {
    shutdownTimerService.handleWaitingFinished();
    if (plPlayerController != null) {
      plPlayerController!.removeStatusLister(playerListener);
      plPlayerController!.dispose();
    }
    if (vdCtr.floating != null) {
      vdCtr.floating!.dispose();
    }
    videoPlayerServiceHandler.onVideoDetailDispose();
    if (Platform.isAndroid) {
      floating.toggleAutoPip(autoEnter: false);
      floating.dispose();
    }
    appbarStream.close();
    WidgetsBinding.instance.removeObserver(this);
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  // 离开当前页面时
  void didPushNext() async {
    final MainController mainController = Get.find<MainController>();
    if (mainController.imgPreviewStatus) {
      return;
    }

    /// 开启
    if (setting.get(SettingBoxKey.enableAutoBrightness, defaultValue: false)
        as bool) {
      vdCtr.brightness = plPlayerController!.brightness.value;
    }
    if (plPlayerController != null) {
      vdCtr.defaultST = plPlayerController!.position.value;
      videoIntroController.isPaused = true;
      plPlayerController!.removeStatusLister(playerListener);
      plPlayerController!.pause();
      vdCtr.clearSubtitleContent();
    }
    isShowing.value = false;
    super.didPushNext();
  }

  @override
  // 返回当前页面时
  void didPopNext() async {
    final MainController mainController = Get.find<MainController>();
    if (mainController.imgPreviewStatus) {
      return;
    }

    if (plPlayerController != null &&
        plPlayerController!.videoPlayerController != null) {
      vdCtr.setSubtitleContent();
      isShowing.value = true;
    }
    vdCtr.isFirstTime = false;
    final bool autoplay = autoPlayEnable;
    vdCtr.playerInit();

    /// 未开启自动播放时，未播放跳转下一页返回/播放后跳转下一页返回
    vdCtr.autoPlay.value = !vdCtr.isShowCover.value;
    videoIntroController.isPaused = false;
    if (_extendNestCtr.position.pixels == 0 && autoplay) {
      await Future.delayed(const Duration(milliseconds: 300));
      plPlayerController?.seekTo(vdCtr.defaultST);
      plPlayerController?.play();
    }
    plPlayerController?.addStatusLister(playerListener);
    appbarStream.add(0);
    super.didPopNext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    VideoDetailPage.routeObserver
        .subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  void autoEnterPip({PlayerStatus? status}) {
    final String routePath = Get.currentRoute;
    if (autoPiP && routePath.startsWith('/video')) {
      floating.toggleAutoPip(
        autoEnter: autoPiP && status == PlayerStatus.playing,
      );
    }
  }

  // 生命周期监听
  void lifecycleListener() {
    _lifecycleListener = AppLifecycleListener(
      // onResume: () => _handleTransition('resume'),
      // 后台
      // onInactive: () => _handleTransition('inactive'),
      // 在Android和iOS端不生效
      // onHide: () => _handleTransition('hide'),
      onShow: () => _handleTransition('show'),
      onPause: () => _handleTransition('pause'),
      onRestart: () => _handleTransition('restart'),
      onDetach: () => _handleTransition('detach'),
    );
  }

  void _handleTransition(String name) {
    switch (name) {
      case 'show' || 'restart':
        plPlayerController?.danmakuController?.clear();
        break;
      case 'pause':
        if (autoPiP) {
          vdCtr.hiddenReplyReplyPanel();
          if (vdCtr.videoType == SearchType.video) {
            videoIntroController.hiddenEpisodeBottomSheet();
          }
          if (vdCtr.videoType == SearchType.media_bangumi) {
            bangumiIntroController.hiddenEpisodeBottomSheet();
          }
        }
        break;
    }
  }

  /// 手动播放
  Widget handlePlayPanel() {
    return Stack(
      children: [
        GestureDetector(
          onTap: handlePlay,
          child: Obx(
            () => NetworkImgLayer(
              src: vdCtr.cover.value,
              width: Get.width,
              height: videoHeight,
              type: 'emote',
            ),
          ),
        ),
        buildCustomAppBar(),
        Positioned(
          right: 12,
          bottom: 10,
          child: GestureDetector(
            onTap: handlePlay,
            child: Image.asset(
              'assets/images/play.png',
              width: 60,
              height: 60,
            ),
          ),
        ),
      ],
    );
  }

  /// 自定义AppBar
  Widget buildCustomAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert, color: Colors.white),
        ),
      ],
    );
  }

  /// tabbar
  Widget tabbarBuild() {
    return Container(
      width: double.infinity,
      height: 45,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Material(
        child: Row(
          children: [
            Expanded(
              child: Obx(
                () => TabBar(
                  padding: EdgeInsets.zero,
                  controller: vdCtr.tabCtr,
                  labelStyle: const TextStyle(fontSize: 13),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                  dividerColor: Colors.transparent,
                  tabs:
                      vdCtr.tabs.map((String name) => Tab(text: name)).toList(),
                  onTap: (index) => vdCtr.onTapTabbar(index),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Obx(() => AnimatedOpacity(
                          opacity: playerStatus.value != PlayerStatus.playing
                              ? 1
                              : 0,
                          duration: const Duration(milliseconds: 100),
                          child: const Icon(
                            Icons.drag_handle_rounded,
                            size: 20,
                            color: Colors.grey,
                          ),
                        )),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 32,
                      child: TextButton(
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(EdgeInsets.zero),
                        ),
                        onPressed: () => vdCtr.showShootDanmakuSheet(),
                        child:
                            const Text('发弹幕', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    SizedBox(
                      width: 38,
                      height: 38,
                      child: Obx(
                        () => !vdCtr.isShowCover.value
                            ? IconButton(
                                onPressed: () {
                                  plPlayerController?.isOpenDanmu.value =
                                      !(plPlayerController?.isOpenDanmu.value ??
                                          false);
                                },
                                icon: !(plPlayerController?.isOpenDanmu.value ??
                                        false)
                                    ? SvgPicture.asset(
                                        'assets/images/video/danmu_close.svg',
                                        // ignore: deprecated_member_use
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      )
                                    : SvgPicture.asset(
                                        'assets/images/video/danmu_open.svg',
                                        // ignore: deprecated_member_use
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                              )
                            : IconButton(
                                icon: SvgPicture.asset(
                                  'assets/images/video/danmu_close.svg',
                                  // ignore: deprecated_member_use
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                onPressed: () {},
                              ),
                      ),
                    ),
                    const SizedBox(width: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizeContext = MediaQuery.sizeOf(context);
    final mediaQuery = MediaQuery.of(context);
    late double defaultVideoHeight = sizeContext.width * 9 / 16;
    late RxDouble videoHeight = defaultVideoHeight.obs;
    final double pinnedHeaderHeight =
        statusBarHeight + kToolbarHeight + videoHeight.value;
    // ignore: no_leading_underscores_for_local_identifiers

    // 横屏
    final bool isLandscape = mediaQuery.orientation == Orientation.landscape;
    final Rx<bool> isFullScreen = plPlayerController?.isFullScreen ?? false.obs;
    // 全屏时高度撑满
    if (isLandscape || isFullScreen.value == true) {
      videoHeight.value = Get.size.height;
      enterFullScreen();
    } else {
      videoHeight.value = defaultVideoHeight;
      exitFullScreen();
    }

    // 宽屏判断
    final bool isWideScreen = Get.size.width > 768;

    Widget buildLoadingWidget() {
      return Center(child: Lottie.asset('assets/loading.json', width: 200));
    }

    Widget buildVideoPlayerWidget(AsyncSnapshot snapshot) {
      return Obx(() => !vdCtr.autoPlay.value
          ? const SizedBox()
          : PLVideoPlayer(
              controller: plPlayerController!,
              headerControl: vdCtr.headerControl,
              danmuWidget: PlDanmaku(
                key: Key(vdCtr.danmakuCid.value.toString()),
                cid: vdCtr.danmakuCid.value,
                playerController: plPlayerController!,
              ),
              bottomList: vdCtr.bottomList,
              showEposideCb: () => vdCtr.videoType == SearchType.video
                  ? videoIntroController.showEposideHandler()
                  : bangumiIntroController.showEposideHandler(),
              fullScreenCb: (bool status) {
                videoHeight.value =
                    status ? Get.size.height : defaultVideoHeight;
              },
            ));
    }

    Widget buildErrorWidget(dynamic error) {
      return Obx(
        () => SizedBox(
          height: videoHeight.value,
          width: Get.size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('加载失败', style: TextStyle(color: Colors.white)),
              Text('$error', style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 10),
              IconButton.filled(
                onPressed: () {
                  setState(() {
                    _futureBuilderFuture = vdCtr.queryVideoUrl();
                  });
                },
                icon: const Icon(Icons.refresh),
              )
            ],
          ),
        ),
      );
    }

    /// 播放器面板
    Widget buildVideoPlayerPanel() {
      return FutureBuilder(
        future: _futureBuilderFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildLoadingWidget();
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data['status']) {
              return buildVideoPlayerWidget(snapshot);
            } else {
              return buildErrorWidget(snapshot.error);
            }
          } else {
            return buildErrorWidget('未知错误');
          }
        },
      );
    }

    /// 右侧内容面板
    Widget buildRightContentPanel() {
      return CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: tabbarBuild(),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: vdCtr.tabCtr,
              children: <Widget>[
                Builder(
                  builder: (BuildContext context) {
                    return CustomScrollView(
                      key: const PageStorageKey<String>('简介'),
                      slivers: <Widget>[
                        if (vdCtr.videoType == SearchType.video) ...[
                          VideoIntroPanel(bvid: vdCtr.bvid),
                        ] else if (vdCtr.videoType ==
                            SearchType.media_bangumi) ...[
                          Obx(() => BangumiIntroPanel(cid: vdCtr.cid.value)),
                        ],
                        SliverToBoxAdapter(
                          child: Divider(
                            indent: 16,
                            endIndent: 16,
                            color: Theme.of(context)
                                .dividerColor
                                .withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Obx(
                  () => VideoReplyPanel(
                    bvid: vdCtr.bvid,
                    oid: vdCtr.oid.value,
                    onControllerCreated: vdCtr.onControllerCreated,
                  ),
                )
              ],
            ),
          ),
        ],
      );
    }

    /// 窄屏布局
    Widget buildNarrowScreenLayout() {
      return SafeArea(
        top: MediaQuery.of(context).orientation == Orientation.portrait &&
            plPlayerController?.isFullScreen.value == true,
        bottom: MediaQuery.of(context).orientation == Orientation.portrait &&
            plPlayerController?.isFullScreen.value == true,
        left: false,
        right: false,
        child: Stack(
          children: [
            Scaffold(
              resizeToAvoidBottomInset: false,
              key: vdCtr.scaffoldKey,
              backgroundColor: Theme.of(context).colorScheme.surface,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(0),
                child: StreamBuilder(
                  stream: appbarStream.stream.distinct(),
                  initialData: 0,
                  builder: ((context, snapshot) {
                    return AppBar(
                      backgroundColor: Colors.black,
                      elevation: 0,
                      scrolledUnderElevation: 0,
                      systemOverlayStyle: Get.isDarkMode
                          ? SystemUiOverlayStyle.light
                          : snapshot.data!.toDouble() > kToolbarHeight
                              ? SystemUiOverlayStyle.dark
                              : SystemUiOverlayStyle.light,
                    );
                  }),
                ),
              ),
              body: ExtendedNestedScrollView(
                controller: _extendNestCtr,
                headerSliverBuilder:
                    (BuildContext context2, bool innerBoxIsScrolled) {
                  return <Widget>[
                    Obx(
                      () {
                        final Orientation orientation =
                            MediaQuery.of(context).orientation;
                        final bool isFullScreen =
                            plPlayerController?.isFullScreen.value == true;
                        final double expandedHeight =
                            orientation == Orientation.landscape || isFullScreen
                                ? (MediaQuery.sizeOf(context).height -
                                    (orientation == Orientation.landscape
                                        ? 0
                                        : MediaQuery.of(context).padding.top))
                                : videoHeight.value;
                        if (orientation == Orientation.landscape ||
                            isFullScreen) {
                          enterFullScreen();
                        } else {
                          exitFullScreen();
                        }
                        return SliverAppBar(
                          automaticallyImplyLeading: false,
                          pinned: true,
                          elevation: 0,
                          scrolledUnderElevation: 0,
                          forceElevated: innerBoxIsScrolled,
                          expandedHeight: expandedHeight,
                          backgroundColor: Colors.black,
                          flexibleSpace: FlexibleSpaceBar(
                            background: PopScope(
                              canPop: plPlayerController?.isFullScreen.value !=
                                  true,
                              onPopInvokedWithResult:
                                  (bool didPop, dynamic result) {
                                if (plPlayerController?.isFullScreen.value ==
                                    true) {
                                  plPlayerController!
                                      .triggerFullScreen(status: false);
                                }
                                if (MediaQuery.of(context).orientation ==
                                    Orientation.landscape) {
                                  verticalScreen();
                                }
                              },
                              child: LayoutBuilder(
                                builder: (BuildContext context,
                                    BoxConstraints constraints) {
                                  return Hero(
                                    tag: heroTag,
                                    child: Stack(
                                      children: <Widget>[
                                        Obx(
                                          () => isShowing.value
                                              ? buildVideoPlayerPanel()
                                              : const SizedBox(),
                                        ),

                                        /// 关闭自动播放时 手动播放
                                        Obx(
                                          () => Visibility(
                                            visible: !vdCtr.autoPlay.value &&
                                                vdCtr.isShowCover.value,
                                            child: Positioned(
                                              top: 0,
                                              left: 0,
                                              right: 0,
                                              child: handlePlayPanel(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ];
                },

                /// 不收回
                pinnedHeaderSliverHeightBuilder: () {
                  return MediaQuery.of(context).orientation ==
                              Orientation.landscape ||
                          plPlayerController?.isFullScreen.value == true
                      ? MediaQuery.sizeOf(context).height
                      : playerStatus.value != PlayerStatus.playing
                          ? kToolbarHeight
                          : pinnedHeaderHeight;
                },
                onlyOneScrollInBody: true,
                body: Column(
                  children: [
                    tabbarBuild(),
                    Expanded(
                      child: TabBarView(
                        controller: vdCtr.tabCtr,
                        children: <Widget>[
                          Builder(
                            builder: (BuildContext context) {
                              return CustomScrollView(
                                key: const PageStorageKey<String>('简介'),
                                slivers: <Widget>[
                                  if (vdCtr.videoType == SearchType.video) ...[
                                    VideoIntroPanel(bvid: vdCtr.bvid),
                                  ] else if (vdCtr.videoType ==
                                      SearchType.media_bangumi) ...[
                                    Obx(() => BangumiIntroPanel(
                                        cid: vdCtr.cid.value)),
                                  ],
                                  SliverToBoxAdapter(
                                    child: Divider(
                                      indent: 12,
                                      endIndent: 12,
                                      color: Theme.of(context)
                                          .dividerColor
                                          .withValues(alpha: 0.06),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          Obx(
                            () => VideoReplyPanel(
                              bvid: vdCtr.bvid,
                              oid: vdCtr.oid.value,
                              onControllerCreated: vdCtr.onControllerCreated,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// 重新进入会刷新
            // 播放完成/暂停播放
            StreamBuilder(
              stream: appbarStream.stream.distinct(),
              initialData: 0,
              builder: ((context, snapshot) {
                return ScrollAppBar(
                  snapshot.data!.toDouble(),
                  () => continuePlay(),
                  playerStatus.value,
                  null,
                );
              }),
            ),

            /// 稍后再看列表
            Obx(
              () => Visibility(
                visible: vdCtr.sourceType.value == 'watchLater' ||
                    vdCtr.sourceType.value == 'fav',
                child: AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  left: 32,
                  bottom: vdCtr.isWatchLaterVisible.value
                      ? MediaQuery.of(context).padding.bottom + 32
                      : -100,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        vdCtr.toggeleWatchLaterVisible(
                            !vdCtr.isWatchLaterVisible.value);
                        vdCtr.showMediaListPanel();
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(14)),
                      child: Container(
                        width: Get.size.width - 64,
                        height: 54,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondaryContainer
                              .withValues(alpha: 0.95),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(14)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(children: [
                          const Icon(Icons.playlist_play, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            vdCtr.watchLaterTitle.value,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.keyboard_arrow_up_rounded, size: 26),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    /// 宽屏布局
    Widget buildWideScreenLayout() {
      return SafeArea(
        top: MediaQuery.of(context).orientation == Orientation.portrait &&
            plPlayerController?.isFullScreen.value == true,
        bottom: MediaQuery.of(context).orientation == Orientation.portrait &&
            plPlayerController?.isFullScreen.value == true,
        left: false,
        right: false,
        child: Stack(
          children: [
            Scaffold(
              resizeToAvoidBottomInset: false,
              key: vdCtr.scaffoldKey,
              backgroundColor: Theme.of(context).colorScheme.surface,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(0),
                child: StreamBuilder(
                  stream: appbarStream.stream.distinct(),
                  initialData: 0,
                  builder: ((context, snapshot) {
                    return AppBar(
                      backgroundColor: Colors.black,
                      elevation: 0,
                      scrolledUnderElevation: 0,
                      systemOverlayStyle: Get.isDarkMode
                          ? SystemUiOverlayStyle.light
                          : snapshot.data!.toDouble() > kToolbarHeight
                              ? SystemUiOverlayStyle.dark
                              : SystemUiOverlayStyle.light,
                    );
                  }),
                ),
              ),
              body: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 左侧播放器
                  Expanded(
                    flex: 2,
                    child: CustomScrollView(
                      slivers: [
                        Obx(
                          () {
                            final Orientation orientation =
                                MediaQuery.of(context).orientation;
                            final bool isFullScreen =
                                plPlayerController?.isFullScreen.value == true;
                            final double expandedHeight = orientation ==
                                        Orientation.landscape ||
                                    isFullScreen
                                ? (MediaQuery.sizeOf(context).height -
                                    (orientation == Orientation.landscape
                                        ? 0
                                        : MediaQuery.of(context).padding.top))
                                : videoHeight.value;
                            if (orientation == Orientation.landscape ||
                                isFullScreen) {
                              enterFullScreen();
                            } else {
                              exitFullScreen();
                            }
                            return SliverAppBar(
                              automaticallyImplyLeading: false,
                              pinned: true,
                              elevation: 0,
                              scrolledUnderElevation: 0,
                              forceElevated: false,
                              expandedHeight: expandedHeight,
                              backgroundColor: Colors.black,
                              flexibleSpace: FlexibleSpaceBar(
                                background: PopScope(
                                  canPop:
                                      plPlayerController?.isFullScreen.value !=
                                          true,
                                  onPopInvokedWithResult:
                                      (bool didPop, dynamic result) {
                                    if (plPlayerController
                                            ?.isFullScreen.value ==
                                        true) {
                                      plPlayerController!
                                          .triggerFullScreen(status: false);
                                    }
                                    if (MediaQuery.of(context).orientation ==
                                        Orientation.landscape) {
                                      verticalScreen();
                                    }
                                  },
                                  child: LayoutBuilder(
                                    builder: (BuildContext context,
                                        BoxConstraints constraints) {
                                      return Hero(
                                        tag: heroTag,
                                        child: Stack(
                                          children: <Widget>[
                                            Obx(
                                              () => isShowing.value
                                                  ? buildVideoPlayerPanel()
                                                  : const SizedBox(),
                                            ),

                                            /// 关闭自动播放时 手动播放
                                            Obx(
                                              () => Visibility(
                                                visible:
                                                    !vdCtr.autoPlay.value &&
                                                        vdCtr.isShowCover.value,
                                                child: Positioned(
                                                  top: 0,
                                                  left: 0,
                                                  right: 0,
                                                  child: handlePlayPanel(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // 右侧内容区
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          Expanded(
                            child: buildRightContentPanel(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// 重新进入会刷新
            // 播放完成/暂停播放
            StreamBuilder(
              stream: appbarStream.stream.distinct(),
              initialData: 0,
              builder: ((context, snapshot) {
                return ScrollAppBar(
                  snapshot.data!.toDouble(),
                  () => continuePlay(),
                  playerStatus.value,
                  null,
                );
              }),
            ),

            /// 稍后再看列表
            Obx(
              () => Visibility(
                visible: vdCtr.sourceType.value == 'watchLater' ||
                    vdCtr.sourceType.value == 'fav',
                child: AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  left: 32,
                  bottom: vdCtr.isWatchLaterVisible.value
                      ? MediaQuery.of(context).padding.bottom + 32
                      : -100,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        vdCtr.toggeleWatchLaterVisible(
                            !vdCtr.isWatchLaterVisible.value);
                        vdCtr.showMediaListPanel();
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(14)),
                      child: Container(
                        width: (Get.size.width * 2 / 3) - 64,
                        height: 54,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondaryContainer
                              .withValues(alpha: 0.95),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(14)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(children: [
                          const Icon(Icons.playlist_play, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            vdCtr.watchLaterTitle.value,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.keyboard_arrow_up_rounded, size: 26),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return isWideScreen ? buildWideScreenLayout() : buildNarrowScreenLayout();
  }
}
