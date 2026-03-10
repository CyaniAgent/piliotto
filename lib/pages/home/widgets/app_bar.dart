import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/pages/mine/view.dart';
import 'package:piliotto/pages/home/controller.dart';
import 'package:piliotto/utils/storage.dart';

Box userInfoCache = GStrorage.userInfo;

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    var userInfo = userInfoCache.get('userInfoCache');
    final HomeController homeController = Get.find<HomeController>();
    return SliverAppBar(
      scrolledUnderElevation: 0,
      toolbarHeight: MediaQuery.of(context).padding.top,
      expandedHeight: kToolbarHeight + MediaQuery.of(context).padding.top,
      automaticallyImplyLeading: false,
      pinned: true,
      floating: true,
      primary: false,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          return FlexibleSpaceBar(
            background: Column(
              children: [
                AppBar(
                  centerTitle: false,
                  title: GestureDetector(
                    onTap: () => Get.toNamed('/search'),
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(
                            CupertinoIcons.search,
                            size: 18,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Obx(() => Text(
                              homeController.defaultSearch.value.isEmpty
                                  ? '搜索视频'
                                  : homeController.defaultSearch.value,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            )),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    if (userInfo != null) ...[
                      GestureDetector(
                        onTap: () => showModalBottomSheet(
                          context: context,
                          builder: (_) => const SizedBox(
                            height: 450,
                            child: MinePage(),
                          ),
                          clipBehavior: Clip.hardEdge,
                          isScrollControlled: true,
                        ),
                        child: NetworkImgLayer(
                          type: 'avatar',
                          width: 32,
                          height: 32,
                          src: userInfo.face,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ] else ...[
                      IconButton(
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          builder: (_) => const SizedBox(
                            height: 450,
                            child: MinePage(),
                          ),
                          clipBehavior: Clip.hardEdge,
                          isScrollControlled: true,
                        ),
                        icon: const Icon(CupertinoIcons.person, size: 22),
                      ),
                    ],
                    const SizedBox(width: 10)
                  ],
                  elevation: 0,
                  scrolledUnderElevation: 0,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
