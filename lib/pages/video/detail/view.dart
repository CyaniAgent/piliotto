import 'dart:async';
import 'dart:io';

import 'package:floating/floating.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';

import 'package:piliotto/pages/danmaku/view.dart';
import 'package:piliotto/pages/main/view.dart';
import 'package:piliotto/pages/video/detail/reply/index.dart';
import 'package:piliotto/pages/video/detail/provider.dart';
import 'package:piliotto/pages/video/detail/introduction/index.dart';

import 'package:piliotto/plugin/pl_player/index.dart';
import 'package:piliotto/plugin/pl_player/models/play_repeat.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:piliotto/utils/route_arguments.dart';
import 'package:status_bar_control_plus/status_bar_control_plus.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../../plugin/pl_player/models/bottom_control_type.dart';
import '../../../services/shutdown_timer_service.dart';

import 'widgets/app_bar.dart';

class VideoDetailPage extends ConsumerStatefulWidget {
  const VideoDetailPage({super.key});

  @override
  ConsumerState<VideoDetailPage> createState() => _VideoDetailPageState();
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();
}

class _VideoDetailPageState extends ConsumerState<VideoDetailPage>
    with TickerProviderStateMixin, RouteAware, WidgetsBindingObserver {
  PlPlayerController? plPlayerController;
  final ScrollController _extendNestCtr = ScrollController();
  late StreamController<double> appbarStream;
  late String heroTag;
  final FocusNode _keyboardFocusNode = FocusNode();

  PlayerStatus playerStatus = PlayerStatus.playing;
  double doubleOffset = 0;
  double videoHeight = 0;

  late double statusBarHeight;
  late Future _futureBuilderFuture;
  late bool autoExitFullcreen;
  late bool autoPlayEnable;
  late bool autoPiP;
  Floating? floating;
  bool isShowing = true;
  late final AppLifecycleListener _lifecycleListener;
  late double statusHeight;

  @override
  void initState() {
    super.initState();
    getStatusHeight();
    heroTag = routeArguments['heroTag'] ?? 'default';
    
    try {
      statusBarHeight = GStrorage.localCache.get('statusBarHeight') ?? 0.0;
      autoExitFullcreen = GStrorage.setting
          .get(SettingBoxKey.enableAutoExit, defaultValue: false);
      autoPlayEnable = GStrorage.setting
          .get(SettingBoxKey.autoPlayEnable, defaultValue: true);
      autoPiP =
          GStrorage.setting.get(SettingBoxKey.autoPiP, defaultValue: false);
    } catch (_) {
      statusBarHeight = 0.0;
      autoExitFullcreen = false;
      autoPlayEnable = true;
      autoPiP = false;
    }

    videoHeight = WidgetsBinding
            .instance.platformDispatcher.views.first.physicalSize.width /
        WidgetsBinding
            .instance.platformDispatcher.views.first.devicePixelRatio *
        9 /
        16;
    videoSourceInit();
    appbarStreamListen();
    if (Platform.isAndroid) {
      final notifier = ref.read(videoDetailProvider.notifier);
      floating = notifier.floating;
    }
    WidgetsBinding.instance.addObserver(this);
    lifecycleListener();
  }

  Future<void> videoSourceInit() async {
    final vdNotifier = ref.read(videoDetailProvider.notifier);
    _futureBuilderFuture = vdNotifier.getVideoDetail();
    final vdState = ref.read(videoDetailProvider);
    if (vdState.autoPlay) {
      plPlayerController = vdNotifier.plPlayerController;
      plPlayerController?.addStatusLister(playerListener);
      fullScreenStatusListener();
    }
  }

  void appbarStreamListen() {
    appbarStream = StreamController<double>.broadcast();
    _extendNestCtr.addListener(
      () {
        final double offset = _extendNestCtr.position.pixels;
        final screenHeight = WidgetsBinding
                .instance.platformDispatcher.views.first.physicalSize.height /
            WidgetsBinding
                .instance.platformDispatcher.views.first.devicePixelRatio;
        final vdNotifier = ref.read(videoDetailProvider.notifier);
        vdNotifier.setSheetHeight(
            screenHeight - videoHeight - statusBarHeight + offset);
        appbarStream.add(offset);
      },
    );
  }

  void playerListener(PlayerStatus status) async {
    playerStatus = status;
    autoEnterPip(status: status);
    if (status == PlayerStatus.completed) {
      if (autoExitFullcreen) {
        plPlayerController?.triggerFullScreen(status: false);
      }
      shutdownTimerService.handleWaitingFinished();

      if (plPlayerController?.playRepeat != PlayRepeat.pause &&
          plPlayerController?.playRepeat != PlayRepeat.singleCycle) {
        final vdState = ref.read(videoDetailProvider);
        if (vdState.videoType == 'video') {
          final introNotifier = ref.read(videoIntroProvider(vdState.vid).notifier);
          introNotifier.nextPlay();
        }
      }

      if (plPlayerController?.playRepeat == PlayRepeat.singleCycle) {
        plPlayerController?.seekTo(Duration.zero);
        plPlayerController?.play();
      }
      try {
        final vdNotifier = ref.read(videoDetailProvider.notifier);
        PiPStatus currentStatus = await vdNotifier.floating!.pipStatus;
        if (currentStatus == PiPStatus.disabled) {
          plPlayerController?.onLockControl(false);
        }
      } catch (_) {}
    }
    if (Platform.isAndroid && floating != null) {
      if (status == PlayerStatus.playing && autoPiP) {
        floating!.enable(const OnLeavePiP());
      } else {
        floating!.cancelOnLeavePiP();
      }
    }
  }

  void continuePlay() async {
    await _extendNestCtr.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    plPlayerController?.play();
  }

  Future<void> handlePlay() async {
    final vdNotifier = ref.read(videoDetailProvider.notifier);
    await vdNotifier.playerInit(autoplay: true);
    plPlayerController = vdNotifier.plPlayerController;
    plPlayerController?.addStatusLister(playerListener);
    vdNotifier.setAutoPlay(true);
    vdNotifier.setIsShowCover(false);
    isShowing = true;
    autoEnterPip(status: PlayerStatus.playing);
  }

  void fullScreenStatusListener() {
    plPlayerController?.isFullScreen.listen((bool isFullScreen) {
      final vdNotifier = ref.read(videoDetailProvider.notifier);
      if (isFullScreen) {
        vdNotifier.hiddenReplyReplyPanel();
      }
      if (!isFullScreen) {
        final vdState = ref.read(videoDetailProvider);
        if (vdState.bottomList.contains(BottomControlType.episode)) {
          final newList = List<BottomControlType>.from(vdState.bottomList);
          newList.removeAt(3);
          vdNotifier.setBottomList(newList);
        }
      }
    });
  }

  Future<void> getStatusHeight() async {
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      try {
        statusHeight = await StatusBarControlPlus.getHeight;
      } catch (e) {
        statusHeight = 0;
      }
    } else {
      statusHeight = 0;
    }
  }

  @override
  void dispose() {
    shutdownTimerService.handleWaitingFinished();
    final vdNotifier = ref.read(videoDetailProvider.notifier);
    if (plPlayerController != null) {
      plPlayerController!.removeStatusLister(playerListener);
      plPlayerController!.dispose();
    }
    if (Platform.isAndroid && floating != null) {
      floating!.cancelOnLeavePiP();
    }
    appbarStream.close();
    WidgetsBinding.instance.removeObserver(this);
    _lifecycleListener.dispose();
    _keyboardFocusNode.dispose();
    vdNotifier.dispose();
    super.dispose();
  }

  @override
  void didPushNext() async {
    final mainState = ref.read(mainAppProvider);
    if (mainState.imgPreviewStatus) {
      return;
    }

    bool enableAutoBrightness = false;
    try {
      enableAutoBrightness = GStrorage.setting
          .get(SettingBoxKey.enableAutoBrightness, defaultValue: false) as bool;
    } catch (_) {}
    final vdNotifier = ref.read(videoDetailProvider.notifier);
    if (enableAutoBrightness && plPlayerController != null) {
      vdNotifier.setBrightness(plPlayerController!.brightness.value);
    }
    if (plPlayerController != null) {
      vdNotifier.setDefaultST(plPlayerController!.position.value);
      plPlayerController!.removeStatusLister(playerListener);
      plPlayerController!.pause();
    }
    isShowing = false;
    super.didPushNext();
  }

  @override
  void didPopNext() async {
    final mainState = ref.read(mainAppProvider);
    if (mainState.imgPreviewStatus) {
      return;
    }

    final vdState = ref.read(videoDetailProvider);
    final vdNotifier = ref.read(videoDetailProvider.notifier);
    if (plPlayerController != null &&
        plPlayerController!.videoPlayerController != null) {
      isShowing = true;
    }
    vdNotifier.setIsFirstTime(false);
    final bool autoplay = autoPlayEnable;
    vdNotifier.playerInit();

    vdNotifier.setAutoPlay(!vdState.isShowCover);
    if (_extendNestCtr.hasClients &&
        _extendNestCtr.position.pixels == 0 &&
        autoplay) {
      await Future.delayed(const Duration(milliseconds: 300));
      plPlayerController?.seekTo(vdState.defaultST);
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
    final String routePath = GoRouterState.of(context).matchedLocation;
    if (autoPiP && routePath.startsWith('/video') && floating != null) {
      if (status == PlayerStatus.playing) {
        floating!.enable(const OnLeavePiP());
      } else {
        floating!.cancelOnLeavePiP();
      }
    }
  }

  void lifecycleListener() {
    _lifecycleListener = AppLifecycleListener(
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
          final vdNotifier = ref.read(videoDetailProvider.notifier);
          vdNotifier.hiddenReplyReplyPanel();
        }
        break;
    }
  }

  Widget handlePlayPanel() {
    final vdState = ref.watch(videoDetailProvider);
    return Stack(
      children: [
        GestureDetector(
          onTap: handlePlay,
          child: NetworkImgLayer(
            src: vdState.cover,
            width: MediaQuery.of(context).size.width,
            height: videoHeight,
            type: 'emote',
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

  Widget buildCustomAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
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

  Widget tabbarBuild() {
    final vdState = ref.watch(videoDetailProvider);
    final vdNotifier = ref.read(videoDetailProvider.notifier);
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
        color: Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: vdNotifier.tabController != null
                  ? TabBar(
                      padding: EdgeInsets.zero,
                      controller: vdNotifier.tabController!,
                      labelStyle: const TextStyle(fontSize: 13),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                      dividerColor: Colors.transparent,
                      tabs:
                          vdState.tabs.map((String name) => Tab(text: name)).toList(),
                      onTap: (index) => vdNotifier.onTapTabbar(index),
                    )
                  : const SizedBox(),
            ),
            Flexible(
              flex: 1,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedOpacity(
                      opacity: playerStatus != PlayerStatus.playing ? 1 : 0,
                      duration: const Duration(milliseconds: 100),
                      child: const Icon(
                        Icons.drag_handle_rounded,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 32,
                      child: TextButton(
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(EdgeInsets.zero),
                        ),
                        onPressed: () => vdNotifier.showShootDanmakuSheet(),
                        child:
                            const Text('发弹幕', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    SizedBox(
                      width: 38,
                      height: 38,
                      child: !vdState.isShowCover
                          ? IconButton(
                              onPressed: () {
                                if (plPlayerController != null) {
                                  plPlayerController!.isOpenDanmu.value =
                                      !(plPlayerController?.isOpenDanmu.value ??
                                          false);
                                }
                              },
                              icon: !(plPlayerController?.isOpenDanmu.value ??
                                      false)
                                  ? SvgPicture.asset(
                                      'assets/images/video/danmu_close.svg',
                                      colorFilter: ColorFilter.mode(
                                        Theme.of(context).colorScheme.outline,
                                        BlendMode.srcIn,
                                      ),
                                    )
                                  : SvgPicture.asset(
                                      'assets/images/video/danmu_open.svg',
                                      colorFilter: ColorFilter.mode(
                                        Theme.of(context).colorScheme.primary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                            )
                          : IconButton(
                              icon: SvgPicture.asset(
                                'assets/images/video/danmu_close.svg',
                                colorFilter: ColorFilter.mode(
                                  Theme.of(context).colorScheme.outline,
                                  BlendMode.srcIn,
                                ),
                              ),
                              onPressed: () {},
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
    final double defaultVideoHeight = sizeContext.width * 9 / 16;
    final bool isWideScreen = sizeContext.width > 768;
    final vdState = ref.watch(videoDetailProvider);
    final vdNotifier = ref.read(videoDetailProvider.notifier);

    if (vdNotifier.tabController == null) {
      vdNotifier.initTabController(this);
    }

    Widget buildLoadingWidget() {
      return Center(
        child: SizedBox(
          width: 120,
          child: LinearProgressIndicator(
            minHeight: 4,
            borderRadius: const BorderRadius.all(Radius.circular(2)),
            color: Theme.of(context).colorScheme.primary,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.24),
          ),
        ),
      );
    }

    Widget buildVideoPlayerWidget() {
      return !vdState.autoPlay
          ? const SizedBox()
          : PLVideoPlayer(
              controller: plPlayerController!,
              headerControl: vdNotifier.headerControl,
              danmuWidget: PlDanmaku(
                key: Key(vdState.vid.toString()),
                vid: vdState.vid,
                playerController: plPlayerController!,
              ),
              bottomList: vdState.bottomList,
            );
    }

    Widget buildErrorWidget() {
      return SizedBox(
        height: videoHeight,
        width: sizeContext.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('加载失败', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            IconButton.filled(
              onPressed: () {
                setState(() {
                  _futureBuilderFuture = vdNotifier.getVideoDetail();
                });
              },
              icon: const Icon(Icons.refresh),
            )
          ],
        ),
      );
    }

    Widget buildVideoPlayerPanel() {
      return FutureBuilder(
        future: _futureBuilderFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildLoadingWidget();
          } else if (snapshot.connectionState == ConnectionState.done) {
            return vdState.isEffective
                ? buildVideoPlayerWidget()
                : buildErrorWidget();
          } else {
            return buildErrorWidget();
          }
        },
      );
    }

    Widget buildRightContentPanel() {
      return Scaffold(
        key: vdNotifier.rightContentScaffoldKey,
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Column(
          children: [
            tabbarBuild(),
            Expanded(
              child: vdNotifier.tabController != null
                  ? TabBarView(
                      controller: vdNotifier.tabController!,
                      children: <Widget>[
                        Builder(
                          builder: (BuildContext context) {
                            return CustomScrollView(
                              key: const PageStorageKey<String>('简介'),
                              slivers: <Widget>[
                                if (vdState.videoType == 'video') ...[
                                  VideoIntroPanel(vid: vdState.vid),
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
                        VideoReplyPanel(
                          vid: vdState.vid,
                          onControllerCreated: vdNotifier.onControllerCreated,
                        )
                      ],
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      );
    }

    Widget buildNarrowScreenLayout() {
      final bool isFullScreen =
          plPlayerController?.isFullScreen.value == true;
      return SafeArea(
        top: MediaQuery.of(context).orientation == Orientation.portrait &&
            isFullScreen,
        bottom: MediaQuery.of(context).orientation == Orientation.portrait &&
            isFullScreen,
        left: false,
        right: false,
        child: Stack(
          children: [
            Scaffold(
              resizeToAvoidBottomInset: false,
              key: vdNotifier.scaffoldKey,
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
                      systemOverlayStyle: Theme.of(context).brightness ==
                              Brightness.dark
                          ? SystemUiOverlayStyle.light
                          : snapshot.data!.toDouble() > kToolbarHeight
                              ? SystemUiOverlayStyle.dark
                              : SystemUiOverlayStyle.light,
                    );
                  }),
                ),
              ),
              body: Builder(
                builder: (context) {
                  final Orientation orientation =
                      MediaQuery.of(context).orientation;
                  final bool isFullScreen =
                      plPlayerController?.isFullScreen.value == true;

                  if (isFullScreen) {
                    return SizedBox(
                      height: MediaQuery.sizeOf(context).height,
                      width: MediaQuery.sizeOf(context).width,
                      child: Hero(
                        tag: heroTag,
                        child: buildVideoPlayerPanel(),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      SizedBox(
                        height: orientation == Orientation.landscape
                            ? MediaQuery.sizeOf(context).height
                            : defaultVideoHeight,
                        width: sizeContext.width,
                        child: Hero(
                          tag: heroTag,
                          child: Stack(
                            children: <Widget>[
                              isShowing
                                  ? buildVideoPlayerPanel()
                                  : const SizedBox(),
                              Visibility(
                                visible: !vdState.autoPlay &&
                                    vdState.isShowCover,
                                child: handlePlayPanel(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      tabbarBuild(),
                      Expanded(
                        child: vdNotifier.tabController != null
                            ? TabBarView(
                                controller: vdNotifier.tabController!,
                                children: <Widget>[
                                  Builder(
                                    builder: (BuildContext context) {
                                      return CustomScrollView(
                                        key: const PageStorageKey<String>('简介'),
                                        physics: const ClampingScrollPhysics(),
                                        slivers: <Widget>[
                                          if (vdState.videoType == 'video') ...[
                                            VideoIntroPanel(vid: vdState.vid),
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
                                  VideoReplyPanel(
                                    vid: vdState.vid,
                                    onControllerCreated: vdNotifier.onControllerCreated,
                                  )
                                ],
                              )
                            : const SizedBox(),
                      ),
                    ],
                  );
                },
              ),
            ),
            StreamBuilder(
              stream: appbarStream.stream.distinct(),
              initialData: 0,
              builder: ((context, snapshot) {
                return ScrollAppBar(
                  snapshot.data!.toDouble(),
                  () => continuePlay(),
                  playerStatus,
                  null,
                );
              }),
            ),
          ],
        ),
      );
    }

    Widget buildWideScreenLayout() {
      final bool isFullScreen =
          plPlayerController?.isFullScreen.value == true;

      if (isFullScreen) {
        return SizedBox(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          child: Hero(
            tag: heroTag,
            child: buildVideoPlayerPanel(),
          ),
        );
      }

      return SafeArea(
        top: false,
        bottom: false,
        left: false,
        right: false,
        child: Stack(
          children: [
            Scaffold(
              resizeToAvoidBottomInset: false,
              key: vdNotifier.scaffoldKey,
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
                      systemOverlayStyle: Theme.of(context).brightness ==
                              Brightness.dark
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
                  Expanded(
                    flex: 2,
                    child: CustomScrollView(
                      slivers: [
                        Builder(
                          builder: (context) {
                            final Orientation orientation =
                                MediaQuery.of(context).orientation;
                            final bool isFullScreen =
                                plPlayerController?.isFullScreen.value ==
                                    true;
                            final double expandedHeight = orientation ==
                                        Orientation.landscape ||
                                    isFullScreen
                                ? (MediaQuery.sizeOf(context).height -
                                    (orientation == Orientation.landscape
                                        ? 0
                                        : MediaQuery.of(context).padding.top))
                                : defaultVideoHeight;
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
                                  canPop: plPlayerController
                                          ?.isFullScreen.value !=
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
                                            isShowing
                                                ? buildVideoPlayerPanel()
                                                : const SizedBox(),
                                            Visibility(
                                              visible: !vdState.autoPlay &&
                                                  vdState.isShowCover,
                                              child: Positioned(
                                                top: 0,
                                                left: 0,
                                                right: 0,
                                                child: handlePlayPanel(),
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
                  Expanded(
                    flex: 1,
                    child: buildRightContentPanel(),
                  ),
                ],
              ),
            ),
            StreamBuilder(
              stream: appbarStream.stream.distinct(),
              initialData: 0,
              builder: ((context, snapshot) {
                return ScrollAppBar(
                  snapshot.data!.toDouble(),
                  () => continuePlay(),
                  playerStatus,
                  null,
                );
              }),
            ),
          ],
        ),
      );
    }

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          _handleKeyEvent(event.logicalKey);
        }
      },
      child: isWideScreen ? buildWideScreenLayout() : buildNarrowScreenLayout(),
    );
  }

  void _handleKeyEvent(LogicalKeyboardKey key) {
    if (plPlayerController == null) return;

    if (key == LogicalKeyboardKey.space) {
      plPlayerController!.togglePlay();
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      final current = plPlayerController!.position.value;
      plPlayerController!.seekTo(current - const Duration(seconds: 5));
    } else if (key == LogicalKeyboardKey.arrowRight) {
      final current = plPlayerController!.position.value;
      plPlayerController!.seekTo(current + const Duration(seconds: 5));
    } else if (key == LogicalKeyboardKey.arrowUp) {
      plPlayerController!
          .setVolume((plPlayerController!.volume.value + 0.1).clamp(0.0, 1.0));
    } else if (key == LogicalKeyboardKey.arrowDown) {
      plPlayerController!
          .setVolume((plPlayerController!.volume.value - 0.1).clamp(0.0, 1.0));
    } else if (key == LogicalKeyboardKey.keyF) {
      plPlayerController!
          .triggerFullScreen(status: !plPlayerController!.isFullScreen.value);
    } else if (key == LogicalKeyboardKey.escape) {
      if (plPlayerController!.isFullScreen.value) {
        plPlayerController!.triggerFullScreen(status: false);
      }
    }
  }
}

void verticalScreen() {
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
}
