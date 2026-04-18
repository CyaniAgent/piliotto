import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/api/services/old_api_service.dart';
import 'package:piliotto/http/video.dart';
import 'package:piliotto/models/member/archive.dart';
import 'package:piliotto/models/member/info.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:share_plus/share_plus.dart';

class MemberController extends GetxController {
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
    relationSearch();
  }

  Future<Map<String, dynamic>> getInfo() async {
    var res = await OldApiService.getUserDetail(uid: mid);
    if (res['status'] == 'success') {
      memberInfo.value = MemberInfoModel(
        mid: int.tryParse(res['uid'].toString()) ?? 0,
        name: res['username']?.toString() ?? '',
        sign: res['intro']?.toString() ?? '',
        face: res['avatar_url']?.toString() ?? '',
        cover: res['cover_url']?.toString() ?? '',
        sex: res['sex']?.toString() ?? '',
        fans: int.tryParse(res['fans_count'].toString()) ?? 0,
        attention: int.tryParse(res['followings_count'].toString()) ?? 0,
        archiveCount: int.tryParse(res['video_num'].toString()) ?? 0,
        articleCount: int.tryParse(res['blog_num'].toString()) ?? 0,
      );
      face.value = res['avatar_url']?.toString() ?? '';
    }
    return res;
  }

  Future<void> getMemberArchive(String type) async {
    if (isLoadingArchive.value) return;
    isLoadingArchive.value = true;
    if (type == 'init') {
      _archiveOffset = 0;
      archiveList.clear();
    }
    try {
      final res = await OldApiService.getUserVideoList(
        uid: mid,
        offset: _archiveOffset,
        num: 20,
      );
      if (res['status'] == 'success') {
        final List<dynamic> videoList = res['video_list'] as List;
        final items = videoList.map((v) => VListItemModel.fromJson(v)).toList();
        if (type == 'init') {
          archiveList.value = items;
        } else {
          archiveList.addAll(items);
        }
        _archiveOffset += items.length;
      }
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
                  await OldApiService.followUser(followingUid: mid);
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
      var res = await OldApiService.getFollowStatus(followingUid: mid);
      if (res['status'] == 'success') {
        final followStatus = res['data']['follow_status'];
        switch (followStatus) {
          case 1:
            attribute.value = 0;
            attributeText.value = '关注';
            break;
          case 2:
            attribute.value = 2;
            attributeText.value = '已关注';
            break;
          case 3:
            attribute.value = 1;
            attributeText.value = '回关';
            break;
          case 4:
            attribute.value = 6;
            attributeText.value = '已互关';
            break;
          default:
            attribute.value = -1;
            attributeText.value = '关注';
        }
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
                var res = await VideoHttp.relationMod(
                  mid: mid,
                  act: attribute.value != 128 ? 5 : 6,
                  reSrc: 11,
                );
                SmartDialog.dismiss();
                if (res['status']) {
                  attribute.value = attribute.value != 128 ? 128 : 0;
                  attributeText.value = attribute.value == 128 ? '已拉黑' : '关注';
                  memberInfo.value.isFollowed = false;
                  relationSearch();
                  memberInfo.update((val) {});
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
