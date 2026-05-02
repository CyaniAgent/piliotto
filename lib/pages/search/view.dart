import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:piliotto/common/constants.dart';
import 'package:piliotto/common/skeleton/video_card_h.dart';
import 'package:piliotto/common/widgets/video_card_h.dart';
import 'package:piliotto/pages/search/provider.dart';
import 'package:piliotto/services/search_history_service.dart';
import 'package:piliotto/utils/responsive_util.dart';
import 'package:piliotto/utils/route_arguments.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final SearchController _searchController = SearchController();
  final SearchHistoryService _historyService = SearchHistoryService();
  String? hintText;
  String? initialKeyword;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    hintText = routeArguments.queryParameters['hintText'];
    initialKeyword = routeArguments.queryParameters['keyword'];
    _historyService.loadSearchHistory();

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
          ref.read(searchProvider.notifier).searchVideos(initialKeyword!);
        }
      });
    }
  }

  void _onSearch(String keyword, {bool closeView = true}) {
    if (keyword.trim().isEmpty) return;
    _historyService.saveSearchHistory(keyword.trim());
    if (closeView) {
      _searchController.closeView(null);
    }
    ref.read(searchProvider.notifier).searchVideos(keyword.trim());
  }

  @override
  void dispose() {
    _searchController.dispose();
    ref.read(searchProvider.notifier).scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = ResponsiveUtil.isMd;
    double maxContentWidth = 800;
    final state = ref.watch(searchProvider);

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
      body: _buildSearchResult(screenWidth, isWideScreen, maxContentWidth, state),
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
        final query = controller.text;
        final filteredHistory = _historyService.filterSearchHistory(query);

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
          if (_historyService.currentHistory.isNotEmpty) ...[
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
                    onPressed: () {
                      setState(() {});
                      _historyService.clearSearchHistory();
                    },
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
                  setState(() {});
                  _historyService.removeSearchHistory(item);
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
      double screenWidth, bool isWideScreen, double maxContentWidth, dynamic state) {
    if (state.isLoading) {
      return _buildLoadingSkeleton(screenWidth, isWideScreen, maxContentWidth, state.crossAxisCount);
    }

    if (state.hasError) {
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
                state.errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => ref.read(searchProvider.notifier).retrySearch(),
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ],
          ),
        ),
      );
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
              state.currentKeyword.isEmpty
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

    final scrollController = ref.read(searchProvider.notifier).scrollController;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 100) {
          ref.read(searchProvider.notifier).onLoad();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => ref.read(searchProvider.notifier).onRefresh(),
        child: CustomScrollView(
          controller: scrollController,
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
                    crossAxisCount: state.crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 3 / 1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return VideoCardH(
                        videoItem: state.videoList[index],
                        source: 'search',
                      );
                    },
                    childCount: state.videoList.length,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Builder(
                builder: (context) {
                  if (state.isLoadingMore) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    );
                  }
                  if (!state.hasMore) {
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(
      double screenWidth, bool isWideScreen, double maxContentWidth, int crossAxisCount) {
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
                crossAxisCount: crossAxisCount,
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
