import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:piliotto/common/constants.dart';
import 'package:piliotto/common/skeleton/video_card_h.dart';
import 'package:piliotto/common/widgets/http_error.dart';
import 'package:piliotto/common/widgets/video_card_h.dart';
import 'package:piliotto/pages/rank/zone/provider.dart';

class ZonePage extends ConsumerStatefulWidget {
  const ZonePage({super.key, required this.rid});

  final int rid;

  @override
  ConsumerState<ZonePage> createState() => _ZonePageState();
}

class _ZonePageState extends ConsumerState<ZonePage>
    with AutomaticKeepAliveClientMixin {
  Future<Map<String, dynamic>>? _futureBuilderFuture;
  late ScrollController scrollController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final notifier = ref.read(zoneProvider.notifier);
    scrollController = notifier.scrollController;
    scrollController.addListener(_onScroll);
    _futureBuilderFuture = notifier.queryRankFeed('init', widget.rid);
  }

  void _onScroll() {
    final notifier = ref.read(zoneProvider.notifier);
    final state = ref.read(zoneProvider);
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (!state.isLoadingMore) {
        notifier.onLoad(widget.rid);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(zoneProvider.notifier).updateCrossAxisCount();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ZonePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(zoneProvider.notifier).updateCrossAxisCount();
      }
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final zoneState = ref.watch(zoneProvider);
    final notifier = ref.read(zoneProvider.notifier);
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = screenWidth > 768;
    double maxContentWidth = 800;

    return RefreshIndicator(
      onRefresh: () async {
        await notifier.onRefresh(widget.rid);
      },
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(StyleString.safeSpace,
                StyleString.safeSpace - 5, StyleString.safeSpace, 0),
            sliver: FutureBuilder(
              future: _futureBuilderFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  Map data = snapshot.data as Map;
                  if (data['status']) {
                    return SliverGrid(
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: zoneState.crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 3 / 1,
                      ),
                      delegate:
                          SliverChildBuilderDelegate((context, index) {
                        return VideoCardH(
                          videoItem: zoneState.videoList[index],
                          showPubdate: true,
                        );
                      }, childCount: zoneState.videoList.length),
                    );
                  } else {
                    return SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWideScreen
                            ? (screenWidth - maxContentWidth) / 2
                            : 0,
                      ),
                      sliver: HttpError(
                        isSliver: true,
                        errMsg: data['msg'],
                        fn: () {
                          setState(() {
                            _futureBuilderFuture =
                                notifier.queryRankFeed('init', widget.rid);
                          });
                        },
                      ),
                    );
                  }
                } else {
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: zoneState.crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 3 / 1,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return const VideoCardHSkeleton();
                    }, childCount: 10),
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
}
