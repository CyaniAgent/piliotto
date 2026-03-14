import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/skeleton/video_card_h.dart';
import 'package:piliotto/common/widgets/video_card_h.dart';
import 'package:piliotto/pages/fav_detail/index.dart';

class FavDetailPage extends StatefulWidget {
  const FavDetailPage({super.key});

  @override
  State<FavDetailPage> createState() => _FavDetailPageState();
}

class _FavDetailPageState extends State<FavDetailPage> {
  final FavDetailController _favDetailController =
      Get.put(FavDetailController());
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
            _favDetailController.onLoad();
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Obx(
          () => Text(
            _favDetailController.title.value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
      body: Obx(() {
        if (_favDetailController.isLoading.value &&
            _favDetailController.favList.isEmpty) {
          return ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return const VideoCardHSkeleton();
            },
          );
        }

        if (_favDetailController.favList.isEmpty) {
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
            await _favDetailController.onRefresh();
          },
          child: ListView.builder(
            controller: _controller,
            itemCount: _favDetailController.favList.length + 1,
            itemBuilder: (context, index) {
              if (index == _favDetailController.favList.length) {
                return Container(
                  height: 60,
                  alignment: Alignment.center,
                  child: Text(
                    _favDetailController.hasMore.value ? '加载中...' : '没有更多了',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 13,
                    ),
                  ),
                );
              }
              final video = _favDetailController.favList[index];
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
                  _favDetailController.removeFavorite(video.vid);
                },
                child: VideoCardH(videoItem: video),
              );
            },
          ),
        );
      }),
    );
  }
}
