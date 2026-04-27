import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/repositories/i_video_repository.dart';
import 'package:piliotto/models/user/fav_folder.dart';
import 'package:piliotto/utils/storage.dart';

class MediaController extends GetxController {
  final IVideoRepository _videoRepo = Get.find<IVideoRepository>();
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
      final response = await _videoRepo.getFavoriteVideos(offset: 0, num: 5);
      return {'status': true, 'data': response};
    } catch (e) {
      return {'status': false, 'msg': e.toString()};
    }
  }
}
