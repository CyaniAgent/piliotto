import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:piliotto/common/skeleton/video_card_h.dart';
import 'package:piliotto/common/widgets/video_card_h.dart';
import 'package:piliotto/pages/fav/index.dart';

class FavPage extends ConsumerStatefulWidget {
  const FavPage({super.key});

  @override
  ConsumerState<FavPage> createState() => _FavPageState();
}

class _FavPageState extends ConsumerState<FavPage> {
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 300) {
          EasyThrottle.throttle('fav', const Duration(seconds: 1), () {
            ref.read(favProvider.notifier).onLoad();
          });
        }
      },
    );
    Future.microtask(() {
      ref.read(favProvider.notifier).queryFavorites();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(favProvider.notifier).updateCrossAxisCount();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favProvider);

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
          await ref.read(favProvider.notifier).onRefresh();
        },
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(FavState state) {
    if (state.isLoading && state.favoriteList.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: state.crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 3 / 1,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                return const VideoCardHSkeleton();
              }, childCount: 10),
            ),
          ),
        ],
      );
    }

    if (state.favoriteList.isEmpty) {
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

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: state.crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 3 / 1,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final video = state.favoriteList[index];
              return VideoCardH(videoItem: video);
            }, childCount: state.favoriteList.length),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            height: 60,
            alignment: Alignment.center,
            child: Text(
              state.hasMore ? '加载中...' : '没有更多了',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 13,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).padding.bottom + 10,
          ),
        ),
      ],
    );
  }
}
