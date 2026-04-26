import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/common/constants.dart';
import 'package:piliotto/common/skeleton/video_intro.dart';
import 'package:piliotto/pages/video/detail/index.dart';
import 'package:piliotto/common/widgets/markdown_text.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/common/widgets/stat/danmu.dart';
import 'package:piliotto/common/widgets/stat/view.dart';
import 'package:piliotto/pages/video/detail/introduction/controller.dart';

import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/global_data_cache.dart';
import 'package:piliotto/services/loggeer.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:piliotto/utils/utils.dart';
import 'widgets/action_item.dart';

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
          return Obx(
            () => VideoInfo(
              videoDetail: videoIntroController.videoDetail.value,
              heroTag: heroTag,
              vid: widget.vid,
            ),
          );
        } else {
          return const SliverToBoxAdapter(
            child: VideoIntroSkeleton(),
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
    super.key,
    this.videoDetail,
    this.heroTag,
    required this.vid,
  });

  @override
  State<VideoInfo> createState() => _VideoInfoState();
}

class _VideoInfoState extends State<VideoInfo>
    with AutomaticKeepAliveClientMixin {
  late String heroTag;
  late final VideoIntroController videoIntroController;
  VideoDetailController? videoDetailCtr;
  final Box<dynamic> localCache = GStrorage.localCache;
  final Box<dynamic> setting = GStrorage.setting;
  late double sheetHeight;
  late int mid;
  late String memberHeroTag;

  bool isProcessing = false;

  @override
  bool get wantKeepAlive => true;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        videoDetailCtr = Get.find<VideoDetailController>(tag: heroTag);
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        getLogger().d('VideoDetailController not found: $e');
      }
    });
    sheetHeight = localCache.get('sheetHeight');
  }

  // 收藏
  void showFavBottomSheet({String type = 'tap'}) {
    if (videoIntroController.userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    videoIntroController.actionFavVideo();
  }

  // 用户主页
  void onPushMember() {
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
  Widget build(BuildContext context) {
    super.build(context);
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
          SelectableText(
            widget.videoDetail.title!,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 7, bottom: 6),
            child: Row(
              children: [
                StatView(
                  view: widget.videoDetail.viewCount ?? 0,
                  size: 'medium',
                ),
                const SizedBox(width: 10),
                Obx(
                  () => StatDanMu(
                    danmu: videoIntroController.danmakuCount,
                    size: 'medium',
                  ),
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
                SelectableText(
                  'OV${widget.vid}',
                  style: TextStyle(
                    fontSize: 12,
                    color: t.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),

          /// 视频简介
          if (widget.videoDetail.intro != null &&
              widget.videoDetail.intro!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: MarkdownText(
                text: widget.videoDetail.intro ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: t.colorScheme.onSurface,
                ),
              ),
            ),

          /// 点赞收藏转发
          Material(child: actionGrid(context, videoIntroController)),

          // 作者信息
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: t.colorScheme.surfaceContainerHighest.withAlpha(100),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (widget.videoDetail.uid != null) {
                    mid = widget.videoDetail.uid!;
                    memberHeroTag = Utils.makeHeroTag(mid);
                    String face = widget.videoDetail.avatarUrl ?? '';
                    Get.toNamed('/member?mid=$mid',
                        arguments: {'face': face, 'heroTag': memberHeroTag});
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      NetworkImgLayer(
                        type: 'avatar',
                        src: widget.videoDetail.avatarUrl,
                        width: 40,
                        height: 40,
                        fadeInDuration: Duration.zero,
                        fadeOutDuration: Duration.zero,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.videoDetail.username!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Obx(
                              () => Text(
                                '${Utils.numFormat(videoIntroController.follower.value)} 粉丝',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: outline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Obx(
                        () {
                          final bool isFollowed =
                              videoIntroController.followStatus.value;
                          return SizedBox(
                            height: 32,
                            child: FilledButton.tonal(
                              onPressed: videoIntroController.actionRelationMod,
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                backgroundColor: isFollowed
                                    ? t.colorScheme.surfaceContainerHighest
                                    : null,
                              ),
                              child: Text(
                                isFollowed ? '已关注' : '关注',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isFollowed
                                      ? t.colorScheme.onSurfaceVariant
                                      : null,
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
          icon: FontAwesomeIcons.thumbsUp,
          selectIcon: FontAwesomeIcons.solidThumbsUp,
          onTap: handleState(videoIntroController.actionLikeVideo),
          onLongPress: () => videoIntroController.oneThreeDialog(),
          selectStatus: videoIntroController.hasLike.value,
          text: (widget.videoDetail.likeCount ?? 0).toString(),
        ),
      ),
      'collect': Obx(
        () => ActionItem(
          icon: FontAwesomeIcons.star,
          selectIcon: FontAwesomeIcons.solidStar,
          onTap: () => showFavBottomSheet(),
          onLongPress: () => showFavBottomSheet(type: 'longPress'),
          selectStatus: videoIntroController.hasFav.value,
          text: (widget.videoDetail.favoriteCount ?? 0).toString(),
        ),
      ),
      'share': ActionItem(
        icon: FontAwesomeIcons.shareFromSquare,
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
