import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/api/services/old_api_service.dart';
import 'package:piliotto/models/user/fav_folder.dart';
import 'package:piliotto/utils/storage.dart';

class MediaController extends GetxController {
  Rx<FavFolderData> favFolderData = FavFolderData().obs;
  Box userInfoCache = GStrorage.userInfo;
  RxBool userLogin = false.obs;
  List list = [
    {
      'icon': Icons.history,
      'title': '观看记录',
      'onTap': () => Get.toNamed('/history'),
    },
    {
      'icon': Icons.star_border,
      'title': '我的收藏',
      'onTap': () => Get.toNamed('/fav'),
    },
  ];
  dynamic userInfo;
  int? mid;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    userInfo = userInfoCache.get('userInfoCache');
    userLogin.value = userInfo != null;
  }

  Future<dynamic> queryFavFolder() async {
    if (!userLogin.value) {
      return {'status': false, 'data': [], 'msg': '未登录'};
    }
    try {
      final res = await OldApiService.getFavoriteVideoList(offset: 0, num: 5);
      if (res['status'] == 'success') {
        return {'status': true, 'data': res};
      } else {
        return {'status': false, 'msg': res['message'] ?? '获取收藏失败'};
      }
    } catch (e) {
      return {'status': false, 'msg': e.toString()};
    }
  }
}
