import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:piliotto/common/constants.dart';
import 'package:piliotto/pages/video/detail/index.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/common/widgets/stat/danmu.dart';
import 'package:piliotto/common/widgets/stat/view.dart';
import 'package:piliotto/pages/video/detail/introduction/controller.dart';

import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/global_data_cache.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:piliotto/utils/utils.dart';
import 'widgets/action_item.dart';
import 'widgets/fav_panel.dart';

class VideoIntroPanel extends StatefulWidget {
  final int vid;

  const VideoIntroPanel({super.key, required this.vid});

  @override
  State<VideoIntroPanel> createState() => _VideoIntroPanelState();
}

class _VideoIntroPanelState extends State<VideoIntroPanel>
    with AutomaticKeepAliveClientMixin {
  late String heroTag;
  late VideoIntroController videoIntroController;
  late Future? _futureBuilderFuture;

  // 添加页面缓存
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    /// fix 全屏时参数丢失
    heroTag = Get.arguments?['heroTag'] ?? 'default_${widget.vid}';
    videoIntroController =
        Get.put(VideoIntroController(vid: widget.vid), tag: heroTag);
    _futureBuilderFuture = videoIntroController.queryVideoIntro();
  }

  @override
  void dispose() {
    videoIntroController.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: _futureBuilderFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // 请求完成
          return Obx(
            () => VideoInfo(
              videoDetail: videoIntroController.videoDetail.value,
              heroTag: heroTag,
              vid: widget.vid,
            ),
          );
        } else {
          return SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: Center(
                child: Lottie.asset(
                  'assets/loading.json',
                  width: 200,
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class VideoInfo extends StatefulWidget {
  final dynamic videoDetail;
  final String? heroTag;
  final int vid;

  const VideoInfo({
    Key? key,
    this.videoDetail,
    this.heroTag,
    required this.vid,
  }) : super(key: key);

  @override
  State<VideoInfo> createState() => _VideoInfoState();
}

class _VideoInfoState extends State<VideoInfo> with TickerProviderStateMixin {
  late String heroTag;
  late final VideoIntroController videoIntroController;
  VideoDetailController? videoDetailCtr;
  final Box<dynamic> localCache = GStrorage.localCache;
  final Box<dynamic> setting = GStrorage.setting;
  late double sheetHeight;
  late int mid;
  late String memberHeroTag;

  bool isProcessing = false;
  RxBool isExpand = false.obs;
  late ExpandableController _expandableCtr;

  void Function()? handleState(Future<dynamic> Function() action) {
    return isProcessing
        ? null
        : () async {
            isProcessing = true;
            await action.call();
            isProcessing = false;
          };
  }

  @override
  void initState() {
    super.initState();
    heroTag = widget.heroTag!;
    videoIntroController =
        Get.put(VideoIntroController(vid: widget.vid), tag: heroTag);
    // 延迟获取 VideoDetailController，确保它已经被创建
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        videoDetailCtr = Get.find<VideoDetailController>(tag: heroTag);
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        print('VideoDetailController not found: $e');
      }
    });
    sheetHeight = localCache.get('sheetHeight');

    _expandableCtr = ExpandableController(initialExpanded: false);
  }

  // 收藏
  showFavBottomSheet({type = 'tap'}) {
    if (videoIntroController.userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    final bool enableDragQuickFav =
        setting.get(SettingBoxKey.enableQuickFav, defaultValue: false);
    // 快速收藏 &
    // 点按 收藏至默认文件夹
    // 长按选择文件夹
    if (enableDragQuickFav) {
      if (type == 'tap') {
        if (!videoIntroController.hasFav.value) {
          videoIntroController.actionFavVideo(type: 'default');
        } else {
          _showFavPanel();
        }
      } else {
        _showFavPanel();
      }
    } else if (type != 'longPress') {
      _showFavPanel();
    }
  }

  void _showFavPanel() {
    showFlexibleBottomSheet(
      bottomSheetBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      minHeight: 0.6,
      initHeight: 0.6,
      maxHeight: 1,
      context: context,
      builder: (BuildContext context, ScrollController scrollController,
          double offset) {
        return FavPanel(
          ctr: videoIntroController,
          scrollController: scrollController,
        );
      },
      anchors: [0.6, 1],
      isSafeArea: true,
    );
  }

  // 视频介绍
  showIntroDetail() {
    feedBack();
    isExpand.value = !(isExpand.value);
    _expandableCtr.toggle();
  }

  // 用户主页
  onPushMember() {
    feedBack();
    if (widget.videoDetail.uid != null) {
      mid = widget.videoDetail.uid!;
      memberHeroTag = Utils.makeHeroTag(mid);
      String face = widget.videoDetail.avatarUrl ?? '';
      Get.toNamed('/member?mid=$mid',
          arguments: {'face': face, 'heroTag': memberHeroTag});
    }
  }

  @override
  void dispose() {
    _expandableCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final Color outline = t.colorScheme.outline;
    return SliverPadding(
      padding: const EdgeInsets.only(
        left: StyleString.safeSpace,
        right: StyleString.safeSpace,
        top: 16,
      ),
      sliver: SliverToBoxAdapter(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => showIntroDetail(),
            onLongPress: () async {
              feedBack();
              await Clipboard.setData(
                  ClipboardData(text: widget.videoDetail.title!));
              SmartDialog.showToast('标题已复制');
            },
            child: ExpandablePanel(
              controller: _expandableCtr,
              collapsed: Text(
                widget.videoDetail.title!,
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              expanded: Text(
                widget.videoDetail.title!,
                softWrap: true,
                maxLines: 10,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              theme: const ExpandableThemeData(
                animationDuration: Duration(milliseconds: 300),
                scrollAnimationDuration: Duration(milliseconds: 300),
                crossFadePoint: 0,
                fadeCurve: Curves.ease,
                sizeCurve: Curves.linear,
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => showIntroDetail(),
            child: Padding(
              padding: const EdgeInsets.only(top: 7, bottom: 6),
              child: Row(
                children: [
                  StatView(
                    view: widget.videoDetail.viewCount ?? 0,
                    size: 'medium',
                  ),
                  const SizedBox(width: 10),
                  const StatDanMu(
                    danmu: 0,
                    size: 'medium',
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.videoDetail.time ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: t.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (videoIntroController.isShowOnlineTotal)
                    Obx(
                      () => Text(
                        '${videoIntroController.total.value}人在看',
                        style: TextStyle(
                          fontSize: 12,
                          color: t.colorScheme.outline,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          /// 视频简介
          ExpandablePanel(
            controller: _expandableCtr,
            collapsed: const SizedBox(height: 0),
            expanded: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                widget.videoDetail.intro ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: t.colorScheme.onSurface,
                ),
              ),
            ),
            theme: const ExpandableThemeData(
              animationDuration: Duration(milliseconds: 300),
              scrollAnimationDuration: Duration(milliseconds: 300),
              crossFadePoint: 0,
              fadeCurve: Curves.ease,
              sizeCurve: Curves.linear,
            ),
          ),

          /// 点赞收藏转发
          Material(child: actionGrid(context, videoIntroController)),

          // 作者信息
          GestureDetector(
            onTap: () {
              if (widget.videoDetail.uid != null) {
                mid = widget.videoDetail.uid!;
                memberHeroTag = Utils.makeHeroTag(mid);
                String face = widget.videoDetail.avatarUrl ?? '';
                Get.toNamed('/member?mid=$mid',
                    arguments: {'face': face, 'heroTag': memberHeroTag});
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Row(
                children: [
                  NetworkImgLayer(
                    type: 'avatar',
                    src: widget.videoDetail.avatarUrl,
                    width: 34,
                    height: 34,
                    fadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                  ),
                  const SizedBox(width: 10),
                  Text(widget.videoDetail.username!,
                      style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Obx(
                    () => Text(
                      Utils.numFormat(videoIntroController.follower.value),
                      style: TextStyle(
                        fontSize: t.textTheme.labelSmall!.fontSize,
                        color: outline,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Obx(
                    () {
                      final bool isFollowed =
                          videoIntroController.followStatus.value;
                      return SizedBox(
                        height: 32,
                        child: TextButton(
                          onPressed: videoIntroController.actionRelationMod,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.only(
                              left: 8,
                              right: 8,
                            ),
                            foregroundColor:
                                isFollowed ? outline : t.colorScheme.onPrimary,
                            backgroundColor: isFollowed
                                ? t.colorScheme.onInverseSurface
                                : t.colorScheme.primary, // 设置按钮背景色
                          ),
                          child: Text(
                            isFollowed ? '已关注' : '关注',
                            style: TextStyle(
                              fontSize: t.textTheme.labelMedium!.fontSize,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }

  Widget actionGrid(BuildContext context, videoIntroController) {
    final actionTypeSort = GlobalDataCache().actionTypeSort;

    Map<String, Widget> menuListWidgets = {
      'like': Obx(
        () => ActionItem(
          icon: const Icon(FontAwesomeIcons.thumbsUp),
          selectIcon: const Icon(FontAwesomeIcons.solidThumbsUp),
          onTap: handleState(videoIntroController.actionLikeVideo),
          onLongPress: () => videoIntroController.oneThreeDialog(),
          selectStatus: videoIntroController.hasLike.value,
          text: (widget.videoDetail.likeCount ?? 0).toString(),
        ),
      ),
      'collect': Obx(
        () => ActionItem(
          icon: const Icon(FontAwesomeIcons.star),
          selectIcon: const Icon(FontAwesomeIcons.solidStar),
          onTap: () => showFavBottomSheet(),
          onLongPress: () => showFavBottomSheet(type: 'longPress'),
          selectStatus: videoIntroController.hasFav.value,
          text: (widget.videoDetail.favoriteCount ?? 0).toString(),
        ),
      ),
      'share': ActionItem(
        icon: const Icon(FontAwesomeIcons.shareFromSquare),
        onTap: () => videoIntroController.actionShareVideo(),
        selectStatus: false,
        text: '分享',
      ),
    };
    final List<Widget> list = [];
    for (var i = 0; i < actionTypeSort.length; i++) {
      if (menuListWidgets.containsKey(actionTypeSort[i])) {
        list.add(menuListWidgets[actionTypeSort[i]]!);
      }
    }

    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 4),
      child: Row(
        children: list.map((item) => Expanded(child: item)).toList(),
      ),
    );
  }
}
