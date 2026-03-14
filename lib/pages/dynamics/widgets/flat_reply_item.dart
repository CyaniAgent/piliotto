import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/models/video/reply/item.dart';
import 'package:piliotto/utils/utils.dart';

class FlatReplyItem extends StatelessWidget {
  final ReplyItemModel replyItem;

  const FlatReplyItem({
    super.key,
    required this.replyItem,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final heroTag = Utils.makeHeroTag(replyItem.mid);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 8, 5),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: colorScheme.onInverseSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Get.toNamed('/member?mid=${replyItem.mid}', arguments: {
                'face': replyItem.member?.avatar,
                'heroTag': heroTag,
              });
            },
            child: Hero(
              tag: heroTag,
              child: NetworkImgLayer(
                src: replyItem.member?.avatar,
                width: 34,
                height: 34,
                type: 'avatar',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.toNamed('/member?mid=${replyItem.mid}', arguments: {
                      'face': replyItem.member?.avatar,
                      'heroTag': heroTag,
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        replyItem.member?.uname ?? '未知用户',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.outline,
                        ),
                      ),
                      if (replyItem.member?.ottohubData?['honour'] != null &&
                          replyItem.member!.ottohubData!['honour']
                              .toString()
                              .isNotEmpty)
                        ...replyItem.member!.ottohubData!['honour']
                            .toString()
                            .split(',')
                            .where((e) => e.trim().isNotEmpty)
                            .map((title) => Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    title.trim(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                ))
                            .toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Utils.dateFormat(replyItem.ctime),
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  replyItem.content?.message ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
