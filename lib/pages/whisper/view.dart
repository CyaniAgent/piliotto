import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/constants.dart';
import 'package:piliotto/common/skeleton/skeleton.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/utils/utils.dart';
import 'package:piliotto/api/models/message.dart';

import 'controller.dart';

class WhisperPage extends StatefulWidget {
  const WhisperPage({super.key});

  @override
  State<WhisperPage> createState() => _WhisperPageState();
}

class _WhisperPageState extends State<WhisperPage> {
  late final WhisperController _whisperController =
      Get.put(WhisperController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  Future _scrollListener() async {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      EasyThrottle.throttle('my-throttler', const Duration(milliseconds: 800),
          () async {
        await _whisperController.onLoad();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _whisperController.onRefresh();
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: SizedBox(
                      height: constraints.maxWidth / 4,
                      child: Obx(
                        () => GridView.count(
                          primary: false,
                          crossAxisCount: 4,
                          padding: const EdgeInsets.all(0),
                          children: [
                            ..._whisperController.noticesList.map((element) {
                              return InkWell(
                                onTap: () {
                                  if (['/messageAt']
                                      .contains(element['path'])) {
                                    SmartDialog.showToast('功能开发中');
                                    return;
                                  }
                                  Get.toNamed(element['path']);

                                  if (element['count'] > 0) {
                                    element['count'] = 0;
                                  }
                                  _whisperController.noticesList.refresh();
                                },
                                onLongPress: () {},
                                borderRadius: StyleString.mdRadius,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Badge(
                                      isLabelVisible: element['count'] > 0,
                                      label: Text(element['count'] > 99
                                          ? '99+'
                                          : element['count'].toString()),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Icon(
                                          element['icon'],
                                          size: 21,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(element['title'])
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              Obx(() {
                final friendList = _whisperController.friendList;
                if (_whisperController.isLoading && friendList.isEmpty) {
                  return ListView.builder(
                    itemCount: 15,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, int i) {
                      return Skeleton(
                        child: ListTile(
                          leading: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface,
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          title: Container(
                            width: 100,
                            height: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onInverseSurface,
                          ),
                          subtitle: Container(
                            width: 80,
                            height: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onInverseSurface,
                          ),
                        ),
                      );
                    },
                  );
                }
                if (friendList.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Text('暂无消息'),
                  );
                }
                return ListView.separated(
                  itemCount: friendList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (_, int i) {
                    return FriendItem(
                      friend: friendList[i],
                      onTap: () {
                        Get.toNamed(
                          '/whisperDetail',
                          parameters: {
                            'friendUid': friendList[i].uid.toString(),
                            'name': friendList[i].username,
                            'face': friendList[i].avatarUrl ?? '',
                            'mid': friendList[i].uid.toString(),
                            'heroTag': Utils.makeHeroTag(friendList[i].uid),
                          },
                        );
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      indent: 72,
                      endIndent: 20,
                      height: 6,
                      color: Colors.grey.withValues(alpha: 0.1 * 255),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class FriendItem extends StatelessWidget {
  final Friend friend;
  final VoidCallback onTap;

  const FriendItem({
    super.key,
    required this.friend,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String heroTag = Utils.makeHeroTag(friend.uid);

    return ListTile(
      onTap: onTap,
      leading: Badge(
        isLabelVisible: (friend.newMessageNum ?? 0) > 0,
        label: Text(friend.newMessageNum.toString()),
        alignment: Alignment.topRight,
        child: Hero(
          tag: heroTag,
          child: NetworkImgLayer(
            width: 45,
            height: 45,
            type: 'avatar',
            src: friend.avatarUrl ?? '',
          ),
        ),
      ),
      title: Text(friend.username),
      subtitle: Text(
        friend.lastMessage ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context)
            .textTheme
            .labelMedium!
            .copyWith(color: Theme.of(context).colorScheme.outline),
      ),
      trailing: Text(
        friend.lastTime != null ? Utils.dateFormat(friend.lastTime) : '',
        style: TextStyle(
          fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}
