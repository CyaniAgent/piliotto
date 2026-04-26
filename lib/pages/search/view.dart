import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/common/constants.dart';
import 'package:piliotto/common/skeleton/video_card_h.dart';
import 'package:piliotto/common/widgets/video_card_h.dart';
import 'package:piliotto/pages/search/controller.dart';
import 'package:piliotto/utils/responsive_util.dart';
import 'package:piliotto/utils/storage.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late VideoSearchController _videoSearchController;
  final SearchController _searchController = SearchController();
  final Box _historyBox = GStrorage.historyword;
  List<String> _searchHistory = [];
  String? hintText;
  String? initialKeyword;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _videoSearchController = Get.put(VideoSearchController());
    hintText = Get.parameters['hintText'];
    initialKeyword = Get.parameters['keyword'];
    _loadSearchHistory();

    if (initialKeyword != null && initialKeyword!.isNotEmpty) {
      _searchController.text = initialKeyword!;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasSearched && initialKeyword != null && initialKeyword!.isNotEmpty) {
      _hasSearched = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _videoSearchController.searchVideos(initialKeyword!);
        }
      });
    }
  }

  void _loadSearchHistory() {
    final history = _historyBox.get('searchHistory', defaultValue: <String>[]);
    setState(() {
      _searchHistory = List<String>.from(history);
    });
  }

  void _saveSearchHistory(String keyword) {
    if (keyword.trim().isEmpty) return;
    _searchHistory.remove(keyword);
    _searchHistory.insert(0, keyword);
    if (_searchHistory.length > 20) {
      _searchHistory = _searchHistory.sublist(0, 20);
    }
    _historyBox.put('searchHistory', _searchHistory);
  }

  void _clearSearchHistory() {
    setState(() {
      _searchHistory.clear();
    });
    _historyBox.put('searchHistory', <String>[]);
  }

  void _onSearch(String keyword, {bool closeView = true}) {
    if (keyword.trim().isEmpty) return;
    _saveSearchHistory(keyword.trim());
    if (closeView) {
      _searchController.closeView(null);
    }
    _videoSearchController.searchVideos(keyword.trim());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _videoSearchController.scrollController.dispose();
    Get.delete<VideoSearchController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = ResponsiveUtil.isMd;
    double maxContentWidth = 800;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWideScreen ? 500 : double.infinity,
                      ),
                      child: _buildSearchInput(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: Obx(
          () => _buildSearchResult(screenWidth, isWideScreen, maxContentWidth)),
    );
  }

  Widget _buildSearchInput() {
    return SearchAnchor(
      searchController: _searchController,
      viewHintText: hintText ?? '搜索视频',
      viewOnSubmitted: (value) {
        _onSearch(value);
      },
      viewTrailing: [
        IconButton(
          onPressed: () {
            _onSearch(_searchController.text);
          },
          icon: const Icon(Icons.search),
        ),
      ],
      builder: (context, controller) {
        return SearchBar(
          controller: controller,
          hintText: hintText ?? '搜索视频',
          leading: const Icon(Icons.search_outlined),
          onTap: () {
            controller.openView();
          },
          onChanged: (_) {
            controller.openView();
          },
          onSubmitted: (value) {
            _onSearch(value);
          },
          trailing: [
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                if (value.text.isNotEmpty) {
                  return IconButton(
                    onPressed: () {
                      controller.clear();
                    },
                    icon: const Icon(Icons.clear),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return 3.0;
            }
            return 0.0;
          }),
        );
      },
      suggestionsBuilder: (context, controller) {
        final query = controller.text.toLowerCase();
        final filteredHistory = query.isEmpty
            ? _searchHistory
            : _searchHistory
                .where((item) => item.toLowerCase().contains(query))
                .toList();

        if (filteredHistory.isEmpty && query.isEmpty) {
          return [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '暂无搜索历史',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ),
          ];
        }

        final List<Widget> suggestions = [
          if (_searchHistory.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '搜索历史',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  TextButton(
                    onPressed: _clearSearchHistory,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('清空'),
                  ),
                ],
              ),
            ),
          ],
        ];

        suggestions.addAll(
          filteredHistory.map((item) {
            return ListTile(
              leading: const Icon(Icons.history, size: 20),
              title: Text(item),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  setState(() {
                    _searchHistory.remove(item);
                    _historyBox.put('searchHistory', _searchHistory);
                  });
                },
              ),
              onTap: () {
                controller.closeView(item);
                _onSearch(item, closeView: false);
              },
              dense: true,
              visualDensity: VisualDensity.compact,
            );
          }),
        );

        return suggestions;
      },
    );
  }

  Widget _buildSearchResult(
      double screenWidth, bool isWideScreen, double maxContentWidth) {
    if (_videoSearchController.isLoading.value) {
      return _buildLoadingSkeleton(screenWidth, isWideScreen, maxContentWidth);
    }

    if (_videoSearchController.hasError.value) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _videoSearchController.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _videoSearchController.retrySearch,
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ],
          ),
        ),
      );
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
              _videoSearchController.currentKeyword.value.isEmpty
                  ? '输入关键词搜索视频'
                  : '未找到相关视频',
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
