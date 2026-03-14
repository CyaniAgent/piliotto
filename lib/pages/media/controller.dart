import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/http/user.dart';
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
    var res = await await UserHttp.userfavFolder(
      pn: 1,
      ps: 5,
      mid: mid ?? GStrorage.userInfo.get('userInfoCache').mid,
    );
    favFolderData.value = res['data'];
    return res;
  }
}
