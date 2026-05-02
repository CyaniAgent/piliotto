import 'dart:async';

import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:piliotto/pages/dynamics/detail/provider.dart';
import 'package:piliotto/pages/dynamics/widgets/author_panel.dart';
import 'package:piliotto/pages/dynamics/widgets/flat_reply_item.dart';
import 'package:piliotto/pages/dynamics/widgets/blog_comment_input.dart';
import 'package:piliotto/utils/responsive_util.dart';
import 'package:piliotto/utils/route_arguments.dart';

import 'header.dart';

class DynamicDetailPage extends ConsumerStatefulWidget {
  const DynamicDetailPage({super.key});

  @override
  ConsumerState<DynamicDetailPage> createState() => _DynamicDetailPageState();
}

class _DynamicDetailPageState extends ConsumerState<DynamicDetailPage>
    with TickerProviderStateMixin {
  late AnimationController fabAnimationCtr;
  Future? _futureBuilderFuture;
  late StreamController<bool> titleStreamC = StreamController<bool>.broadcast();
  late ScrollController scrollController;
  bool _visibleTitle = false;
  String? action;
  bool _isFabVisible = true;
  int oid = 0;

  @override
  void initState() {
    super.initState();
    init();
    if (action == 'comment') {
      _visibleTitle = true;
      titleStreamC.add(true);
    }

    fabAnimationCtr = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    fabAnimationCtr.forward();
  }

  Future<void> init() async {
    final Map args = routeArguments.arguments;
    action = args.containsKey('action') ? args['action'] : null;

    oid = int.tryParse(args['item'].idStr ?? '0') ?? 0;

    _futureBuilderFuture = ref.read(dynamicDetailProvider(oid).notifier).queryReplyList();

    if (mounted) {
      scrollListener();
      setState(() {});
    }
  }

  void scrollListener() {
    final notifier = ref.read(dynamicDetailProvider(oid).notifier);
    scrollController = notifier.scrollController;
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 300) {
          EasyThrottle.throttle('replylist', const Duration(seconds: 2), () {
            notifier.queryReplyList(reqType: 'onLoad');
          });
        }

        if (scrollController.offset > 55 && !_visibleTitle) {
          _visibleTitle = true;
          titleStreamC.add(true);
        } else if (scrollController.offset <= 55 && _visibleTitle) {
          _visibleTitle = false;
          titleStreamC.add(false);
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

  @override
  void dispose() {
    scrollController.removeListener(() {});
    fabAnimationCtr.dispose();
    scrollController.dispose();
    titleStreamC.close();
    super.dispose();
  }

  EdgeInsets _buildPadding(bool isWideScreen, double screenWidth) {
    const contentMaxWidth = 600.0;
    if (isWideScreen) {
      final horizontalPadding = (screenWidth - contentMaxWidth) / 2;
      return EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: MediaQuery.of(context).padding.bottom + 80,
      );
    }
    return EdgeInsets.only(
      bottom: MediaQuery.of(context).padding.bottom + 80,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWideScreen = ResponsiveUtil.isLg || ResponsiveUtil.isXl;
    final screenWidth = MediaQuery.of(context).size.width;
    final state = ref.watch(dynamicDetailProvider(oid));
    final notifier = ref.read(dynamicDetailProvider(oid).notifier);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleSpacing: 0,
        automaticallyImplyLeading: true,
        title: StreamBuilder(
          stream: titleStreamC.stream,
          initialData: false,
          builder: (context, AsyncSnapshot snapshot) {
            return AnimatedOpacity(
              opacity: snapshot.data ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: AuthorPanel(item: state.item),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await notifier.queryReplyList();
              },
              child: FutureBuilder(
                future: _futureBuilderFuture,
                builder: (context, snapshot) {
                  final replyList = state.replyList;
                  final isLoading = state.isLoadingMore;

                  return ListView.builder(
                    controller: scrollController,
                    padding: _buildPadding(isWideScreen, screenWidth),
                    itemCount: replyList.length + 2,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        if (action != 'comment') {
                          return DynamicDetailHeader(
                            item: state.item,
                          );
                        }
                        return const SizedBox.shrink();
                      }

                      if (index == 1) {
                        return _buildCommentHeader(context, state, notifier);
                      }

                      final replyIndex = index - 2;
                      if (replyIndex == replyList.length) {
                        return _buildLoadingIndicator(colorScheme, isLoading, state);
                      }

                      return FlatReplyItem(
                        replyItem: replyList[replyIndex],
                        bid: oid,
                        onReply: (replyItem, [subReply, loadMore]) {
                          notifier.setReplyingTo(
                            subReply ?? replyItem,
                            parent: replyItem.rpid,
                          );
                        },
                        onRefresh: () {
                          notifier.queryReplyList(reqType: 'init');
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
          BlogCommentInput(
            bid: oid,
            parentBcid: state.parentBcid,
            placeholder: state.replyingTo != null
                ? '回复 @${state.replyingTo?.member?.uname ?? ''}'
                : '发一条友善的评论喵~',
            onCommentSuccess: () {
              notifier.onReplySuccess();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommentHeader(BuildContext context, DynamicDetailState state, DynamicDetailNotifier notifier) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            width: 0.6,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
          ),
        ),
      ),
      height: 45,
      padding: const EdgeInsets.only(left: 12, right: 6),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Text(
              '${state.acount}',
              key: ValueKey<int>(state.acount),
            ),
          ),
          const Text('条回复'),
          const Spacer(),
          if (state.replyingTo != null)
            TextButton.icon(
              onPressed: () {
                notifier.clearReplyingTo();
              },
              icon: const Icon(Icons.close, size: 16),
              label: const Text('取消回复'),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.outline,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(ColorScheme colorScheme, bool isLoading, DynamicDetailState state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '加载中...',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              )
            : Text(
                state.noMore,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.outline,
                ),
              ),
      ),
    );
  }
}
