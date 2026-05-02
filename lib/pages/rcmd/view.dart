import 'dart:async';

import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:piliotto/common/constants.dart';
import 'package:piliotto/common/skeleton/video_card_v.dart';
import 'package:piliotto/common/widgets/http_error.dart';
import 'package:piliotto/common/widgets/no_data.dart';
import 'package:piliotto/common/widgets/video_card_v.dart';
import 'package:piliotto/pages/rcmd/provider.dart';
import 'package:piliotto/utils/main_stream.dart';
import 'package:piliotto/utils/responsive_util.dart';

class RcmdPage extends ConsumerStatefulWidget {
  const RcmdPage({super.key});

  @override
  ConsumerState<RcmdPage> createState() => _RcmdPageState();
}

class _RcmdPageState extends ConsumerState<RcmdPage>
    with AutomaticKeepAliveClientMixin {
  Future? _futureBuilderFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final scrollController = ref.read(rcmdProvider.notifier).scrollController;
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          EasyThrottle.throttle(
              'my-throttler', const Duration(milliseconds: 200), () {
            ref.read(rcmdProvider.notifier).onLoad();
          });
        }
        handleScrollEvent(scrollController, ref);
      },
    );
    _futureBuilderFuture =
        ref.read(rcmdProvider.notifier).queryRcmdFeed('init');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(rcmdProvider.notifier).updateCrossAxisCount();
      }
    });
  }

  @override
  void didUpdateWidget(covariant RcmdPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(rcmdProvider.notifier).updateCrossAxisCount();
      }
    });
  }

  @override
  void dispose() {
    ref.read(rcmdProvider.notifier).scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(rcmdProvider);
    final notifier = ref.read(rcmdProvider.notifier);

    return Container(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.only(
          left: StyleString.safeSpace, right: StyleString.safeSpace),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(StyleString.imgRadius),
      ),
      child: FutureBuilder(
        future: _futureBuilderFuture,
        builder: (context, snapshot) {
          if (_futureBuilderFuture == null ||
              snapshot.connectionState == ConnectionState.none) {
            return contentGrid(state.copyWith(videoList: []), notifier);
          }
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null) {
              Map data = snapshot.data as Map;
              if (data['status']) {
                return RefreshIndicator(
                  onRefresh: () async {
                    await notifier.onRefresh();
                    await Future.delayed(const Duration(milliseconds: 300));
                  },
                  child: contentGrid(state, notifier),
                );
              } else {
                return HttpError(
                  errMsg: data['msg'],
                  fn: () {
                    setState(() {
                      _futureBuilderFuture = notifier.queryRcmdFeed('init');
                    });
                  },
                );
              }
            } else {
              return const NoData();
            }
          } else {
            return contentGrid(state.copyWith(videoList: []), notifier);
          }
        },
      ),
    );
  }

  Widget contentGrid(RcmdState state, RcmdNotifier notifier) {
    int crossAxisCount = state.crossAxisCount;
    double mainAxisExtent = ResponsiveUtil.calculateMainAxisExtent(
      crossAxisCount: crossAxisCount,
      aspectRatio: StyleString.aspectRatio,
      textHeight:
          crossAxisCount == 1 ? 68 : MediaQuery.textScalerOf(context).scale(86),
    );
    return GridView.builder(
      controller: notifier.scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: StyleString.safeSpace,
        crossAxisSpacing: StyleString.safeSpace,
        crossAxisCount: crossAxisCount,
        mainAxisExtent: mainAxisExtent,
      ),
      itemBuilder: (BuildContext context, int index) {
        return state.videoList.isNotEmpty
            ? VideoCardV(
                videoItem: state.videoList[index],
                crossAxisCount: crossAxisCount,
                blockUserCb: (mid) => notifier.blockUserCb(mid),
              )
            : const VideoCardVSkeleton();
      },
      itemCount: state.videoList.isNotEmpty ? state.videoList.length : 10,
      padding: const EdgeInsets.fromLTRB(
          0, StyleString.safeSpace, 0, StyleString.safeSpace),
    );
  }
}
