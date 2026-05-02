import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:piliotto/common/constants.dart';
import 'package:piliotto/common/skeleton/video_card_h.dart';
import 'package:piliotto/common/widgets/http_error.dart';
import 'package:piliotto/common/widgets/video_card_h.dart';
import 'package:piliotto/pages/hot/provider.dart';
import 'package:piliotto/utils/main_stream.dart';
import 'package:piliotto/utils/responsive_util.dart';

class HotPage extends ConsumerStatefulWidget {
  const HotPage({super.key});

  @override
  ConsumerState<HotPage> createState() => _HotPageState();
}

class _HotPageState extends ConsumerState<HotPage>
    with AutomaticKeepAliveClientMixin {
  late Future _futureBuilderFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = ref.read(hotProvider.notifier).queryHotFeed(type: 'init');
    ref.read(hotProvider.notifier).scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final notifier = ref.read(hotProvider.notifier);
    final state = ref.read(hotProvider);
    if (notifier.scrollController.hasClients &&
        notifier.scrollController.position.pixels >=
            notifier.scrollController.position.maxScrollExtent - 200) {
      if (!state.isLoadingMore && state.noMore != '没有更多了') {
        notifier.onLoad();
      }
    }
    handleScrollEvent(notifier.scrollController, ref);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(hotProvider.notifier).updateCrossAxisCount();
      }
    });
  }

  @override
  void didUpdateWidget(covariant HotPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(hotProvider.notifier).updateCrossAxisCount();
      }
    });
  }

  @override
  void dispose() {
    ref.read(hotProvider.notifier).scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(hotProvider);
    final notifier = ref.read(hotProvider.notifier);
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = ResponsiveUtil.isMd;
    double maxContentWidth = 800;

    return RefreshIndicator(
      onRefresh: () async {
        return await notifier.onRefresh();
      },
      child: CustomScrollView(
        controller: notifier.scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: _buildTabBar(context, state, notifier),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(StyleString.safeSpace,
                StyleString.safeSpace - 5, StyleString.safeSpace, 0),
            sliver: FutureBuilder(
              future: _futureBuilderFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (state.videoList.isEmpty) {
                    return SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWideScreen
                            ? (screenWidth - maxContentWidth) / 2
                            : 0,
                      ),
                      sliver: HttpError(
                        isSliver: true,
                        errMsg: state.noMore == '加载失败'
                            ? '加载失败，请重试'
                            : '暂无数据',
                        fn: () {
                          setState(() {
                            _futureBuilderFuture =
                                notifier.queryHotFeed(type: 'init');
                          });
                        },
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWideScreen
                          ? (screenWidth - maxContentWidth) / 2
                          : 0,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: state.crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 3 / 1,
                      ),
                      delegate:
                          SliverChildBuilderDelegate((context, index) {
                        return VideoCardH(
                          videoItem: state.videoList[index],
                          showPubdate: true,
                        );
                      }, childCount: state.videoList.length),
                    ),
                  );
                } else {
                  return SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWideScreen
                          ? (screenWidth - maxContentWidth) / 2
                          : 0,
                    ),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: state.crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 3 / 1,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return const VideoCardHSkeleton();
                      }, childCount: 10),
                    ),
                  );
                }
              },
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.bottom + 10,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, HotState state, HotNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(notifier.tabs.length, (index) {
          final isSelected = state.currentTabIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(notifier.tabs[index]['label'] as String),
              selected: isSelected,
              onSelected: (_) {
                notifier.onTabChanged(index);
              },
            ),
          );
        }),
      ),
    );
  }
}
