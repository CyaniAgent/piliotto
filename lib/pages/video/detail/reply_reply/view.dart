import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:piliotto/common/skeleton/video_reply.dart';
import 'package:piliotto/common/widgets/http_error.dart';
import 'package:piliotto/models/common/reply_type.dart';
import 'package:piliotto/ottohub/models/video/reply/item.dart';
import 'package:piliotto/pages/video/detail/reply/widgets/reply_item.dart';
import 'package:piliotto/pages/video/detail/reply/widgets/comment_input.dart';

import 'provider.dart';

class VideoReplyReplyPanel extends ConsumerStatefulWidget {
  const VideoReplyReplyPanel({
    this.vid,
    this.parentVcid,
    this.closePanel,
    this.firstFloor,
    this.source,
    this.replyType,
    this.sheetHeight,
    this.currentReply,
    this.loadMore = true,
    super.key,
  });
  final int? vid;
  final int? parentVcid;
  final Function? closePanel;
  final ReplyItemModel? firstFloor;
  final String? source;
  final ReplyType? replyType;
  final double? sheetHeight;
  final dynamic currentReply;
  final bool loadMore;

  @override
  ConsumerState<VideoReplyReplyPanel> createState() => _VideoReplyReplyPanelState();
}

class _VideoReplyReplyPanelState extends ConsumerState<VideoReplyReplyPanel> {
  late ScrollController scrollController;
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();

    final notifier = ref.read(videoReplyReplyProvider(
      widget.vid ?? 0,
      widget.parentVcid ?? 0,
      widget.replyType ?? ReplyType.video,
    ).notifier);
    scrollController = notifier.scrollController;
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 300) {
          EasyThrottle.throttle('replylist', const Duration(milliseconds: 200),
              () {
            ref.read(videoReplyReplyProvider(
              widget.vid ?? 0,
              widget.parentVcid ?? 0,
              widget.replyType ?? ReplyType.video,
            ).notifier).queryReplyList(type: 'onLoad');
          });
        }
      },
    );

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      await ref.read(videoReplyReplyProvider(
        widget.vid ?? 0,
        widget.parentVcid ?? 0,
        widget.replyType ?? ReplyType.video,
      ).notifier).queryReplyList(
        currentReply: widget.currentReply,
      );
    } catch (e) {
      _errorMsg = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = widget.sheetHeight == null;
    final replyState = ref.watch(videoReplyReplyProvider(
      widget.vid ?? 0,
      widget.parentVcid ?? 0,
      widget.replyType ?? ReplyType.video,
    ));

    return Container(
      height: isWideScreen ? null : widget.sheetHeight,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          AppBar(
            toolbarHeight: 45,
            automaticallyImplyLeading: false,
            centerTitle: false,
            title: Text(
              '评论详情',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  widget.closePanel?.call();
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 14),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _loadData();
              },
              child: CustomScrollView(
                controller: scrollController,
                physics: const ClampingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: <Widget>[
                  if (widget.firstFloor != null) ...[
                    SliverToBoxAdapter(
                      child: ReplyItem(
                        replyItem: widget.firstFloor,
                        replyLevel: '2',
                        showReplyRow: false,
                        replyType: widget.replyType,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Divider(
                        height: 20,
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.1),
                        thickness: 6,
                      ),
                    ),
                  ],
                  _buildContent(replyState),
                ],
              ),
            ),
          ),
          CommentInput(
            vid: widget.vid ?? 0,
            parentVcid: widget.parentVcid ?? 0,
            placeholder: '回复评论...',
            onCommentSuccess: () {
              _loadData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(VideoReplyReplyState replyState) {
    if (_isLoading) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return const VideoReplySkeleton();
          },
          childCount: 5,
        ),
      );
    }

    if (_errorMsg != null) {
      return HttpError(
        isSliver: true,
        errMsg: _errorMsg!,
        fn: _loadData,
      );
    }

    if (!widget.loadMore) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(
            child: Text(
              '还没有评论',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ),
      );
    }

    final replyList = replyState.replyList;
    final isLoadingMore = replyState.isLoadingMore;
    final noMore = replyState.noMore;

    if (replyList.isEmpty && !isLoadingMore) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(
            child: Text(
              '暂无回复喵~',
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
          if (index == replyList.length) {
            if (isLoadingMore) {
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
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '加载中...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.outline,
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
                  noMore,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            );
          }

          return ReplyItem(
            replyItem: replyList[index],
            replyLevel: '2',
            showReplyRow: false,
            replyType: widget.replyType,
          );
        },
        childCount: replyList.length + 1,
      ),
    );
  }
}
