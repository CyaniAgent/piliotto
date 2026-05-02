import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:piliotto/common/constants.dart';
import 'package:piliotto/common/widgets/video_card_h.dart';
import 'package:piliotto/common/skeleton/video_card_h.dart';
import 'package:piliotto/pages/rank/provider.dart';
import 'package:piliotto/utils/feed_back.dart';

class RankPage extends ConsumerStatefulWidget {
  const RankPage({super.key});

  @override
  ConsumerState<RankPage> createState() => _RankPageState();
}

class _RankPageState extends ConsumerState<RankPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(rankProvider.notifier);
      notifier.initTabController(this);
      notifier.loadVideos();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(rankProvider);
    final notifier = ref.read(rankProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('排行榜'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildTabBar(state, notifier),
          Expanded(
            child: _buildVideoList(state, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(RankState state, RankNotifier notifier) {
    return Container(
      width: double.infinity,
      height: 42,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: TabBar(
        controller: notifier.tabController,
        tabs: notifier.tabs.map((e) => Tab(text: e['label'])).toList(),
        isScrollable: false,
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.center,
        onTap: (value) {
          feedBack();
          if (value == state.currentTabIndex) {
            notifier.animateToTop();
          }
        },
      ),
    );
  }

  Widget _buildVideoList(RankState state, RankNotifier notifier) {
    if (state.isLoading) {
      return _buildLoadingSkeleton();
    }

    if (state.videoList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无数据',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: notifier.onRefresh,
      child: CustomScrollView(
        controller: notifier.scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              StyleString.safeSpace,
              StyleString.safeSpace - 5,
              StyleString.safeSpace,
              0,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: state.crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 3 / 1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final video = state.videoList[index];
                  return VideoCardH(
                    videoItem: video,
                    source: 'rank',
                    rankIndex: index + 1,
                  );
                },
                childCount: state.videoList.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(StyleString.safeSpace),
      itemCount: 10,
      itemBuilder: (context, index) {
        return const VideoCardHSkeleton();
      },
    );
  }
}
