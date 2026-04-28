import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/repositories/i_user_repository.dart';
import 'package:piliotto/repositories/i_video_repository.dart';
import 'package:piliotto/ottohub/models/member/archive.dart';
import 'package:piliotto/ottohub/models/member/info.dart';
import 'package:piliotto/utils/responsive_util.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:share_plus/share_plus.dart';

class MemberController extends GetxController {
  final IUserRepository _userRepo = Get.find<IUserRepository>();
  final IVideoRepository _videoRepo = Get.find<IVideoRepository>();
  late int mid;
  Rx<MemberInfoModel> memberInfo = MemberInfoModel().obs;
  late Map userStat;
  RxString face = ''.obs;
  String? heroTag;
  Box userInfoCache = GStrorage.userInfo;
  late int ownerMid;
  RxList<VListItemModel> archiveList = <VListItemModel>[].obs;
  RxBool isLoadingArchive = false.obs;
  int _archiveOffset = 0;
  dynamic userInfo;
  RxInt attribute = (-1).obs;
  RxString attributeText = '关注'.obs;
  RxInt crossAxisCount = 1.obs;

  RxBool isOwner = false.obs;

  @override
  void onInit() {
    super.onInit();
    mid = int.parse(Get.parameters['mid']!);
    userInfo = userInfoCache.get('userInfoCache');
    ownerMid = userInfo != null ? userInfo.mid : -1;
    isOwner.value = mid == ownerMid;
    face.value = Get.arguments['face'] ?? '';
    heroTag = Get.arguments['heroTag'] ?? '';
    updateCrossAxisCount();
    relationSearch();
  }

  void updateCrossAxisCount() {
    try {
      int baseCount = ResponsiveUtil.calculateCrossAxisCount(
        baseCount: 1,
        minCount: 1,
        maxCount: 3,
      );
      crossAxisCount.value = baseCount;
    } catch (e) {
      crossAxisCount.value = 1;
    }
  }

  Future<Map<String, dynamic>> getInfo() async {
    try {
      memberInfo.value = await _userRepo.getUserDetail(uid: mid);
      face.value = memberInfo.value.face ?? '';
      return {'status': 'success'};
    } catch (e) {
      return {'status': 'fail', 'message': e.toString()};
    }
  }

  Future<void> getMemberArchive(String type) async {
    if (isLoadingArchive.value) return;
    isLoadingArchive.value = true;
    if (type == 'init') {
      _archiveOffset = 0;
      archiveList.clear();
    }
    try {
      final items = await _videoRepo.getUserVideoList(
          uid: mid, offset: _archiveOffset, num: 20);
      if (type == 'init') {
        archiveList.value = items;
      } else {
        archiveList.addAll(items);
      }
      _archiveOffset += items.length;
    } catch (e) {
      SmartDialog.showToast('获取投稿失败: $e');
    }
    isLoadingArchive.value = false;
  }

  Future<Map<String, dynamic>> getMemberStat() async {
    userStat = {};
    return {'status': true, 'data': {}};
  }

  Future<Map<String, dynamic>> getMemberView() async {
    return {'status': true, 'data': {}};
  }

  Future actionRelationMod() async {
    if (userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    if (attribute.value == 128) {
      blockUser();
      return;
    }
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          content: Text(attributeText.value == '关注' ? '关注UP主?' : '取消关注UP主?'),
          actions: [
            TextButton(
              onPressed: () => SmartDialog.dismiss(),
              child: Text(
                '点错了',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _userRepo.followUser(followingUid: mid);
                  await relationSearch();
                  SmartDialog.dismiss();
                } catch (e) {
                  SmartDialog.showToast('操作失败，请重试');
                }
              },
              child: const Text('确认'),
            )
          ],
        );
      },
    );
  }

  Future relationSearch() async {
    if (userInfo == null) return;
    if (mid == ownerMid) return;
    try {
      var res = await _userRepo.getFollowStatus(followingUid: mid);
      if (res.followStatus == 1) {
        attribute.value = 2;
        attributeText.value = '已关注';
      } else {
        attribute.value = 0;
        attributeText.value = '关注';
      }
    } catch (e) {
      attribute.value = -1;
      attributeText.value = '关注';
    }
  }

  Future blockUser() async {
    if (userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          content: Text(attribute.value != 128 ? '确定拉黑UP主?' : '从黑名单移除UP主'),
          actions: [
            TextButton(
              onPressed: () => SmartDialog.dismiss(),
              child: Text(
                '点错了',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  if (attribute.value != 128) {
                    await _userRepo.blockUser(blockedId: mid);
                  } else {
                    await _userRepo.unblockUser(blockedId: mid);
                  }
                  SmartDialog.dismiss();
                  attribute.value = attribute.value != 128 ? 128 : 0;
                  attributeText.value = attribute.value == 128 ? '已拉黑' : '关注';
                  memberInfo.value.isFollowed = false;
                  relationSearch();
                  memberInfo.update((val) {});
                } catch (e) {
                  SmartDialog.showToast('操作失败，请重试');
                }
              },
              child: const Text('确认'),
            )
          ],
        );
      },
    );
  }

  void shareUser() {
    SharePlus.instance.share(
      ShareParams(
        text: '${memberInfo.value.name} - https://www.ottohub.cn/u/$mid',
      ),
    );
  }
}
