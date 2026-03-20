import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/image_save.dart';

import '../../models/model_rec_video_item.dart';
import '../../api/models/video.dart';
import '../../services/ottohub_service.dart';
import 'stat/danmu.dart';
import 'stat/view.dart';
// TODO: 迁移到 Ottohub API
// import '../../http/dynamics.dart';
import '../../http/video.dart';
import '../../utils/id_utils.dart';
import '../../utils/utils.dart';
import '../constants.dart';
import 'badge.dart';
import 'network_img_layer.dart';

// 视频卡片 - 垂直布局
class VideoCardV extends StatelessWidget {
  final dynamic videoItem;
  final int crossAxisCount;
  final Function? blockUserCb;

  const VideoCardV({
    Key? key,
    required this.videoItem,
    required this.crossAxisCount,
    this.blockUserCb,
  }) : super(key: key);

  bool isStringNumeric(String str) {
    RegExp numericRegex = RegExp(r'^\d+$');
    return numericRegex.hasMatch(str);
  }

  void onPushDetail(heroTag) async {
    // 处理Ottohub的Video模型
    if (videoItem is Video) {
      Get.toNamed('/video?vid=${videoItem.vid}', arguments: {
        'pic': videoItem.coverUrl,
        'heroTag': heroTag,
      });
      return;
    }

    // 处理旧的模型
    String goto = videoItem.goto;
    switch (goto) {
      case 'bangumi':
        SmartDialog.showToast('暂不支持番剧观看');
        return;
      case 'av':
        String bvid = videoItem.bvid ?? IdUtils.av2bv(videoItem.aid);
        Get.toNamed('/video?bvid=$bvid&cid=${videoItem.cid}', arguments: {
          // 'videoItem': videoItem,
          'pic': videoItem.pic,
          'heroTag': heroTag,
        });
        break;
      // 动态
      case 'picture':
        try {
          String uri = videoItem.uri;
          if (videoItem.uri.startsWith('bilibili://article/')) {
            // https://www.bilibili.com/read/cv27063554
            RegExp regex = RegExp(r'\d+');
            Match match = regex.firstMatch(videoItem.uri)!;
            String matchedNumber = match.group(0)!;
            videoItem.param = int.parse(matchedNumber);
          }
          if (uri.startsWith('http')) {
            String path = Uri.parse(uri).path;
            if (isStringNumeric(path.split('/')[1])) {
              // TODO: 迁移到 Ottohub OldApiService.getBlogDetail API
              // 请求接口
              // var res =
              //     await DynamicsHttp.dynamicDetail(id: path.split('/')[1]);
              // if (res['status']) {
              //   Get.toNamed('/dynamicDetail', arguments: {
              //     'item': res['data'],
              //     'floor': 1,
              //     'action': 'detail'
              //   });
              // }
              SmartDialog.showToast('TODO: 迁移到 Ottohub API');
              return;
            }
          }
          Get.toNamed('/read', parameters: {
            'title': videoItem.title,
            'id': videoItem.param,
            'articleType': 'read'
          });
        } catch (err) {
          SmartDialog.showToast(err.toString());
        }
        break;
      default:
        SmartDialog.showToast(videoItem.goto);
        Get.toNamed(
          '/webview',
          parameters: {
            'url': videoItem.uri,
            'type': 'url',
            'pageTitle': videoItem.title,
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 为不同模型生成heroTag
    String heroTag;
    if (videoItem is Video) {
      heroTag = Utils.makeHeroTag(videoItem.vid.toString());
    } else {
      heroTag = Utils.makeHeroTag(videoItem.id);
    }

    return InkWell(
      onTap: () async => onPushDetail(heroTag),
      onLongPress: () => imageSaveDialog(
        context,
        videoItem,
        SmartDialog.dismiss,
      ),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: StyleString.aspectRatio,
            child: LayoutBuilder(builder: (context, boxConstraints) {
              double maxWidth = boxConstraints.maxWidth;
              double maxHeight = boxConstraints.maxHeight;
              return Stack(
                children: [
                  Hero(
                    tag: heroTag,
                    child: NetworkImgLayer(
                      src: (videoItem is Video
                              ? videoItem.coverUrl
                              : videoItem.pic) ??
                          '',
                      width: maxWidth,
                      height: maxHeight,
                    ),
                  ),
                  // 显示视频时长
                  if ((videoItem is Video
                              ? videoItem.duration
                              : videoItem.duration) !=
                          null &&
                      (videoItem is Video
                              ? videoItem.duration
                              : videoItem.duration) >
                          0)
                    if (crossAxisCount == 1) ...[
                      PBadge(
                        bottom: 10,
                        right: 10,
                        text: Utils.timeFormat(videoItem is Video
                            ? videoItem.duration!
                            : videoItem.duration),
                      )
                    ] else ...[
                      PBadge(
                        bottom: 6,
                        right: 7,
                        size: 'small',
                        type: 'gray',
                        text: Utils.timeFormat(videoItem is Video
                            ? videoItem.duration!
                            : videoItem.duration),
                      )
                    ],
                ],
              );
            }),
          ),
          VideoContent(
            videoItem: videoItem,
            crossAxisCount: crossAxisCount,
            blockUserCb: blockUserCb,
          )
        ],
      ),
    );
  }
}

class VideoContent extends StatelessWidget {
  final dynamic videoItem;
  final int crossAxisCount;
  final Function? blockUserCb;

  const VideoContent({
    Key? key,
    required this.videoItem,
    required this.crossAxisCount,
    this.blockUserCb,
  }) : super(key: key);

  Widget _buildBadge(String text, String type, [double fs = 12]) {
    return PBadge(
      text: text,
      stack: 'normal',
      size: 'small',
      type: type,
      fs: fs,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: crossAxisCount == 1
          ? const EdgeInsets.fromLTRB(9, 9, 9, 4)
          : const EdgeInsets.fromLTRB(5, 8, 5, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            videoItem.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (crossAxisCount > 1) ...[
            const SizedBox(height: 2),
            VideoStat(videoItem: videoItem, crossAxisCount: crossAxisCount),
          ],
          if (crossAxisCount == 1) const SizedBox(height: 4),
          Row(
            children: [
              // 处理Ottohub的Video模型
              if (videoItem is Video) ...[
                // 可以添加Ottohub特有的徽章
              ] else ...[
                // 处理旧的模型
                if (videoItem.goto == 'bangumi')
                  _buildBadge(videoItem.bangumiBadge, 'line', 9),
                if (videoItem.rcmdReason != null)
                  _buildBadge(videoItem.rcmdReason, 'color'),
                if (videoItem.goto == 'picture') _buildBadge('动态', 'line', 9),
                if (videoItem.isFollowed == 1) _buildBadge('已关注', 'color'),
              ],
              Expanded(
                flex: crossAxisCount == 1 ? 0 : 1,
                child: Text(
                  videoItem is Video
                      ? videoItem.username
                      : videoItem.owner.name,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
              if (crossAxisCount == 1) ...[
                const SizedBox(width: 10),
                VideoStat(
                  videoItem: videoItem,
                  crossAxisCount: crossAxisCount,
                ),
                const Spacer(),
              ],
              // 显示更多按钮
              if (videoItem is! Video) ...[
                if (videoItem.goto == 'av')
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
                              videoItem: videoItem,
                              blockUserCb: blockUserCb,
                            );
                          },
                        );
                      },
                      icon: Icon(
                        Icons.more_vert_outlined,
                        color: Theme.of(context).colorScheme.outline,
                        size: 14,
                      ),
                    ),
                  )
              ] else ...[
                // 为Ottohub的Video模型添加更多按钮
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
                            videoItem: videoItem,
                            blockUserCb: blockUserCb,
                          );
                        },
                      );
                    },
                    icon: Icon(
                      Icons.more_vert_outlined,
                      color: Theme.of(context).colorScheme.outline,
                      size: 14,
                    ),
                  ),
                )
              ]
            ],
          ),
        ],
      ),
    );
  }
}

class VideoStat extends StatelessWidget {
  final dynamic videoItem;
  final int crossAxisCount;

  const VideoStat({
    Key? key,
    required this.videoItem,
    required this.crossAxisCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 处理Ottohub的Video模型
        if (videoItem is Video) ...[
          StatView(view: videoItem.viewCount),
          const SizedBox(width: 8),
          // Ottohub模型没有danmu字段，这里可以留空或者显示其他信息
          const SizedBox(width: 20), // 保持布局一致
          crossAxisCount > 1 ? const Spacer() : const SizedBox(width: 8),
          RichText(
            maxLines: 1,
            text: TextSpan(
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
                  color: Theme.of(context).colorScheme.outline,
                ),
                text: Utils.formatTimestampToRelativeTime(videoItem.time)),
          ),
          const SizedBox(width: 4),
        ] else ...[
          // 处理旧的模型
          StatView(view: videoItem.stat.view),
          const SizedBox(width: 8),
          StatDanMu(danmu: videoItem.stat.danmu),
          if (videoItem is RecVideoItemModel) ...<Widget>[
            crossAxisCount > 1 ? const Spacer() : const SizedBox(width: 8),
            RichText(
              maxLines: 1,
              text: TextSpan(
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  text: Utils.formatTimestampToRelativeTime(videoItem.pubdate)),
            ),
            const SizedBox(width: 4),
          ]
        ]
      ],
    );
  }
}

class MorePanel extends StatelessWidget {
  final dynamic videoItem;
  final Function? blockUserCb;
  const MorePanel({
    super.key,
    required this.videoItem,
    this.blockUserCb,
  });

  Future<dynamic> menuActionHandler(String type) async {
    switch (type) {
      case 'block':
        Get.back();
        blockUser();
        break;
      default:
    }
  }

  void blockUser() async {
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        // 获取用户名和ID
        String username;
        int userId;

        if (videoItem is Video) {
          username = videoItem.username;
          userId = videoItem.uid;
        } else {
          username = videoItem.owner.name;
          userId = videoItem.owner.mid;
        }

        return AlertDialog(
          title: const Text('提示'),
          content: Text('确定拉黑:$username($userId)?\n\n注：被拉黑的Up可以在隐私设置-黑名单管理中解除'),
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
                // 调用Ottohub的拉黑API
                if (videoItem is Video) {
                  // 使用Ottohub的blockUser方法
                  try {
                    await OttohubService.blockUser(
                      blockedId: userId,
                    );
                    SmartDialog.dismiss();
                    blockUserCb?.call(userId);
                    SmartDialog.showToast('拉黑成功');
                  } catch (error) {
                    SmartDialog.dismiss();
                    SmartDialog.showToast('拉黑失败: $error');
                  }
                } else {
                  // 使用旧的API
                  var res = await VideoHttp.relationMod(
                    mid: userId,
                    act: 5,
                    reSrc: 11,
                  );
                  SmartDialog.dismiss();
                  if (res['status']) {
                    blockUserCb?.call(userId);
                  }
                  SmartDialog.showToast(res['msg']);
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
            onTap: () async => await menuActionHandler('block'),
            minLeadingWidth: 0,
            leading: const Icon(Icons.block, size: 19),
            title: Text(
              '拉黑up主 「${videoItem is Video ? videoItem.username : videoItem.owner.name}」',
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
