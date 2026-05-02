import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:piliotto/ottohub/api/models/following.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/common/widgets/no_data.dart';
import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/utils.dart';

class UserListPage extends StatefulWidget {
  final String title;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoad;
  final Future<void> Function() onInit;
  final List<FollowingUser> userList;
  final bool isLoading;
  final bool hasMore;
  final String loadingText;

  const UserListPage({
    super.key,
    required this.title,
    required this.onRefresh,
    required this.onLoad,
    required this.onInit,
    required this.userList,
    required this.isLoading,
    required this.hasMore,
    required this.loadingText,
  });

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    widget.onInit();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      EasyThrottle.throttle('userList', const Duration(seconds: 1), () {
        widget.onLoad();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 16,
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: Builder(
          builder: (context) {
            if (widget.isLoading && widget.userList.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (widget.userList.isEmpty) {
              return const CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: NoData()),
                ],
                physics: AlwaysScrollableScrollPhysics(),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: widget.userList.length + 1,
              itemBuilder: (context, index) {
                if (index == widget.userList.length) {
                  return Container(
                    height: MediaQuery.of(context).padding.bottom + 60,
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom,
                    ),
                    child: Center(
                      child: Text(
                        widget.loadingText,
                        style: TextStyle(
                          color: colorScheme.outline,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }

                final user = widget.userList[index];
                final heroTag = Utils.makeHeroTag(user.uid);

                return ListTile(
                  onTap: () {
                    feedBack();
                    context.push(
                      '/member?mid=${user.uid}',
                      extra: {
                        'face': user.avatarUrl,
                        'heroTag': heroTag,
                      },
                    );
                  },
                  leading: Hero(
                    tag: heroTag,
                    child: NetworkImgLayer(
                      width: 40,
                      height: 40,
                      type: 'avatar',
                      src: user.avatarUrl,
                    ),
                  ),
                  title: Text(
                    user.username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
