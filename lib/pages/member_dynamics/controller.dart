import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/api/services/old_api_service.dart';
import 'package:piliotto/models/dynamics/result.dart';

class MemberDynamicsController extends GetxController {
  final ScrollController scrollController = ScrollController();
  late int mid;
  int offset = 0;
  int count = 0;
  bool hasMore = true;
  RxList<DynamicItemModel> dynamicsList = <DynamicItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    mid = int.parse(Get.parameters['mid']!);
  }

  Future<Map<String, dynamic>> getMemberDynamic(String type) async {
    if (type == 'onRefresh') {
      offset = 0;
      dynamicsList.clear();
      count = 0;
      hasMore = true;
    }
    if (!hasMore) {
      return {};
    }
    var res = await OldApiService.getUserBlogList(
      uid: mid,
      offset: offset,
      num: 10,
    );
    if (res['status'] == 'success') {
      final blogList = res['blog_list'] ?? [];
      if (blogList.isNotEmpty) {
        // 转换数据格式
        for (var blog in blogList) {
          dynamicsList.add(DynamicItemModel.fromJson(blog));
        }
        offset += blogList.length as int;
        count += blogList.length as int;
        hasMore = (blogList.length as int) == 10;
      } else {
        hasMore = false;
      }
    }
    return res;
  }

  // 上拉加载
  Future onLoad() async {
    getMemberDynamic('onLoad');
  }
}
