import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/skeleton/video_card_h.dart';
import 'package:piliotto/common/widgets/http_error.dart';
import 'package:piliotto/common/widgets/no_data.dart';
import 'package:piliotto/pages/history/index.dart';
import 'package:piliotto/utils/route_push.dart';

import 'widgets/item.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryController _historyController = Get.put(HistoryController());
  Future? _futureBuilderFuture;
  late ScrollController scrollController;

  @override
  void initState() {
    _futureBuilderFuture = _historyController.queryHistoryList();
    super.initState();
    scrollController = _historyController.scrollController;
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 300) {
          if (!_historyController.isLoadingMore.value) {
            EasyThrottle.throttle('history', const Duration(seconds: 1), () {
              _historyController.onLoad();
            });
          }
        }
      },
    );
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  _historyController.onClearHistory();
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
          await _historyController.onRefresh();
          return;
        },
        child: CustomScrollView(
          controller: _historyController.scrollController,
          slivers: [
            FutureBuilder(
              future: _futureBuilderFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data == null) {
                    return const SliverToBoxAdapter(child: SizedBox());
                  }
                  Map? data = snapshot.data;
                  if (data != null && data['status']) {
                    return Obx(
                      () => _historyController.historyList.isNotEmpty
                          ? SliverList(
                              delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                return HistoryItem(
                                  videoItem:
                                      _historyController.historyList[index],
                                );
                              },
                                  childCount:
                                      _historyController.historyList.length),
                            )
                          : _historyController.isLoadingMore.value
                              ? const SliverToBoxAdapter(
                                  child: Center(child: Text('加载中')),
                                )
                              : const NoData(),
                    );
                  } else {
                    return HttpError(
                      errMsg: data?['msg'] ?? '请求异常',
                      btnText: data?['code'] == -101 ? '去登录' : null,
                      fn: () {
                        if (data?['code'] == -101) {
                          RoutePush.loginRedirectPush();
                        } else {
                          setState(() {
                            _futureBuilderFuture =
                                _historyController.queryHistoryList();
                          });
                        }
                      },
                    );
                  }
                } else {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return const VideoCardHSkeleton();
                    }, childCount: 10),
                  );
                }
              },
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
