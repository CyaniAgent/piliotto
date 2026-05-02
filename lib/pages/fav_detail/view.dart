import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:piliotto/common/skeleton/video_card_h.dart';
import 'package:piliotto/common/widgets/video_card_h.dart';
import 'package:piliotto/pages/fav_detail/provider.dart';

class FavDetailPage extends ConsumerStatefulWidget {
  const FavDetailPage({super.key});

  @override
  ConsumerState<FavDetailPage> createState() => _FavDetailPageState();
}

class _FavDetailPageState extends ConsumerState<FavDetailPage> {
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(
      () {
        if (_controller.position.pixels >=
            _controller.position.maxScrollExtent - 200) {
          EasyThrottle.throttle('favDetail', const Duration(seconds: 1), () {
            ref.read(favDetailProvider.notifier).onLoad();
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favDetailProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          state.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading && state.favList.isEmpty) {
            return ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return const VideoCardHSkeleton();
              },
            );
          }

          if (state.favList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无收藏',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(favDetailProvider.notifier).onRefresh();
            },
            child: ListView.builder(
              controller: _controller,
              itemCount: state.favList.length + 1,
              itemBuilder: (context, index) {
                if (index == state.favList.length) {
                  return Container(
                    height: 60,
                    alignment: Alignment.center,
                    child: Text(
                      state.hasMore ? '加载中...' : '没有更多了',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 13,
                      ),
                    ),
                  );
                }
                final video = state.favList[index];
                return Dismissible(
                  key: Key('fav_detail_${video.vid}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    ref.read(favDetailProvider.notifier).removeFavorite(video.vid);
                  },
                  child: VideoCardH(videoItem: video),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
