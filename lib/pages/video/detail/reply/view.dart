import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/skeleton/video_reply.dart';

import 'package:piliotto/models/common/reply_type.dart';
import 'controller.dart';
import 'widgets/reply_item.dart';
import 'widgets/comment_input.dart';
import '../controller.dart';

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

  String get _tag =>
      replyLevel == '2' ? widget.rpid.toString() : _controllerTag;

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

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await controller.queryReplyList(type: 'init');
            },
            child: GetBuilder<VideoReplyController>(
              init: controller,
              tag: _tag,
              builder: (controller) {
                return ListView.builder(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  key: PageStorageKey<String>('评论_${widget.vid}'),
                  itemCount: controller.replyList.isEmpty
                      ? (controller.isLoadingMore ? 5 : 1)
                      : controller.replyList.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (controller.replyList.isEmpty) {
                      if (controller.isLoadingMore) {
                        return const VideoReplySkeleton();
                      }
                      return SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            '暂无评论，快来抢沙发喵~',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                      );
                    }

                    if (index == controller.replyList.length) {
                      if (controller.isLoadingMore) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '加载中...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                      replyReply: (replyItem, currentReply, loadMore) {
                        final heroTag =
                            Get.arguments?['heroTag'] ?? widget.vid.toString();
                        try {
                          final videoDetailCtr =
                              Get.find<VideoDetailController>(tag: heroTag);
                          videoDetailCtr.showReplyReplyPanel(
                            widget.vid,
                            replyItem.rpid,
                            replyItem,
                            currentReply,
                            loadMore,
                          );
                        } catch (e) {
                          debugPrint('VideoDetailController not found: $e');
                        }
                      },
                      replyType: ReplyType.video,
                    );
                  },
                );
              },
            ),
          ),
        ),
        CommentInput(
          vid: widget.vid,
          onCommentSuccess: () {
            refresh();
          },
        ),
      ],
    );
  }
}
