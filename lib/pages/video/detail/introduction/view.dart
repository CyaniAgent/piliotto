import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:piliotto/common/constants.dart';
import 'package:piliotto/common/skeleton/video_intro.dart';
import 'package:piliotto/common/widgets/markdown_text.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/common/widgets/stat/danmu.dart';
import 'package:piliotto/common/widgets/stat/view.dart';
import 'package:piliotto/pages/video/detail/introduction/provider.dart';

import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/global_data_cache.dart';
import 'package:piliotto/utils/route_arguments.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:piliotto/utils/utils.dart';
import 'widgets/action_item.dart';

class VideoIntroPanel extends ConsumerStatefulWidget {
  final int vid;

  const VideoIntroPanel({super.key, required this.vid});

  @override
  ConsumerState<VideoIntroPanel> createState() => _VideoIntroPanelState();
}

class _VideoIntroPanelState extends ConsumerState<VideoIntroPanel>
    with AutomaticKeepAliveClientMixin {
  late String heroTag;
  late Future? _futureBuilderFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    heroTag = routeArguments['heroTag'] ?? 'default_${widget.vid}';
    _futureBuilderFuture = ref.read(videoIntroProvider(widget.vid).notifier).queryVideoIntro();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: _futureBuilderFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return VideoInfo(
            vid: widget.vid,
            heroTag: heroTag,
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

class VideoInfo extends ConsumerStatefulWidget {
  final String? heroTag;
  final int vid;

  const VideoInfo({
    super.key,
    this.heroTag,
    required this.vid,
  });

  @override
  ConsumerState<VideoInfo> createState() => _VideoInfoState();
}

class _VideoInfoState extends ConsumerState<VideoInfo>
    with AutomaticKeepAliveClientMixin {
  late String heroTag;
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
    heroTag = widget.heroTag ?? 'default_${widget.vid}';
    try {
      sheetHeight = GStrorage.localCache.get('sheetHeight') ?? 0.0;
    } catch (_) {
      sheetHeight = 0.0;
    }
  }

  void showFavBottomSheet({String type = 'tap'}) {
    final introState = ref.read(videoIntroProvider(widget.vid));
    if (introState.userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    ref.read(videoIntroProvider(widget.vid).notifier).actionFavVideo();
  }

  void onPushMember() {
    feedBack();
    final introState = ref.read(videoIntroProvider(widget.vid));
    if (introState.videoDetail?.uid != null) {
      mid = introState.videoDetail!.uid;
      memberHeroTag = Utils.makeHeroTag(mid);
      String face = introState.videoDetail?.avatarUrl ?? '';
      context.push('/member?mid=$mid',
          extra: {'face': face, 'heroTag': memberHeroTag});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ThemeData t = Theme.of(context);
    final Color outline = t.colorScheme.outline;
    final introState = ref.watch(videoIntroProvider(widget.vid));
    final introNotifier = ref.read(videoIntroProvider(widget.vid).notifier);
    final videoDetail = introState.videoDetail;

    if (videoDetail == null) {
      return const SliverToBoxAdapter(
        child: VideoIntroSkeleton(),
      );
    }

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
            videoDetail.title,
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
                  view: videoDetail.viewCount,
                  size: 'medium',
                ),
                const SizedBox(width: 10),
                StatDanMu(
                  danmu: 0,
                  size: 'medium',
                ),
                const SizedBox(width: 10),
                Text(
                  videoDetail.time,
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

          if (videoDetail.intro != null &&
              videoDetail.intro!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: MarkdownText(
                text: videoDetail.intro ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: t.colorScheme.onSurface,
                ),
              ),
            ),

          Material(child: actionGrid(context, introState, introNotifier)),

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
                  if (videoDetail.uid != 0) {
                    mid = videoDetail.uid;
                    memberHeroTag = Utils.makeHeroTag(mid);
                    String face = videoDetail.avatarUrl;
                    context.push('/member?mid=$mid',
                        extra: {'face': face, 'heroTag': memberHeroTag});
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      NetworkImgLayer(
                        type: 'avatar',
                        src: videoDetail.avatarUrl,
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
                              videoDetail.username,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${Utils.numFormat(introState.follower)} 粉丝',
                              style: TextStyle(
                                fontSize: 12,
                                color: outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 32,
                        child: FilledButton.tonal(
                          onPressed: introNotifier.actionRelationMod,
                          style: FilledButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            backgroundColor: introState.followStatus
                                ? t.colorScheme.surfaceContainerHighest
                                : null,
                          ),
                          child: Text(
                            introState.followStatus ? '已关注' : '关注',
                            style: TextStyle(
                              fontSize: 13,
                              color: introState.followStatus
                                  ? t.colorScheme.onSurfaceVariant
                                  : null,
                            ),
                          ),
                        ),
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

  Widget actionGrid(BuildContext context, VideoIntroState introState, VideoIntroNotifier introNotifier) {
    final actionTypeSort = GlobalDataCache().actionTypeSort;
    final videoDetail = introState.videoDetail;

    if (videoDetail == null) {
      return const SizedBox();
    }

    Map<String, Widget> menuListWidgets = {
      'like': ActionItem(
        icon: FontAwesomeIcons.thumbsUp,
        selectIcon: FontAwesomeIcons.solidThumbsUp,
        onTap: handleState(introNotifier.actionLikeVideo),
        onLongPress: () => introNotifier.oneThreeDialog(),
        selectStatus: introState.hasLike,
        text: videoDetail.likeCount.toString(),
      ),
      'collect': ActionItem(
        icon: FontAwesomeIcons.star,
        selectIcon: FontAwesomeIcons.solidStar,
        onTap: () => showFavBottomSheet(),
        onLongPress: () => showFavBottomSheet(type: 'longPress'),
        selectStatus: introState.hasFav,
        text: videoDetail.favoriteCount.toString(),
      ),
      'share': ActionItem(
        icon: FontAwesomeIcons.shareFromSquare,
        onTap: () => introNotifier.actionShareVideo(),
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
