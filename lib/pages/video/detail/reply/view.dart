import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/skeleton/video_reply.dart';

import 'package:piliotto/models/common/reply_type.dart';
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
  State<VideoReplyPanel> createState() => VideoReplyPanelState();
}

class VideoReplyPanelState extends State<VideoReplyPanel>
    with AutomaticKeepAliveClientMixin {
  VideoReplyController? _videoReplyController;
  late ScrollController scrollController;

  String replyLevel = '1';
  late String _controllerTag;
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  String get _tag => replyLevel == '2' ? widget.rpid.toString() : _controllerTag;

  @override
  void initState() {
    super.initState();
    _controllerTag = Get.arguments?['heroTag'] ?? widget.vid.toString();
    replyLevel = widget.replyLevel ?? '1';
    
    _initController();
    scrollController = ScrollController();
    widget.onControllerCreated?.call(scrollController);
    _setupScrollListener();
    _isInitialized = true;
  }

  void _initController() {
    final tag = _tag;
    
    if (Get.isRegistered<VideoReplyController>(tag: tag)) {
      _videoReplyController = Get.find<VideoReplyController>(tag: tag);
    } else {
      _videoReplyController = Get.put(
        VideoReplyController(widget.vid),
        tag: tag,
      );
    }
    
    if (!_videoReplyController!.hasLoaded) {
      _videoReplyController!.queryReplyList();
    }
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 300) {
        EasyThrottle.throttle(
          'replylist',
          const Duration(milliseconds: 500),
          () {
            _videoReplyController?.onLoad();
          },
        );
      }
    });
  }

  Future<void> refresh() async {
    await _videoReplyController?.queryReplyList(type: 'init');
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_isInitialized || _videoReplyController == null) {
      return const SizedBox();
    }
    
    final controller = _videoReplyController!;
    
    return RefreshIndicator(
      onRefresh: () async {
        await controller.queryReplyList(type: 'init');
      },
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        key: PageStorageKey<String>('评论_${widget.vid}'),
        slivers: <Widget>[
          GetBuilder<VideoReplyController>(
            init: controller,
            tag: _tag,
            builder: (controller) {
              if (controller.replyList.isEmpty && !controller.isLoadingMore) {
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        '暂无评论',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  ),
                );
              }
              
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    if (index < 5 && controller.replyList.isEmpty) {
                      return const VideoReplySkeleton();
                    }

                    if (index == controller.replyList.length) {
                      double bottom = MediaQuery.of(context).padding.bottom;
                      return Container(
                        padding: EdgeInsets.only(bottom: bottom),
                        height: bottom + 100,
                        child: Center(
                          child: Text(
                            controller.noMore,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                      );
                    }

                    final replyItem = controller.replyList[index];
                    return ReplyItem(
                      key: ValueKey('reply_${replyItem.rpid}_$index'),
                      replyItem: replyItem,
                      showReplyRow: true,
                      replyLevel: replyLevel,
                      replyReply: (replyItem, currentReply, loadMore) {},
                      replyType: ReplyType.video,
                    );
                  },
                  childCount: controller.replyList.isEmpty
                      ? 5
                      : controller.replyList.length + 1,
                  findChildIndexCallback: (Key key) {
                    if (key is ValueKey<String>) {
                      final keyString = key.value;
                      if (keyString.startsWith('reply_')) {
                        final parts = keyString.split('_');
                        if (parts.length >= 3) {
                          final rpid = int.tryParse(parts[1]);
                          if (rpid != null) {
                            for (int i = 0; i < controller.replyList.length; i++) {
                              if (controller.replyList[i].rpid == rpid) {
                                return i;
                              }
                            }
                          }
                        }
                      }
                    }
                    return null;
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
