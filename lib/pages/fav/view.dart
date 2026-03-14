import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/skeleton/video_card_h.dart';
import 'package:piliotto/common/widgets/video_card_h.dart';
import 'package:piliotto/pages/fav/index.dart';

class FavPage extends StatefulWidget {
  const FavPage({super.key});

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  final FavController _favController = Get.put(FavController());
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = _favController.scrollController;
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 300) {
          EasyThrottle.throttle('fav', const Duration(seconds: 1), () {
            _favController.onLoad();
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          '我的收藏',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _favController.onRefresh();
        },
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (_favController.isLoading.value &&
          _favController.favoriteList.isEmpty) {
        return ListView.builder(
          itemBuilder: (context, index) {
            return const VideoCardHSkeleton();
          },
          itemCount: 10,
        );
      }

      if (_favController.favoriteList.isEmpty) {
        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              child: Center(
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
              ),
            ),
          ],
        );
      }

      return ListView.builder(
        controller: scrollController,
        itemCount: _favController.favoriteList.length + 1,
        itemBuilder: (context, index) {
          if (index == _favController.favoriteList.length) {
            return Obx(() => Container(
                  height: 60,
                  alignment: Alignment.center,
                  child: Text(
                    _favController.hasMore.value ? '加载中...' : '没有更多了',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 13,
                    ),
                  ),
                ));
          }
          final video = _favController.favoriteList[index];
          return Dismissible(
            key: Key('fav_${video.vid}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              _favController.removeFavorite(video.vid);
            },
            child: VideoCardH(videoItem: video),
          );
        },
      );
    });
  }
}
