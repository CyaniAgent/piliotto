import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/repositories/i_dynamics_repository.dart';
import 'package:piliotto/models/dynamics/result.dart';

class MemberDynamicsController extends GetxController {
  final IDynamicsRepository _dynamicsRepo = Get.find<IDynamicsRepository>();
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
    try {
      final blogList = await _dynamicsRepo.getUserBlogs(uid: mid, offset: offset, num: 10);
      if (blogList.isNotEmpty) {
        dynamicsList.addAll(blogList);
        offset += blogList.length;
        count += blogList.length;
        hasMore = blogList.length == 10;
      } else {
        hasMore = false;
      }
      return {'status': 'success'};
    } catch (e) {
      return {'status': 'fail', 'message': e.toString()};
    }
  }

  // 上拉加载
  Future onLoad() async {
    getMemberDynamic('onLoad');
  }
}
