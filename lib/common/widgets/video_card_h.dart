import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/image_save.dart';

import '../../api/models/video.dart';
import '../../services/ottohub_service.dart';
import '../../utils/utils.dart';
import '../constants.dart';
import 'badge.dart';
import 'network_img_layer.dart';
import 'stat/danmu.dart';
import 'stat/view.dart';

class VideoCardH extends StatelessWidget {
  const VideoCardH({
    super.key,
    required this.videoItem,
    this.onPressedFn,
    this.source = 'normal',
    this.showOwner = true,
    this.showView = true,
    this.showDanmaku = true,
    this.showPubdate = false,
    this.showCharge = false,
    this.rankIndex,
  });
  final dynamic videoItem;
  final Function()? onPressedFn;
  final String source;
  final bool showOwner;
  final bool showView;
  final bool showDanmaku;
  final bool showPubdate;
  final bool showCharge;
  final int? rankIndex;

  int get _videoId {
    if (videoItem is Video) {
      return videoItem.vid;
    }
    return videoItem.vid ?? videoItem.aid ?? 0;
  }

  String get _coverUrl {
    if (videoItem is Video) {
      return videoItem.coverUrl ?? '';
    }
    return videoItem.pic ?? videoItem.coverUrl ?? '';
  }

  String get _title {
    if (videoItem is Video) {
      return videoItem.title ?? '';
    }
    return videoItem.title ?? '';
  }

  String get _ownerName {
    if (videoItem is Video) {
      return videoItem.username ?? '';
    }
    return videoItem.owner?.name ?? videoItem.author ?? '';
  }

  int get _viewCount {
    if (videoItem is Video) {
      return videoItem.viewCount ?? 0;
    }
    return videoItem.stat?.view ?? videoItem.play ?? 0;
  }

  int? get _danmakuCount {
    if (videoItem is Video) {
      return null;
    }
    return videoItem.stat?.danmaku ?? videoItem.videoReview ?? 0;
  }

  int get _duration {
    if (videoItem is Video) {
      return videoItem.duration ?? 0;
    }
    final dur = videoItem.duration ?? videoItem.length;
    if (dur is int) return dur;
    if (dur is String) return int.tryParse(dur) ?? 0;
    return 0;
  }

  int? get _pubdate {
    if (videoItem is Video) {
      final time = videoItem.time;
      if (time is int) return time;
      if (time is String) {
        final dt = DateTime.tryParse(time);
        return dt != null ? dt.millisecondsSinceEpoch ~/ 1000 : null;
      }
      return null;
    }
    return videoItem.pubdate ?? videoItem.created;
  }

  @override
  Widget build(BuildContext context) {
    final String heroTag = Utils.makeHeroTag(_videoId);
    return InkWell(
      onTap: () async {
        Get.toNamed('/video?vid=$_videoId', arguments: {
          'pic': _coverUrl,
          'heroTag': heroTag,
        });
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            StyleString.safeSpace, 5, StyleString.safeSpace, 5),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints boxConstraints) {
            final double width = (boxConstraints.maxWidth -
                    StyleString.cardSpace *
                        6 /
                        MediaQuery.textScalerOf(context).scale(1.0)) /
                2;
            return Container(
              constraints: const BoxConstraints(minHeight: 88),
              height: width / StyleString.aspectRatio,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: StyleString.aspectRatio,
                    child: LayoutBuilder(
                      builder: (BuildContext context,
                          BoxConstraints boxConstraints) {
                        final double maxWidth = boxConstraints.maxWidth;
                        final double maxHeight = boxConstraints.maxHeight;
                        return Stack(
                          children: [
                            Hero(
                              tag: heroTag,
                              child: NetworkImgLayer(
                                src: _coverUrl,
                                width: maxWidth,
                                height: maxHeight,
                              ),
                            ),
                            if (rankIndex != null && rankIndex! <= 3)
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: rankIndex == 1
                                        ? const Color(0xFFFFD700)
                                        : rankIndex == 2
                                            ? const Color(0xFFC0C0C0)
                                            : const Color(0xFFCD7F32),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(8),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$rankIndex',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            if (rankIndex != null && rankIndex! > 3)
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(8),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$rankIndex',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            if (_duration > 0)
                              PBadge(
                                text: Utils.timeFormat(_duration),
                                right: 6.0,
                                bottom: 6.0,
                                type: 'gray',
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 6, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _title,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          if (showPubdate && _pubdate != null)
                            Text(
                              Utils.dateFormat(_pubdate!),
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.outline),
                            ),
                          if (showOwner)
                            Row(
                              children: [
                                Text(
                                  _ownerName,
                                  style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .fontSize,
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          Row(
                            children: [
                              if (showView) ...[
                                StatView(view: _viewCount),
                                const SizedBox(width: 8),
                              ],
                              if (showDanmaku && _danmakuCount != null)
                                StatDanMu(danmu: _danmakuCount),
                              const Spacer(),
                              if (source == 'normal')
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      feedBack();
                                      showModalBottomSheet(
                                        context: context,
                                        useRootNavigator: true,
                                        isScrollControlled: true,
                                        builder: (context) {
                                          return MorePanel(
                                              videoItem: videoItem);
                                        },
                                      );
                                    },
                                    icon: Icon(
                                      Icons.more_vert_outlined,
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              if (source == 'later') ...[
                                IconButton(
                                  style: ButtonStyle(
                                    padding: WidgetStateProperty.all(
                                        EdgeInsets.zero),
                                  ),
                                  onPressed: () => onPressedFn?.call(),
                                  icon: Icon(
                                    Icons.clear_outlined,
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                    size: 18,
                                  ),
                                )
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class MorePanel extends StatelessWidget {
  final dynamic videoItem;
  const MorePanel({super.key, required this.videoItem});

  String get _ownerName {
    if (videoItem is Video) {
      return videoItem.username ?? '';
    }
    return videoItem.owner?.name ?? videoItem.author ?? '';
  }

  int get _ownerId {
    if (videoItem is Video) {
      return videoItem.uid;
    }
    return videoItem.owner?.mid ?? videoItem.mid ?? 0;
  }

  void blockUser() async {
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          content:
              Text('确定拉黑:$_ownerName($_ownerId)?\n\n注：被拉黑的Up可以在隐私设置-黑名单管理中解除'),
          actions: [
            TextButton(
              onPressed: () => SmartDialog.dismiss(),
              child: Text(
                '点错了',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await OttohubService.blockUser(blockedId: _ownerId);
                  SmartDialog.dismiss();
                  SmartDialog.showToast('拉黑成功');
                } catch (error) {
                  SmartDialog.dismiss();
                  SmartDialog.showToast('拉黑失败: $error');
                }
              },
              child: const Text('确认'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => Get.back(),
            child: Container(
              height: 35,
              padding: const EdgeInsets.only(bottom: 2),
              child: Center(
                child: Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline,
                      borderRadius: const BorderRadius.all(Radius.circular(3))),
                ),
              ),
            ),
          ),
          ListTile(
            onTap: () async => blockUser(),
            minLeadingWidth: 0,
            leading: const Icon(Icons.block, size: 19),
            title: Text(
              '拉黑up主 「$_ownerName」',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ListTile(
            onTap: () =>
                imageSaveDialog(context, videoItem, SmartDialog.dismiss),
            minLeadingWidth: 0,
            leading: const Icon(Icons.photo_outlined, size: 19),
            title:
                Text('查看视频封面', style: Theme.of(context).textTheme.titleSmall),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
