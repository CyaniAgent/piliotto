// 转发
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/utils/utils.dart';

import 'additional_panel.dart';
import 'article_panel.dart';
import 'live_panel.dart';
import 'live_rcmd_panel.dart';
import 'pic_panel.dart';
import 'rich_node_panel.dart';
import 'video_panel.dart';

Widget forWard(item, context, ctr, source, {floor = 1}) {
  TextStyle authorStyle =
      TextStyle(color: Theme.of(context).colorScheme.primary);
  switch (item.type) {
    // 图文
    case 'DYNAMIC_TYPE_DRAW':
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (floor == 2) ...[
            Row(
              children: [
                GestureDetector(
                  onTap: () => Get.toNamed(
                      '/member?mid=${item.modules.moduleAuthor.mid}',
                      arguments: {'face': item.modules.moduleAuthor.face}),
                  child: Text(
                    '@${item.modules.moduleAuthor.name}',
                    style: authorStyle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  Utils.dateFormat(item.modules.moduleAuthor.pubTs),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize:
                          Theme.of(context).textTheme.labelSmall!.fontSize),
                ),
              ],
            ),
            const SizedBox(height: 2),

            /// fix #话题跟content重复
            // if (item.modules.moduleDynamic.topic != null) ...[
            //   Padding(
            //     padding: floor == 2
            //         ? EdgeInsets.zero
            //         : const EdgeInsets.only(left: 12, right: 12),
            //     child: GestureDetector(
            //       child: Text(
            //         '#${item.modules.moduleDynamic.topic.name}',
            //         style: authorStyle,
            //       ),
            //     ),
            //   ),
            // ],
            Text.rich(
              richNode(item, context),
              // 被转发状态(floor=2) 隐藏
              maxLines: source == 'detail' && floor != 2 ? 999 : 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
          ],
          Padding(
            padding: floor == 2
                ? EdgeInsets.zero
                : const EdgeInsets.only(left: 12, right: 12),
            child: picWidget(item, context),
          ),

          /// 附加内容 商品信息、直播预约等等
          if (item.modules.moduleDynamic.additional != null)
            addWidget(
              item,
              context,
              item.modules.moduleDynamic.additional.type,
              floor: floor,
            )
        ],
      );
    // 视频
    case 'DYNAMIC_TYPE_AV':
      return videoSeasonWidget(item, context, 'archive', floor: floor);
    // 文章
    case 'DYNAMIC_TYPE_ARTICLE':
      return articlePanel(item, context, floor: floor);
    // 转发
    case 'DYNAMIC_TYPE_FORWARD':
      return InkWell(
        onTap: () => ctr.pushDetail(item.orig, floor + 1),
        child: Container(
          padding:
              const EdgeInsets.only(left: 15, top: 10, right: 15, bottom: 8),
          color: Theme.of(context).dividerColor.withOpacity(0.08),
          child: forWard(item.orig, context, ctr, source, floor: floor + 1),
        ),
      );
    // 直播
    case 'DYNAMIC_TYPE_LIVE_RCMD':
      return liveRcmdPanel(item, context, floor: floor);
    // 直播
    case 'DYNAMIC_TYPE_LIVE':
      return livePanel(item, context, floor: floor);
    // 合集
    case 'DYNAMIC_TYPE_UGC_SEASON':
      return videoSeasonWidget(item, context, 'ugcSeason');
    case 'DYNAMIC_TYPE_WORD':
      return floor == 2
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.toNamed(
                          '/member?mid=${item.modules.moduleAuthor.mid}',
                          arguments: {'face': item.modules.moduleAuthor.face}),
                      child: Text(
                        '@${item.modules.moduleAuthor.name}',
                        style: authorStyle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      Utils.dateFormat(item.modules.moduleAuthor.pubTs),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          fontSize:
                              Theme.of(context).textTheme.labelSmall!.fontSize),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text.rich(
                  richNode(item, context),
                  // 被转发状态(floor=2) 隐藏
                  maxLines: source == 'detail' && floor != 2 ? 999 : 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
          : item.modules.moduleDynamic.additional != null
              ? addWidget(
                  item,
                  context,
                  item.modules.moduleDynamic.additional.type,
                  floor: floor,
                )
              : const SizedBox(height: 0);
    case 'DYNAMIC_TYPE_PGC':
      return videoSeasonWidget(item, context, 'pgc', floor: floor);
    case 'DYNAMIC_TYPE_PGC_UNION':
      return videoSeasonWidget(item, context, 'pgc', floor: floor);
    // 直播结束
    case 'DYNAMIC_TYPE_NONE':
      return Row(
        children: [
          const Icon(
            FontAwesomeIcons.ghost,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(item.modules.moduleDynamic.major.none.tips)
        ],
      );
    // 课堂
    case 'DYNAMIC_TYPE_COURSES_SEASON':
      return Row(
        children: [
          Expanded(
            child: Text(
              "课堂💪：${item.modules.moduleDynamic.major.courses['title']}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      );
    // 活动
    case 'DYNAMIC_TYPE_COMMON_SQUARE':
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: InkWell(
          onTap: () {
            Get.toNamed('/webview', parameters: {
              'url': item.modules.moduleDynamic.major.common['jump_url'],
              'type': 'url',
              'pageTitle': item.modules.moduleDynamic.major.common['title']
            });
          },
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.only(left: 12, top: 10, right: 12, bottom: 10),
            color: Theme.of(context).dividerColor.withOpacity(0.08),
            child: Row(
              children: [
                NetworkImgLayer(
                  width: 45,
                  height: 45,
                  src: item.modules.moduleDynamic.major.common['cover'],
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.modules.moduleDynamic.major.common['title'],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.modules.moduleDynamic.major.common['desc'],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize:
                            Theme.of(context).textTheme.labelMedium!.fontSize,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )
              ],
            ),
            // TextButton(onPressed: () {}, child: Text('123'))
          ),
        ),
      );
    case 'DYNAMIC_TYPE_MUSIC':
      final Map music = item.modules.moduleDynamic.major.music;
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: InkWell(
          onTap: () {
            Get.toNamed('/webview', parameters: {
              'url': "https:${music['jump_url']}",
              'type': 'url',
              'pageTitle': music['title']
            });
          },
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.only(left: 12, top: 10, right: 12, bottom: 10),
            color: Theme.of(context).dividerColor.withOpacity(0.08),
            child: Row(
              children: [
                NetworkImgLayer(
                  width: 45,
                  height: 45,
                  src: music['cover'],
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      music['title'],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      music['label'],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize:
                            Theme.of(context).textTheme.labelMedium!.fontSize,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )
              ],
            ),
            // TextButton(onPressed: () {}, child: Text('123'))
          ),
        ),
      );
    default:
      return const SizedBox(
        width: double.infinity,
        child: Text('🙏 暂未支持的类型，请联系开发者反馈 '),
      );
  }
}
