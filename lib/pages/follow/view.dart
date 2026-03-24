import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/widgets/user_list_page.dart';
import 'controller.dart';

class FollowPage extends StatelessWidget {
  const FollowPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String mid = Get.parameters['mid'] ?? '0';
    final FollowController controller = Get.put(FollowController(), tag: mid);

    return UserListPage(
      title: '${controller.name}的关注',
      onRefresh: controller.onRefresh,
      onLoad: controller.onLoad,
      onInit: controller.onRefresh,
      userList: controller.followList,
      isLoading: controller.isLoading,
      hasMore: controller.hasMore,
      loadingText: controller.loadingText,
    );
  }
}
