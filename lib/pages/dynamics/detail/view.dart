import 'dart:async';

import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:piliotto/pages/dynamics/detail/index.dart';
import 'package:piliotto/pages/dynamics/widgets/author_panel.dart';
import 'package:piliotto/pages/dynamics/widgets/flat_reply_item.dart';
import 'package:piliotto/utils/responsive_util.dart';

import '../widgets/dynamic_panel.dart';

class DynamicDetailPage extends StatefulWidget {
  const DynamicDetailPage({Key? key}) : super(key: key);

  @override
  State<DynamicDetailPage> createState() => _DynamicDetailPageState();
}

class _DynamicDetailPageState extends State<DynamicDetailPage>
    with TickerProviderStateMixin {
  late DynamicDetailController _dynamicDetailController;
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
    Map args = Get.arguments;
    action = args.containsKey('action') ? args['action'] : null;

    oid = int.tryParse(args['item'].idStr ?? '0') ?? 0;

    _dynamicDetailController =
        Get.put(DynamicDetailController(oid), tag: oid.toString());
    _futureBuilderFuture = _dynamicDetailController.queryReplyList();

    if (mounted) {
      scrollListener();
      setState(() {});
    }
  }

  void scrollListener() {
    scrollController = _dynamicDetailController.scrollController;
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 300) {
          EasyThrottle.throttle('replylist', const Duration(seconds: 2), () {
            _dynamicDetailController.queryReplyList(reqType: 'onLoad');
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

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleSpacing: 0,
        title: StreamBuilder(
          stream: titleStreamC.stream,
          initialData: false,
          builder: (context, AsyncSnapshot snapshot) {
            return AnimatedOpacity(
              opacity: snapshot.data ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: AuthorPanel(item: _dynamicDetailController.item),
            );
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _dynamicDetailController.queryReplyList();
        },
        child: FutureBuilder(
          future: _futureBuilderFuture,
          builder: (context, snapshot) {
            return Obx(() {
              final replyList = _dynamicDetailController.replyList;
              final isLoading = _dynamicDetailController.isLoadingMore.value;

              return ListView.builder(
                controller: scrollController,
                padding: _buildPadding(isWideScreen, screenWidth),
                itemCount: replyList.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    if (action != 'comment') {
                      return DynamicPanel(
                        item: _dynamicDetailController.item,
                        source: 'detail',
                      );
                    }
                    return const SizedBox.shrink();
                  }

                  if (index == 1) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border(
                          top: BorderSide(
                            width: 0.6,
                            color: Theme.of(context)
                                .dividerColor
                                .withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      height: 45,
                      padding: const EdgeInsets.only(left: 12, right: 6),
                      child: Row(
                        children: [
                          Obx(
                            () => AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return ScaleTransition(
                                    scale: animation, child: child);
                              },
                              child: Text(
                                '${_dynamicDetailController.acount.value}',
                                key: ValueKey<int>(
                                    _dynamicDetailController.acount.value),
                              ),
                            ),
                          ),
                          const Text('条回复'),
                        ],
                      ),
                    );
                  }

                  final replyIndex = index - 2;
                  if (replyIndex == replyList.length) {
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
                                _dynamicDetailController.noMore.value,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.outline,
                                ),
                              ),
                      ),
                    );
                  }

                  return FlatReplyItem(
                    replyItem: replyList[replyIndex],
                  );
                },
              );
            });
          },
        ),
      ),
    );
  }
}
