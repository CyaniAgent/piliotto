import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:piliotto/common/skeleton/dynamic_card.dart';
import 'package:piliotto/common/widgets/no_data.dart';
import 'package:piliotto/utils/feed_back.dart';

import 'provider.dart';
import 'widgets/dynamic_panel.dart';

class DynamicsPage extends ConsumerStatefulWidget {
  const DynamicsPage({super.key});

  @override
  ConsumerState<DynamicsPage> createState() => _DynamicsPageState();
}

class _DynamicsPageState extends ConsumerState<DynamicsPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dynamicsProvider.notifier).queryFollowDynamic();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(dynamicsProvider.notifier).updateCrossAxisCount();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTapTab(int index) {
    feedBack();
    final tabs = ['latest', 'popular'];
    ref.read(dynamicsProvider.notifier).onTabChanged(tabs[index]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final dynamicsState = ref.watch(dynamicsProvider);
    final dynamicsNotifier = ref.read(dynamicsProvider.notifier);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await dynamicsNotifier.onRefresh();
        },
        child: CustomScrollView(
          controller: dynamicsNotifier.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              title: const Text('动态'),
              actions: [
                if (dynamicsState.newDynamicsCount > 0)
                  TextButton(
                    onPressed: () => dynamicsNotifier.loadNewDynamics(),
                    child: Text('有 ${dynamicsState.newDynamicsCount} 条新动态'),
                  ),
              ],
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '最新'),
                  Tab(text: '热门'),
                ],
                onTap: _onTapTab,
              ),
            ),
            if (dynamicsState.isLoadingDynamic && dynamicsState.dynamicsList.isEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: 6,
                    itemBuilder: (context, index) => const DynamicCardSkeleton(),
                  ),
                ),
              )
            else if (dynamicsState.dynamicsList.isEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const NoData(),
                      ElevatedButton(
                        onPressed: () => dynamicsNotifier.queryFollowDynamic(),
                        child: const Text('刷新'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(8),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: dynamicsState.crossAxisCount,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childCount: dynamicsState.dynamicsList.length,
                  itemBuilder: (context, index) {
                    final item = dynamicsState.dynamicsList[index];
                    return DynamicPanel(
                      item: item,
                      onTap: () {
                        dynamicsNotifier.pushDetail(context, item, index);
                      },
                    );
                  },
                ),
              ),
            if (dynamicsState.isLoadingDynamic && dynamicsState.dynamicsList.isNotEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            if (!dynamicsState.hasMore && dynamicsState.dynamicsList.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      '没有更多了',
                      style: TextStyle(color: Theme.of(context).colorScheme.outline),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
