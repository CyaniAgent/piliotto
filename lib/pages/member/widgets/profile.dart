import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/ottohub/models/member/info.dart';

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
          padding: const EdgeInsets.only(top: 1),
          child: Row(
            children: [
              Hero(
                tag: ctr.heroTag!,
                child: NetworkImgLayer(
                  width: 80,
                  height: 80,
                  type: 'avatar',
                  src: !loadingStatus ? memberInfo.face : ctr.face.value,
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
                            Text('-',
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
                                SmartDialog.showToast('私信功能暂不支持');
                              },
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    colorScheme.surfaceContainerHighest,
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
