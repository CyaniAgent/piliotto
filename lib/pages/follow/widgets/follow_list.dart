import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/api/models/following.dart';
import 'package:piliotto/common/widgets/no_data.dart';
import 'package:piliotto/pages/follow/index.dart';

import 'follow_item.dart';

class FollowList extends StatefulWidget {
  final FollowController ctr;
  const FollowList({
    super.key,
    required this.ctr,
  });

  @override
  State<FollowList> createState() => _FollowListState();
}

class _FollowListState extends State<FollowList> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.ctr.queryFollowings();
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          EasyThrottle.throttle('follow', const Duration(seconds: 1), () {
            widget.ctr.onLoad();
          });
        }
      },
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => await widget.ctr.onRefresh(),
      child: Obx(
        () {
          if (widget.ctr.isLoading.value && widget.ctr.followList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          List<FollowingUser> list = widget.ctr.followList;

          if (list.isEmpty) {
            return const CustomScrollView(
              slivers: [NoData()],
              physics: AlwaysScrollableScrollPhysics(),
            );
          }

          return ListView.builder(
            controller: scrollController,
            itemCount: list.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == list.length) {
                return Container(
                  height: MediaQuery.of(context).padding.bottom + 60,
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom,
                  ),
                  child: Center(
                    child: Text(
                      widget.ctr.loadingText.value,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }
              return FollowItem(user: list[index]);
            },
          );
        },
      ),
    );
  }
}
