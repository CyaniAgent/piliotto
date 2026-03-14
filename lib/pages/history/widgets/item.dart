import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:piliotto/api/models/video.dart';
import 'package:piliotto/common/constants.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/utils/utils.dart';

class HistoryItem extends StatelessWidget {
  final Video videoItem;

  const HistoryItem({
    super.key,
    required this.videoItem,
  });

  @override
  Widget build(BuildContext context) {
    final String heroTag = Utils.makeHeroTag(videoItem.vid);

    return InkWell(
      onTap: () {
        Get.toNamed('/video?vid=${videoItem.vid}', arguments: {
          'heroTag': heroTag,
          'pic': videoItem.coverUrl,
        });
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            StyleString.safeSpace, 5, StyleString.safeSpace, 5),
        child: LayoutBuilder(
          builder: (context, boxConstraints) {
            double width =
                (boxConstraints.maxWidth - StyleString.cardSpace * 6) / 2;
            return SizedBox(
              height: width / StyleString.aspectRatio,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: StyleString.aspectRatio,
                    child: LayoutBuilder(
                      builder: (context, boxConstraints) {
                        double maxWidth = boxConstraints.maxWidth;
                        double maxHeight = boxConstraints.maxHeight;
                        return Stack(
                          children: [
                            Hero(
                              tag: heroTag,
                              child: NetworkImgLayer(
                                src: videoItem.coverUrl,
                                width: maxWidth,
                                height: maxHeight,
                              ),
                            ),
                            if (videoItem.duration != null &&
                                videoItem.duration! > 0)
                              Positioned(
                                right: 6.0,
                                bottom: 8.0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    Utils.timeFormat(videoItem.duration!),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  _VideoContent(videoItem: videoItem),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VideoContent extends StatelessWidget {
  final Video videoItem;

  const _VideoContent({
    required this.videoItem,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 2, 6, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              videoItem.title,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            if (videoItem.username.isNotEmpty)
              Row(
                children: [
                  Text(
                    videoItem.username,
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.labelMedium!.fontSize,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  videoItem.time,
                  style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.labelMedium!.fontSize,
                      color: Theme.of(context).colorScheme.outline),
                ),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    tooltip: '功能菜单',
                    icon: Icon(
                      Icons.more_vert_outlined,
                      color: Theme.of(context).colorScheme.outline,
                      size: 14,
                    ),
                    position: PopupMenuPosition.under,
                    onSelected: (String type) {},
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        onTap: () {
                          SmartDialog.showToast('Ottohub API 不支持删除历史记录');
                        },
                        value: 'delete',
                        height: 35,
                        child: const Row(
                          children: [
                            Icon(Icons.close_outlined, size: 16),
                            SizedBox(width: 6),
                            Text('删除记录', style: TextStyle(fontSize: 13))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
