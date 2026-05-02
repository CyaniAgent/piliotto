import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:piliotto/common/skeleton/video_card_h.dart';
import 'package:piliotto/common/widgets/http_error.dart';
import 'package:piliotto/common/widgets/no_data.dart';
import 'package:piliotto/pages/history/provider.dart';
import 'package:piliotto/utils/route_push.dart';

import 'widgets/item.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  Future<Map<String, dynamic>>? _futureBuilderFuture;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    final notifier = ref.read(historyProvider.notifier);
    scrollController = notifier.scrollController;
    scrollController.addListener(
      () {
        final state = ref.read(historyProvider);
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 300) {
          if (!state.isLoadingMore) {
            EasyThrottle.throttle('history', const Duration(seconds: 1), () {
              notifier.onLoad();
            });
          }
        }
      },
    );
    _futureBuilderFuture = notifier.queryHistoryList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(historyProvider.notifier).updateCrossAxisCount();
      }
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);
    final notifier = ref.read(historyProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: false,
        title: Text(
          '观看记录',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String type) {
              switch (type) {
                case 'clear':
                  notifier.onClearHistory();
                  break;
                default:
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'clear',
                child: Text('清空观看记录'),
              ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await notifier.onRefresh();
          return;
        },
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              sliver: FutureBuilder(
                future: _futureBuilderFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data == null) {
                      return const SliverToBoxAdapter(child: SizedBox());
                    }
                    Map? data = snapshot.data;
                    if (data != null && data['status']) {
                      return state.historyList.isNotEmpty
                          ? SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: state.crossAxisCount,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 3 / 1,
                              ),
                              delegate:
                                  SliverChildBuilderDelegate((context, index) {
                                return HistoryItem(
                                  videoItem: state.historyList[index],
                                );
                              }, childCount: state.historyList.length),
                            )
                          : SliverToBoxAdapter(
                              child: state.isLoadingMore
                                  ? const Center(child: Text('加载中'))
                                  : const NoData(),
                            );
                    } else {
                      return HttpError(
                        isSliver: true,
                        errMsg: data?['msg'] ?? '请求异常',
                        btnText: data?['code'] == -101 ? '去登录' : null,
                        fn: () {
                          if (data?['code'] == -101) {
                            RoutePush.loginRedirectPush();
                          } else {
                            setState(() {
                              _futureBuilderFuture =
                                  notifier.queryHistoryList();
                            });
                          }
                        },
                      );
                    }
                  } else {
                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: state.crossAxisCount,
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
      ),
    );
  }
}
