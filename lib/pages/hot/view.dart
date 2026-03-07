import 'dart:async';

import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/constants.dart';
import 'package:piliotto/common/skeleton/video_card_h.dart';
import 'package:piliotto/common/widgets/http_error.dart';
import 'package:piliotto/common/widgets/responsive_layout.dart';
import 'package:piliotto/common/widgets/video_card_h.dart';
import 'package:piliotto/pages/hot/controller.dart';
import 'package:piliotto/utils/main_stream.dart';
import 'package:piliotto/utils/responsive_util.dart';

class HotPage extends StatefulWidget {
  const HotPage({Key? key}) : super(key: key);

  @override
  State<HotPage> createState() => _HotPageState();
}

class _HotPageState extends State<HotPage> with AutomaticKeepAliveClientMixin {
  final HotController _hotController = Get.put(HotController());
  List videoList = [];
  Future? _futureBuilderFuture;
  late ScrollController scrollController;
  late MediaQueryData _mediaQueryData;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = _hotController.queryHotFeed('init');
    scrollController = _hotController.scrollController;
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          if (!_hotController.isLoadingMore) {
            _hotController.isLoadingMore = true;
            _hotController.onLoad();
          }
        }
        handleScrollEvent(scrollController);
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 初始化媒体查询数据
    _mediaQueryData = MediaQuery.of(context);
    // 初始计算列数
    _hotController.updateCrossAxisCount();
  }

  @override
  void didUpdateWidget(covariant HotPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 屏幕尺寸变化时更新列数（使用防抖处理）
    EasyThrottle.throttle(
        'updateCrossAxisCount', const Duration(milliseconds: 100), () {
      _hotController.updateCrossAxisCount();
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = ResponsiveUtil.isMd;
    double maxContentWidth = 800;

    return RefreshIndicator(
      onRefresh: () async {
        return await _hotController.onRefresh();
      },
      child: CustomScrollView(
        controller: _hotController.scrollController,
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
                    return Obx(
                      () {
                        return SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isWideScreen
                                ? (screenWidth - maxContentWidth) / 2
                                : 0,
                          ),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  _hotController.crossAxisCount.value,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 3 / 1,
                            ),
                            delegate:
                                SliverChildBuilderDelegate((context, index) {
                              return VideoCardH(
                                videoItem: _hotController.videoList[index],
                                showPubdate: true,
                              );
                            }, childCount: _hotController.videoList.length),
                          ),
                        );
                      },
                    );
                  } else {
                    return SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWideScreen
                            ? (screenWidth - maxContentWidth) / 2
                            : 0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: HttpError(
                          errMsg: data['msg'],
                          fn: () {
                            setState(() {
                              _futureBuilderFuture =
                                  _hotController.queryHotFeed('init');
                            });
                          },
                        ),
                      ),
                    );
                  }
                } else {
                  // 骨架屏
                  return SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWideScreen
                          ? (screenWidth - maxContentWidth) / 2
                          : 0,
                    ),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _hotController.crossAxisCount.value,
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
}
