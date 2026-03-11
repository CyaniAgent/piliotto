import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/constants.dart';
import 'package:piliotto/common/widgets/video_card_h.dart';
import 'package:piliotto/common/skeleton/video_card_h.dart';
import './controller.dart';

class RankPage extends StatefulWidget {
  const RankPage({Key? key}) : super(key: key);

  @override
  State<RankPage> createState() => _RankPageState();
}

class _RankPageState extends State<RankPage>
    with AutomaticKeepAliveClientMixin {
  final RankController _rankController = Get.put(RankController());

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('排行榜'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: Obx(() => _buildVideoList()),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
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
        controller: _rankController.tabController,
        tabs: _rankController.tabs.map((e) => Tab(text: e['label'])).toList(),
        isScrollable: false,
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.center,
      ),
    );
  }

  Widget _buildVideoList() {
    if (_rankController.isLoading.value) {
      return _buildLoadingSkeleton();
    }

    if (_rankController.videoList.isEmpty) {
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
      onRefresh: _rankController.onRefresh,
      child: CustomScrollView(
        controller: _rankController.scrollController,
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
                crossAxisCount: _rankController.crossAxisCount.value,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 3 / 1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final video = _rankController.videoList[index];
                  return VideoCardH(
                    videoItem: video,
                    source: 'rank',
                    rankIndex: index + 1,
                  );
                },
                childCount: _rankController.videoList.length,
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
