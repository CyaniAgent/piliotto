import 'dart:async';

import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/constants.dart';
import 'package:piliotto/common/skeleton/video_card_h.dart';
import 'package:piliotto/common/widgets/http_error.dart';
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
  late Future _futureBuilderFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = _hotController.queryHotFeed(type: 'init');
    _hotController.scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_hotController.scrollController.hasClients &&
        _hotController.scrollController.position.pixels >=
            _hotController.scrollController.position.maxScrollExtent - 200) {
      if (!_hotController.isLoadingMore &&
          _hotController.noMore != '没有更多了') {
        _hotController.onLoad();
      }
    }
    handleScrollEvent(_hotController.scrollController);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _hotController.updateCrossAxisCount();
  }

  @override
  void didUpdateWidget(covariant HotPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    EasyThrottle.throttle(
        'updateCrossAxisCount', const Duration(milliseconds: 100), () {
      _hotController.updateCrossAxisCount();
    });
  }

  @override
  void dispose() {
    _hotController.scrollController.removeListener(_scrollListener);
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
                  if (_hotController.videoList.isEmpty) {
                    return SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWideScreen
                            ? (screenWidth - maxContentWidth) / 2
                            : 0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: HttpError(
                          errMsg: _hotController.noMore == '加载失败'
                              ? '加载失败，请重试'
                              : '暂无数据',
                          fn: () {
                            setState(() {
                              _futureBuilderFuture =
                                  _hotController.queryHotFeed(type: 'init');
                            });
                          },
                        ),
                      ),
                    );
                  }
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
