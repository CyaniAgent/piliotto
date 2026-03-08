import 'dart:async';

import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/skeleton/video_reply.dart';
import 'package:piliotto/common/widgets/http_error.dart';
import 'package:piliotto/models/common/reply_type.dart';

import 'package:piliotto/utils/feed_back.dart';
import 'controller.dart';
import 'widgets/reply_item.dart';

class VideoReplyPanel extends StatefulWidget {
  final int vid;
  final int rpid;
  final String? replyLevel;
  final Function(ScrollController)? onControllerCreated;

  const VideoReplyPanel({
    required this.vid,
    this.rpid = 0,
    this.replyLevel,
    this.onControllerCreated,
    super.key,
  });

  @override
  State<VideoReplyPanel> createState() => _VideoReplyPanelState();
}

class _VideoReplyPanelState extends State<VideoReplyPanel>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late VideoReplyController _videoReplyController;
  late AnimationController fabAnimationCtr;
  late ScrollController scrollController;

  Future? _futureBuilderFuture;
  bool _isFabVisible = true;
  String replyLevel = '1';
  late String heroTag;

  // 添加页面缓存
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    heroTag = Get.arguments['heroTag'];
    replyLevel = widget.replyLevel ?? '1';
    if (replyLevel == '2') {
      _videoReplyController = Get.put(VideoReplyController(widget.vid),
          tag: widget.rpid.toString());
    } else {
      _videoReplyController =
          Get.put(VideoReplyController(widget.vid), tag: heroTag);
    }

    fabAnimationCtr = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _futureBuilderFuture = _videoReplyController.queryReplyList();
    scrollController = ScrollController();
    widget.onControllerCreated?.call(scrollController);
    fabAnimationCtr.forward();
    scrollListener();
  }

  void scrollListener() {
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 300) {
          EasyThrottle.throttle('replylist', const Duration(milliseconds: 200),
              () {
            _videoReplyController.onLoad();
          });
        }

        final ScrollDirection direction =
            scrollController.position.userScrollDirection;
        if (direction == ScrollDirection.forward) {
          _showFab();
        } else if (direction == ScrollDirection.reverse) {
          _hideFab();
        }
      },
    );
  }

  void _showFab() {
    if (!_isFabVisible) {
      _isFabVisible = true;
      fabAnimationCtr.forward();
    }
  }

  void _hideFab() {
    if (_isFabVisible) {
      _isFabVisible = false;
      fabAnimationCtr.reverse();
    }
  }

  // 展示二级回复
  void replyReply(replyItem, currentReply, loadMore) {
    // Ottohub API 暂不支持二级回复
    SmartDialog.showToast('暂不支持二级回复');
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    fabAnimationCtr.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: () async {
        return await _videoReplyController.queryReplyList(type: 'init');
      },
      child: Stack(
        children: [
          CustomScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            key: const PageStorageKey<String>('评论'),
            slivers: <Widget>[
              SliverPersistentHeader(
                pinned: false,
                floating: true,
                delegate: _MySliverPersistentHeaderDelegate(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.fromLTRB(12, 0, 6, 0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.surface,
                          blurRadius: 0.0,
                          spreadRadius: 0.0,
                          offset: const Offset(2, 0),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '评论',
                          style: const TextStyle(fontSize: 13),
                        ),
                        SizedBox(
                          height: 35,
                          child: TextButton.icon(
                            onPressed: () =>
                                _videoReplyController.queryBySort(),
                            icon: const Icon(Icons.sort, size: 16),
                            label: Text(
                              '排序',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              FutureBuilder(
                future: _futureBuilderFuture,
                builder: (BuildContext context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    var data = snapshot.data;
                    // 不直接访问可观察变量，而是使用data的状态来判断
                    if ((data != null && data['status'])) {
                      // 请求成功
                      return Obx(
                        () {
                          // 直接访问可观察变量以确保GetX能够正确追踪
                          final replyList = _videoReplyController.replyList;
                          final isEmpty = replyList.isEmpty;

                          return isEmpty
                              ? SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                      (BuildContext context, index) {
                                    return const VideoReplySkeleton();
                                  }, childCount: 5),
                                )
                              : SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, index) {
                                      double bottom =
                                          MediaQuery.of(context).padding.bottom;
                                      if (index == replyList.length) {
                                        return Container(
                                          padding:
                                              EdgeInsets.only(bottom: bottom),
                                          height: bottom + 100,
                                          child: Center(
                                            child: Obx(
                                              () => Text(
                                                _videoReplyController
                                                    .noMore.value,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .outline,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return ReplyItem(
                                          replyItem: replyList[index],
                                          showReplyRow: true,
                                          replyLevel: replyLevel,
                                          replyReply: (replyItem, currentReply,
                                                  loadMore) =>
                                              replyReply(replyItem,
                                                  currentReply, loadMore),
                                          replyType: ReplyType.video,
                                        );
                                      }
                                    },
                                    childCount: replyList.length + 1,
                                  ),
                                );
                        },
                      );
                    } else {
                      // 请求错误
                      return HttpError(
                        errMsg: data['msg'],
                        fn: () {
                          setState(() {
                            _futureBuilderFuture =
                                _videoReplyController.queryReplyList();
                          });
                        },
                      );
                    }
                  } else {
                    // 骨架屏
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                          (BuildContext context, index) {
                        return const VideoReplySkeleton();
                      }, childCount: 5),
                    );
                  }
                },
              )
            ],
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 14,
            right: 14,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 2),
                end: const Offset(0, 0),
              ).animate(CurvedAnimation(
                parent: fabAnimationCtr,
                curve: Curves.easeInOut,
              )),
              child: FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  feedBack();
                  // Ottohub API 暂不支持发表评论
                  SmartDialog.showToast('暂不支持发表评论');
                },
                tooltip: '发表评论',
                child: const Icon(Icons.reply),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MySliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  _MySliverPersistentHeaderDelegate({required this.child});
  final double _minExtent = 40;
  final double _maxExtent = 40;
  final Widget child;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    //创建child子组件
    //shrinkOffset：child偏移值minExtent~maxExtent
    //overlapsContent：SliverPersistentHeader覆盖其他子组件返回true，否则返回false
    return child;
  }

  //SliverPersistentHeader最大高度
  @override
  double get maxExtent => _maxExtent;

  //SliverPersistentHeader最小高度
  @override
  double get minExtent => _minExtent;

  @override
  bool shouldRebuild(covariant _MySliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
