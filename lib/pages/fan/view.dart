import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/api/models/following.dart';
import 'package:piliotto/common/widgets/no_data.dart';

import 'controller.dart';
import 'widgets/fan_item.dart';

class FansPage extends StatefulWidget {
  const FansPage({super.key});

  @override
  State<FansPage> createState() => _FansPageState();
}

class _FansPageState extends State<FansPage> {
  late String mid;
  late FanController _fanController;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    mid = Get.parameters['mid'] ?? '0';
    _fanController = Get.put(FanController(), tag: mid);
    _fanController.queryFans();
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          EasyThrottle.throttle('fan', const Duration(seconds: 1), () {
            _fanController.onLoad();
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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          '${_fanController.name}的粉丝',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => await _fanController.onRefresh(),
        child: Obx(
          () {
            if (_fanController.isLoading.value &&
                _fanController.fanList.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            List<FollowingUser> list = _fanController.fanList;

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
                        _fanController.loadingText.value,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }
                return FanItem(user: list[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
