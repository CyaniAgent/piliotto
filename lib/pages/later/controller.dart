import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
// TODO: 迁移到 Ottohub API
// import 'package:piliotto/http/user.dart';
import 'package:piliotto/models/model_hot_video_item.dart';
import 'package:piliotto/models/user/info.dart';
import 'package:piliotto/utils/storage.dart';

class LaterController extends GetxController {
  final ScrollController scrollController = ScrollController();
  RxList<HotVideoItemModel> laterList = <HotVideoItemModel>[].obs;
  int count = 0;
  RxBool isLoading = false.obs;
  Box userInfoCache = GStrorage.userInfo;
  UserInfoData? userInfo;

  @override
  void onInit() {
    super.onInit();
    userInfo = userInfoCache.get('userInfoCache');
  }

  Future queryLaterList() async {
    // TODO: 迁移到 Ottohub API
    // if (userInfo == null) {
    //   return {'status': false, 'msg': '账号未登录', 'code': -101};
    // }
    // isLoading.value = true;
    // var res = await UserHttp.seeYouLater();
    // if (res['status']) {
    //   count = res['data']['count'];
    //   if (count > 0) {
    //     laterList.value = res['data']['list'];
    //   }
    // }
    // isLoading.value = false;
    // return res;
    isLoading.value = false;
    return {'status': false, 'msg': 'TODO: 迁移到 Ottohub API'};
  }

  Future toViewDel({int? aid}) async {
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          content: const Text('确定删除该记录？'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                '取消',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                // TODO: 迁移到 Ottohub API
                // var res = await UserHttp.toViewDel(aid: aid);
                // if (res['status']) {
                //   laterList.removeWhere((p0) => p0.aid == aid);
                //   SmartDialog.showToast('删除成功');
                // }
                // Get.back();
                SmartDialog.showToast('TODO: 迁移到 Ottohub API');
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  // 清空稍后再看
  Future toViewClear() async {
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          content: const Text('确定清空所有记录？'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                '取消',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                // TODO: 迁移到 Ottohub API
                // var res = await UserHttp.toViewClear();
                // if (res['status']) {
                //   laterList.clear();
                //   SmartDialog.showToast('清空成功');
                // }
                // Get.back();
                SmartDialog.showToast('TODO: 迁移到 Ottohub API');
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  // 播放全部
  void toViewPlayAll() {
    // TODO: 迁移到 Ottohub API
    // if (laterList.isEmpty) return;
    // Get.toNamed('/video?bvid=${laterList.first.bvid}&cid=${laterList.first.cid}',
    //     arguments: {'videoItem': laterList.first, 'heroTag': Utils.makeHeroTag(laterList.first.aid)});
    SmartDialog.showToast('TODO: 迁移到 Ottohub API');
  }
}
