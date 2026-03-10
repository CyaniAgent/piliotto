import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/models/live/item.dart';
import 'package:piliotto/models/member/info.dart';

class ProfilePanel extends StatelessWidget {
  final dynamic ctr;
  final bool loadingStatus;
  const ProfilePanel({
    super.key,
    required this.ctr,
    this.loadingStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    MemberInfoModel memberInfo = ctr.memberInfo.value;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    return Builder(
      builder: ((context) {
        return Padding(
          padding: EdgeInsets.only(
              top: max(0.0, MediaQuery.of(context).padding.top - 10)),
          child: Row(
            children: [
              Hero(
                tag: ctr.heroTag!,
                child: Stack(
                  children: [
                    NetworkImgLayer(
                      width: 80,
                      height: 80,
                      type: 'avatar',
                      src: !loadingStatus ? memberInfo.face : ctr.face.value,
                    ),
                    if (!loadingStatus &&
                        memberInfo.liveRoom != null &&
                        memberInfo.liveRoom!.liveStatus == 1)
                      Positioned(
                        bottom: 0,
                        left: 10,
                        child: GestureDetector(
                          onTap: () {
                            LiveItemModel liveItem = LiveItemModel.fromJson({
                              'title': memberInfo.liveRoom!.title,
                              'uname': memberInfo.name,
                              'face': memberInfo.face,
                              'roomid': memberInfo.liveRoom!.roomId,
                              'watched_show': memberInfo.liveRoom!.watchedShow,
                            });
                            Get.toNamed(
                              '/liveRoom?roomid=${memberInfo.liveRoom!.roomId}',
                              arguments: {'liveItem': liveItem},
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Row(children: [
                              Image.asset(
                                'assets/images/live.gif',
                                height: 10,
                              ),
                              Text(
                                ' 直播中',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .labelSmall!
                                        .fontSize),
                              )
                            ]),
                          ),
                        ),
                      )
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            Get.toNamed(
                                '/follow?mid=${memberInfo.mid}&name=${memberInfo.name}');
                          },
                          child: Column(
                            children: [
                              Text(
                                !loadingStatus
                                    ? memberInfo.attention?.toString() ?? '-'
                                    : '-',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface),
                              ),
                              Text(
                                '关注',
                                style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .fontSize,
                                    color: colorScheme.outline),
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.toNamed(
                                '/fan?mid=${memberInfo.mid}&name=${memberInfo.name}');
                          },
                          child: Column(
                            children: [
                              Text(
                                  !loadingStatus
                                      ? memberInfo.fans?.toString() ?? '-'
                                      : '-',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface)),
                              Text(
                                '粉丝',
                                style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .fontSize,
                                    color: colorScheme.outline),
                              )
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                                '-',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface)),
                            Text(
                              '获赞',
                              style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .fontSize,
                                  color: colorScheme.outline),
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (ctr.ownerMid != ctr.mid && ctr.ownerMid != -1) ...[
                      Row(
                        children: [
                          Obx(
                            () => Expanded(
                              child: TextButton(
                                onPressed: () => loadingStatus
                                    ? null
                                    : ctr.actionRelationMod(),
                                style: TextButton.styleFrom(
                                  foregroundColor: ctr.attribute.value == -1
                                      ? Colors.transparent
                                      : ctr.attribute.value != 0
                                          ? colorScheme.outline
                                          : colorScheme.onPrimary,
                                  backgroundColor: ctr.attribute.value != 0
                                      ? colorScheme.surfaceContainerHighest
                                      : colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Obx(() => Text(ctr.attributeText.value)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Get.toNamed(
                                  '/whisperDetail',
                                  parameters: {
                                    'name': memberInfo.name!,
                                    'face': memberInfo.face!,
                                    'mid': memberInfo.mid.toString(),
                                    'heroTag': ctr.heroTag!,
                                  },
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: colorScheme.surfaceContainerHighest,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('发消息'),
                            ),
                          )
                        ],
                      )
                    ],
                    if (ctr.ownerMid == ctr.mid && ctr.ownerMid != -1) ...[
                      TextButton(
                        onPressed: () {
                          SmartDialog.showToast('功能开发中 💪');
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          foregroundColor: colorScheme.onPrimary,
                          backgroundColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('编辑资料'),
                      )
                    ],
                    if (ctr.ownerMid == -1) ...[
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          foregroundColor: colorScheme.outline,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('未登录'),
                      )
                    ]
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
