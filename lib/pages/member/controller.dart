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
  // 投稿列表
  RxList<VListItemModel>? archiveList = <VListItemModel>[].obs;
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

  // 获取用户信息
  Future<Map<String, dynamic>> getInfo() async {
    var res = await OldApiService.getUserDetail(uid: mid);
    if (res['status'] == 'success') {
      final data = res['data'];
      memberInfo.value = MemberInfoModel(
        mid: data['uid'],
        name: data['username'],
        sign: data['intro'],
        face: data['avatar_url'],
        cover: data['cover_url'],
        sex: data['sex'],
        fans: data['fans_count'],
        attention: data['followings_count'],
        archiveCount: data['video_num'],
        articleCount: data['blog_num'],
      );
      face.value = data['avatar_url'];
    }
    return res;
  }

  // 获取用户状态
  Future<Map<String, dynamic>> getMemberStat() async {
    // Ottohub API 暂不支持此接口
    userStat = {};
    return {'status': true, 'data': {}};
  }

  // 获取用户播放数 获赞数
  Future<Map<String, dynamic>> getMemberView() async {
    // Ottohub API 暂不支持此接口
    return {'status': true, 'data': {}};
  }

  // 关注/取关up
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

  // 关系查询
  Future relationSearch() async {
    if (userInfo == null) return;
    if (mid == ownerMid) return;
    try {
      var res = await OldApiService.getFollowStatus(followingUid: mid);
      if (res['status'] == 'success') {
        final followStatus = res['data']['follow_status'];
        switch (followStatus) {
          case 1:
            attribute.value = 0; // 互相未关注
            attributeText.value = '关注';
            break;
          case 2:
            attribute.value = 2; // 我关注对方
            attributeText.value = '已关注';
            break;
          case 3:
            attribute.value = 1; // 对方关注我
            attributeText.value = '回关';
            break;
          case 4:
            attribute.value = 6; // 互相关注
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

  // 拉黑用户
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
        text: '${memberInfo.value.name} - https://space.bilibili.com/$mid',
      ),
    );
  }

  // 跳转查看动态
  void pushDynamicsPage() => Get.toNamed('/memberDynamics?mid=$mid');

  // 跳转查看投稿
  void pushArchivesPage() => Get.toNamed('/memberArchive?mid=$mid');

  void pushfavPage() => Get.toNamed('/fav?mid=$mid');
  // 跳转图文专栏
  void pushArticlePage() => Get.toNamed('/memberArticle?mid=$mid');
}
