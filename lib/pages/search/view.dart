import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/constants.dart';
import 'package:piliotto/common/widgets/video_card_v.dart';
import 'package:piliotto/common/skeleton/video_card_v.dart';
import 'package:piliotto/pages/search/controller.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late VideoSearchController _videoSearchController;
  String? hintText;

  @override
  void initState() {
    super.initState();
    _videoSearchController = Get.put(VideoSearchController());
    hintText = Get.parameters['hintText'];
    if (hintText != null && hintText!.isNotEmpty) {
      _videoSearchController.searchInputController.text = hintText!;
    }
  }

  @override
  void dispose() {
    _videoSearchController.searchFocusNode.dispose();
    _videoSearchController.searchInputController.dispose();
    _videoSearchController.scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchInput(),
        actions: [
          TextButton(
            onPressed: () {
              final keyword = _videoSearchController.searchInputController.text.trim();
              if (keyword.isNotEmpty) {
                _videoSearchController.searchVideos(keyword);
              }
            },
            child: const Text('搜索'),
          ),
        ],
      ),
      body: Obx(() => _buildSearchResult()),
    );
  }

  Widget _buildSearchInput() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            Icons.search,
            size: 18,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _videoSearchController.searchInputController,
              focusNode: _videoSearchController.searchFocusNode,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                final keyword = value.trim();
                if (keyword.isNotEmpty) {
                  _videoSearchController.searchVideos(keyword);
                }
              },
              decoration: InputDecoration(
                hintText: hintText ?? '搜索视频',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.outline,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _videoSearchController.searchInputController,
            builder: (context, value, child) {
              if (value.text.isNotEmpty) {
                return GestureDetector(
                  onTap: () {
                    _videoSearchController.searchInputController.clear();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.clear,
                      size: 18,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                );
              }
              return const SizedBox(width: 12);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResult() {
    if (_videoSearchController.isLoading.value) {
      return _buildLoadingSkeleton();
    }

    if (_videoSearchController.videoList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '输入关键词搜索视频',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 100) {
          _videoSearchController.onLoad();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: _videoSearchController.onRefresh,
        child: CustomScrollView(
          controller: _videoSearchController.scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(StyleString.safeSpace),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _videoSearchController.crossAxisCount.value,
                  mainAxisSpacing: StyleString.cardSpace,
                  crossAxisSpacing: StyleString.cardSpace,
                  childAspectRatio: StyleString.aspectRatio,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return VideoCardV(
                      videoItem: _videoSearchController.videoList[index],
                      crossAxisCount: _videoSearchController.crossAxisCount.value,
                    );
                  },
                  childCount: _videoSearchController.videoList.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Obx(() {
                if (_videoSearchController.isLoadingMore.value) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  );
                }
                if (!_videoSearchController.hasMore.value) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: Text(
                      '没有更多了',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return GridView.builder(
      padding: const EdgeInsets.all(StyleString.safeSpace),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _videoSearchController.crossAxisCount.value,
        mainAxisSpacing: StyleString.cardSpace,
        crossAxisSpacing: StyleString.cardSpace,
        childAspectRatio: StyleString.aspectRatio,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return const VideoCardVSkeleton();
      },
    );
  }
}
