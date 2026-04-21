import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/constants.dart';
import 'package:piliotto/common/skeleton/video_card_h.dart';
import 'package:piliotto/common/widgets/video_card_h.dart';
import 'package:piliotto/pages/search/controller.dart';
import 'package:piliotto/utils/responsive_util.dart';

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
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = ResponsiveUtil.isMd;
    double maxContentWidth = 800;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _buildSearchInput(colorScheme),
        actions: [
          TextButton(
            onPressed: () {
              String keyword =
                  _videoSearchController.searchInputController.text.trim();
              if (keyword.isEmpty && hintText != null && hintText!.isNotEmpty) {
                keyword = hintText!;
              }
              if (keyword.isNotEmpty) {
                _videoSearchController.searchVideos(keyword);
              }
            },
            child: const Text('搜索'),
          ),
        ],
      ),
      body: Obx(
          () => _buildSearchResult(screenWidth, isWideScreen, maxContentWidth)),
    );
  }

  Widget _buildSearchInput(ColorScheme colorScheme) {
    return Hero(
      tag: 'searchBar',
      child: Material(
        color: Colors.transparent,
        child: SearchBar(
          controller: _videoSearchController.searchInputController,
          focusNode: _videoSearchController.searchFocusNode,
          hintText: hintText ?? '搜索视频',
          autoFocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            String keyword = value.trim();
            if (keyword.isEmpty && hintText != null && hintText!.isNotEmpty) {
              keyword = hintText!;
            }
            if (keyword.isNotEmpty) {
              _videoSearchController.searchVideos(keyword);
            }
          },
          leading: Icon(
            Icons.search,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          trailing: [
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _videoSearchController.searchInputController,
              builder: (context, value, child) {
                if (value.text.isNotEmpty) {
                  return IconButton(
                    onPressed: () {
                      _videoSearchController.searchInputController.clear();
                    },
                    icon: Icon(
                      Icons.clear,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
          constraints: const BoxConstraints(minHeight: 40, maxHeight: 40),
          shape: WidgetStateProperty.all(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
          backgroundColor: WidgetStateProperty.all(
            colorScheme.surfaceContainerHighest,
          ),
          elevation: WidgetStateProperty.all(0),
          textStyle: WidgetStateProperty.all(
            TextStyle(fontSize: 14, color: colorScheme.onSurface),
          ),
          hintStyle: WidgetStateProperty.all(
            TextStyle(fontSize: 14, color: colorScheme.outline),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResult(
      double screenWidth, bool isWideScreen, double maxContentWidth) {
    if (_videoSearchController.isLoading.value) {
      return _buildLoadingSkeleton(screenWidth, isWideScreen, maxContentWidth);
    }

    if (_videoSearchController.videoList.isEmpty) {
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
              padding: const EdgeInsets.fromLTRB(
                StyleString.safeSpace,
                StyleString.safeSpace - 5,
                StyleString.safeSpace,
                0,
              ),
              sliver: SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      isWideScreen ? (screenWidth - maxContentWidth) / 2 : 0,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _videoSearchController.crossAxisCount.value,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 3 / 1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return VideoCardH(
                        videoItem: _videoSearchController.videoList[index],
                        source: 'search',
                      );
                    },
                    childCount: _videoSearchController.videoList.length,
                  ),
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

  Widget _buildLoadingSkeleton(
      double screenWidth, bool isWideScreen, double maxContentWidth) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            StyleString.safeSpace,
            StyleString.safeSpace - 5,
            StyleString.safeSpace,
            0,
          ),
          sliver: SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal:
                  isWideScreen ? (screenWidth - maxContentWidth) / 2 : 0,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _videoSearchController.crossAxisCount.value,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 3 / 1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return const VideoCardHSkeleton();
                },
                childCount: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
