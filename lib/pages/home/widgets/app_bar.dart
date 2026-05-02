import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/pages/home/provider.dart';
import 'package:piliotto/utils/storage.dart';

class HomeAppBar extends ConsumerWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    dynamic userInfo;
    try {
      userInfo = GStrorage.userInfo.get('userInfoCache');
    } catch (_) {
      userInfo = null;
    }
    final homeState = ref.watch(homeProvider);
    final isNarrowScreen = MediaQuery.of(context).size.width < 600;

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
                  leading: isNarrowScreen
                      ? GestureDetector(
                          onTap: () => Scaffold.of(context).openDrawer(),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: userInfo != null
                                ? NetworkImgLayer(
                                    type: 'avatar',
                                    width: 32,
                                    height: 32,
                                    src: userInfo.face,
                                  )
                                : const Icon(CupertinoIcons.person, size: 22),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: userInfo != null
                              ? NetworkImgLayer(
                                  type: 'avatar',
                                  width: 32,
                                  height: 32,
                                  src: userInfo.face,
                                )
                              : const Icon(CupertinoIcons.person, size: 22),
                        ),
                  leadingWidth: 50,
                  title: GestureDetector(
                    onTap: () => context.push('/search'),
                    child: Hero(
                      tag: 'searchBar',
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
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
                              child: Text(
                                homeState.defaultSearch.isEmpty
                                    ? '搜索视频'
                                    : homeState.defaultSearch,
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).colorScheme.outline,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
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
