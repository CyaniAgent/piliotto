import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/pages/member_dynamics/index.dart';
import 'package:piliotto/utils/responsive_util.dart';
import 'package:piliotto/utils/utils.dart';

import '../../common/widgets/http_error.dart';
import '../../models/dynamics/result.dart';
import '../dynamics/widgets/dynamic_panel.dart';

class MemberDynamicsPage extends StatefulWidget {
  const MemberDynamicsPage({super.key});

  @override
  State<MemberDynamicsPage> createState() => _MemberDynamicsPageState();
}

class _MemberDynamicsPageState extends State<MemberDynamicsPage> {
  late MemberDynamicsController _memberDynamicController;
  late Future _futureBuilderFuture;
  late ScrollController scrollController;
  late int mid;

  @override
  void initState() {
    super.initState();
    mid = int.parse(Get.parameters['mid']!);
    final String heroTag = Utils.makeHeroTag(mid);
    _memberDynamicController =
        Get.put(MemberDynamicsController(), tag: heroTag);
    _futureBuilderFuture =
        _memberDynamicController.getMemberDynamic('onRefresh');
    scrollController = _memberDynamicController.scrollController;
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      EasyThrottle.throttle(
          'member_dynamics', const Duration(milliseconds: 1000), () {
        _memberDynamicController.onLoad();
      });
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = ResponsiveUtil.isLg || ResponsiveUtil.isXl;
    final screenWidth = MediaQuery.of(context).size.width;
    const maxContentWidth = 600.0;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: false,
        title: Text('他的动态', style: Theme.of(context).textTheme.titleMedium),
      ),
      body: FutureBuilder(
        future: _futureBuilderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null) {
              Map data = snapshot.data as Map;
              RxList<DynamicItemModel> list =
                  _memberDynamicController.dynamicsList;
              if (data['status'] == 'success') {
                return Obx(
                  () => list.isNotEmpty
                      ? ListView.builder(
                          controller: scrollController,
                          padding: _buildPadding(
                              isWideScreen, screenWidth, maxContentWidth),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              width: isWideScreen ? maxContentWidth : null,
                              child: DynamicPanel(
                                item: list[index],
                                onTap: () => Get.toNamed('/dynamicDetail',
                                    arguments: {
                                      'item': list[index],
                                      'floor': 1,
                                    }),
                                onCommentTap: () => Get.toNamed(
                                    '/dynamicDetail',
                                    arguments: {
                                      'item': list[index],
                                      'floor': 1,
                                      'action': 'comment',
                                    }),
                              ),
                            );
                          },
                        )
                      : const Center(child: Text('暂无动态')),
                );
              } else {
                return HttpError(
                  errMsg: data['message'] ?? '加载失败，请稍后重试',
                  fn: () {},
                );
              }
            } else {
              return HttpError(
                errMsg: '加载失败，请稍后重试',
                fn: () {},
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  EdgeInsets _buildPadding(
      bool isWideScreen, double screenWidth, double maxWidth) {
    if (isWideScreen) {
      final horizontalPadding = (screenWidth - maxWidth) / 2;
      return EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 80,
      );
    }
    return const EdgeInsets.only(
      left: 12,
      right: 12,
      top: 8,
      bottom: 80,
    );
  }
}
