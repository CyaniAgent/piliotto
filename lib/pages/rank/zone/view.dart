import 'dart:async';

import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/constants.dart';
import 'package:piliotto/common/skeleton/video_card_h.dart';
import 'package:piliotto/common/widgets/http_error.dart';
import 'package:piliotto/common/widgets/video_card_h.dart';
import 'package:piliotto/pages/rank/zone/index.dart';
import 'package:piliotto/utils/main_stream.dart';

class ZonePage extends StatefulWidget {
  const ZonePage({super.key, required this.rid});

  final int rid;

  @override
  State<ZonePage> createState() => _ZonePageState();
}

class _ZonePageState extends State<ZonePage>
    with AutomaticKeepAliveClientMixin {
  late ZoneController _zoneController;
  List videoList = [];
  Future? _futureBuilderFuture;
  late ScrollController scrollController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _zoneController = Get.put(ZoneController(), tag: widget.rid.toString());
    _futureBuilderFuture = _zoneController.queryRankFeed('init', widget.rid);
    scrollController = _zoneController.scrollController;
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          if (!_zoneController.isLoadingMore) {
            _zoneController.isLoadingMore = true;
            _zoneController.onLoad();
          }
        }
        handleScrollEvent(scrollController);
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 初始计算列数
    _zoneController.updateCrossAxisCount();
  }

  @override
  void didUpdateWidget(covariant ZonePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 屏幕尺寸变化时的防抖处理
    EasyThrottle.throttle(
        'zonePageDidChange', const Duration(milliseconds: 100), () {
      // 更新列数
      _zoneController.updateCrossAxisCount();
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
    bool isWideScreen = screenWidth > 768;
    double maxContentWidth = 800;

    return RefreshIndicator(
      onRefresh: () async {
        return await _zoneController.onRefresh();
      },
      child: CustomScrollView(
        controller: _zoneController.scrollController,
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
                        return SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                _zoneController.crossAxisCount.value,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 3 / 1,
                          ),
                          delegate:
                              SliverChildBuilderDelegate((context, index) {
                            return VideoCardH(
                              videoItem: _zoneController.videoList[index],
                              showPubdate: true,
                            );
                          }, childCount: _zoneController.videoList.length),
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
                              _futureBuilderFuture = _zoneController
                                  .queryRankFeed('init', widget.rid);
                            });
                          },
                        ),
                      ),
                    );
                  }
                } else {
                  // 骨架屏
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _zoneController.crossAxisCount.value,
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
