import 'dart:async';

import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
            _rcmdController.isLoadingMore = true;
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
      child: RefreshIndicator(
        onRefresh: () async {
          await _rcmdController.onRefresh();
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: CustomScrollView(
          controller: _rcmdController.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding:
                  const EdgeInsets.fromLTRB(0, StyleString.safeSpace, 0, 0),
              sliver: FutureBuilder(
                future: _futureBuilderFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data != null) {
                      Map data = snapshot.data as Map;
                      if (data['status']) {
                        return Obx(
                          () {
                            if (_rcmdController.isLoadingMore &&
                                _rcmdController.videoList.isEmpty) {
                              return contentGrid(_rcmdController, []);
                            } else {
                              // 显示视频列表
                              return contentGrid(
                                  _rcmdController, _rcmdController.videoList);
                            }
                          },
                        );
                      } else {
                        return SliverToBoxAdapter(
                          child: HttpError(
                            errMsg: data['msg'],
                            fn: () {
                              setState(() {
                                _rcmdController.isLoadingMore = true;
                                _futureBuilderFuture =
                                    _rcmdController.queryRcmdFeed('init');
                              });
                            },
                          ),
                        );
                      }
                    } else {
                      return const SliverToBoxAdapter(
                        child: NoData(),
                      );
                    }
                  } else {
                    // 骨架屏
                    return contentGrid(_rcmdController, []);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget contentGrid(ctr, videoList) {
    int crossAxisCount = ctr.crossAxisCount.value;
    double mainAxisExtent = ResponsiveUtil.calculateMainAxisExtent(
      crossAxisCount: crossAxisCount,
      aspectRatio: StyleString.aspectRatio,
      textHeight:
          crossAxisCount == 1 ? 68 : MediaQuery.textScalerOf(context).scale(86),
    );
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // 行间距
        mainAxisSpacing: StyleString.safeSpace,
        // 列间距
        crossAxisSpacing: StyleString.safeSpace,
        // 列数
        crossAxisCount: crossAxisCount,
        mainAxisExtent: mainAxisExtent,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return videoList!.isNotEmpty
              ? VideoCardV(
                  videoItem: videoList[index],
                  crossAxisCount: crossAxisCount,
                  blockUserCb: (mid) => ctr.blockUserCb(mid),
                )
              : const VideoCardVSkeleton();
        },
        childCount: videoList!.isNotEmpty ? videoList!.length : 10,
      ),
    );
  }
}
