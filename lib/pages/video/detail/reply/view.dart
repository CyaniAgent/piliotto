import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:piliotto/common/skeleton/video_reply.dart';

import 'package:piliotto/models/common/reply_type.dart';
import 'provider.dart';
import 'widgets/reply_item.dart';
import 'widgets/comment_input.dart';
import '../provider.dart';

class VideoReplyPanel extends ConsumerStatefulWidget {
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
  ConsumerState<VideoReplyPanel> createState() => VideoReplyPanelState();
}

class VideoReplyPanelState extends ConsumerState<VideoReplyPanel>
    with AutomaticKeepAliveClientMixin {
  late ScrollController scrollController;

  String replyLevel = '1';
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    replyLevel = widget.replyLevel ?? '1';

    scrollController = ScrollController();
    widget.onControllerCreated?.call(scrollController);
    _setupScrollListener();
    _isInitialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(videoReplyProvider(widget.vid));
      if (!state.hasLoaded) {
        ref.read(videoReplyProvider(widget.vid).notifier).queryReplyList();
      }
    });
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 300) {
        EasyThrottle.throttle(
          'replylist',
          const Duration(milliseconds: 500),
          () {
            ref.read(videoReplyProvider(widget.vid).notifier).onLoad();
          },
        );
      }
    });
  }

  Future<void> refresh() async {
    await ref.read(videoReplyProvider(widget.vid).notifier).queryReplyList(type: 'init');
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_isInitialized) {
      return const SizedBox();
    }

    final replyState = ref.watch(videoReplyProvider(widget.vid));
    final replyNotifier = ref.read(videoReplyProvider(widget.vid).notifier);

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await replyNotifier.queryReplyList(type: 'init');
            },
            child: ListView.builder(
              controller: scrollController,
              physics: const ClampingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              key: PageStorageKey<String>('评论_${widget.vid}'),
              itemCount: replyState.replyList.isEmpty
                  ? (replyState.isLoadingMore ? 5 : 1)
                  : replyState.replyList.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (replyState.replyList.isEmpty) {
                  if (replyState.isLoadingMore) {
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

                if (index == replyState.replyList.length) {
                  if (replyState.isLoadingMore) {
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
                        replyState.noMore,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  );
                }

                final replyItem = replyState.replyList[index];
                return ReplyItem(
                  key: ValueKey('reply_${replyItem.rpid}_$index'),
                  replyItem: replyItem,
                  showReplyRow: true,
                  replyLevel: replyLevel,
                  replyReply: (replyItem, currentReply, loadMore) {
                    try {
                      final vdNotifier = ref.read(videoDetailProvider.notifier);
                      vdNotifier.showReplyReplyPanel(
                        widget.vid,
                        replyItem.rpid,
                        replyItem,
                        currentReply,
                        loadMore,
                      );
                    } catch (e) {
                      debugPrint('VideoDetailNotifier not found: $e');
                    }
                  },
                  replyType: ReplyType.video,
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
