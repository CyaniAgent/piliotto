import 'dart:async';

import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/api/models/video.dart';
import 'package:piliotto/common/constants.dart';
import 'package:piliotto/common/skeleton/video_card_v.dart';
import 'package:piliotto/common/widgets/http_error.dart';
import 'package:piliotto/common/widgets/no_data.dart';
import 'package:piliotto/common/widgets/video_card_v.dart';
import 'package:piliotto/utils/main_stream.dart';
import 'package:piliotto/utils/responsive_util.dart';

import 'controller.dart';

class RcmdPage extends StatefulWidget {
  const RcmdPage({super.key});

  @override
  State<RcmdPage> createState() => _RcmdPageState();
}

class _RcmdPageState extends State<RcmdPage>
    with AutomaticKeepAliveClientMixin {
  final RcmdController _rcmdController = Get.put(RcmdController());
  late Future _futureBuilderFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = _rcmdController.queryRcmdFeed('init');
    ScrollController scrollController = _rcmdController.scrollController;
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          EasyThrottle.throttle(
              'my-throttler', const Duration(milliseconds: 200), () {
            _rcmdController.onLoad();
          });
        }
        handleScrollEvent(scrollController);
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 初始计算列数
    _rcmdController.updateCrossAxisCount();
  }

  @override
  void didUpdateWidget(covariant RcmdPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 屏幕尺寸变化时更新列数（使用防抖处理）
    EasyThrottle.throttle(
        'updateCrossAxisCount', const Duration(milliseconds: 100), () {
      _rcmdController.updateCrossAxisCount();
    });
  }

  @override
  void dispose() {
    _rcmdController.scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null) {
              Map data = snapshot.data as Map;
              if (data['status']) {
                return Obx(() {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await _rcmdController.onRefresh();
                      await Future.delayed(const Duration(milliseconds: 300));
                    },
                    child:
                        contentGrid(_rcmdController, _rcmdController.videoList),
                  );
                });
              } else {
                return HttpError(
                  errMsg: data['msg'],
                  fn: () {
                    setState(() {
                      _rcmdController.isLoadingMore.value = true;
                      _futureBuilderFuture =
                          _rcmdController.queryRcmdFeed('init');
                    });
                  },
                );
              }
            } else {
              return const NoData();
            }
          } else {
            // 骨架屏
            return Obx(() {
              return contentGrid(_rcmdController, []);
            });
          }
        },
      ),
    );
  }

  Widget contentGrid(RcmdController ctr, List<Video> videoList) {
    int crossAxisCount = ctr.crossAxisCount.value;
    double mainAxisExtent = ResponsiveUtil.calculateMainAxisExtent(
      crossAxisCount: crossAxisCount,
      aspectRatio: StyleString.aspectRatio,
      textHeight:
          crossAxisCount == 1 ? 68 : MediaQuery.textScalerOf(context).scale(86),
    );
    return GridView.builder(
      controller: ctr.scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // 行间距
        mainAxisSpacing: StyleString.safeSpace,
        // 列间距
        crossAxisSpacing: StyleString.safeSpace,
        // 列数
        crossAxisCount: crossAxisCount,
        mainAxisExtent: mainAxisExtent,
      ),
      itemBuilder: (BuildContext context, int index) {
        return videoList.isNotEmpty
            ? VideoCardV(
                videoItem: videoList[index],
                crossAxisCount: crossAxisCount,
                blockUserCb: (mid) => ctr.blockUserCb(mid),
              )
            : const VideoCardVSkeleton();
      },
      itemCount: videoList.isNotEmpty ? videoList.length : 10,
      padding: const EdgeInsets.fromLTRB(
          0, StyleString.safeSpace, 0, StyleString.safeSpace),
    );
  }
}
