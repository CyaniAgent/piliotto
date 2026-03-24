import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/widgets/user_list_page.dart';
import 'controller.dart';

class FansPage extends StatelessWidget {
  const FansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String mid = Get.parameters['mid'] ?? '0';
    final FanController controller = Get.put(FanController(), tag: mid);

    return UserListPage(
      title: '${controller.name}的粉丝',
      onRefresh: controller.onRefresh,
      onLoad: controller.onLoad,
      onInit: controller.onRefresh,
      userList: controller.fanList,
      isLoading: controller.isLoading,
      hasMore: controller.hasMore,
      loadingText: controller.loadingText,
    );
  }
}
