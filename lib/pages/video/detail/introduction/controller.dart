import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/services/ottohub_service.dart';
import 'package:piliotto/pages/video/detail/controller.dart';
import 'package:piliotto/pages/video/detail/reply/index.dart';
import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../api/models/video.dart';

class VideoIntroController extends GetxController {
  VideoIntroController({required this.vid});
  // 视频vid
  int vid;
  // 视频详情 请求返回
  Rx<Video> videoDetail = Video(
    vid: 0,
    uid: 0,
    title: '',
    time: '',
    likeCount: 0,
    favoriteCount: 0,
    viewCount: 0,
    isDeleted: 0,
    auditStatus: 0,
    coverUrl: '',
    username: '',
    avatarUrl: '',
  ).obs;
  // up主粉丝数
  RxInt follower = 0.obs;
  // 是否点赞
  RxBool hasLike = false.obs;
  // 是否收藏
  RxBool hasFav = false.obs;
  Box userInfoCache = GStrorage.userInfo;
  Box setting = GStrorage.setting;
  bool userLogin = false;
  List addMediaIdsNew = [];
  List delMediaIdsNew = [];
  // 关注状态 默认未关注
  RxBool followStatus = false.obs;

  dynamic userInfo;

  String heroTag = '';
  PersistentBottomSheetController? bottomSheetController;

  @override
  void onInit() {
    super.onInit();
    userInfo = userInfoCache.get('userInfoCache');
    heroTag = Get.arguments?['heroTag'] ?? '';
    userLogin = userInfo != null;
  }

  // 获取视频简介
  Future queryVideoIntro() async {
    try {
      videoDetail.value = await OttohubService.getVideoDetail(vid);
      final VideoDetailController videoDetailCtr =
          Get.find<VideoDetailController>(tag: heroTag);
      videoDetailCtr.tabs.value = ['简介', '评论'];
      videoDetailCtr.cover.value = videoDetail.value.coverUrl;
    } catch (e) {
      SmartDialog.showToast('获取视频详情失败：${e.toString()}');
    }
    if (userLogin) {
      // 获取点赞状态
      queryHasLikeVideo();
      // 获取收藏状态
      queryHasFavVideo();
      //
      queryFollowStatus();
    }
  }

  // 获取up主粉丝数
  Future queryUserStat() async {
    // Ottohub API 暂不支持获取用户粉丝数
    follower.value = 0;
  }

  // 获取点赞状态
  Future queryHasLikeVideo() async {
    // 暂时直接从视频详情中获取点赞状态
    hasLike.value = (videoDetail.value.ifLike ?? 0) == 1;
  }

  // 获取收藏状态
  Future queryHasFavVideo() async {
    // 暂时直接从视频详情中获取收藏状态
    hasFav.value = (videoDetail.value.ifFavorite ?? 0) == 1;
  }

  // 一键三连
  Future actionOneThree() async {
    if (userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    if (hasLike.value && hasFav.value) {
      // 已点赞、收藏
      SmartDialog.showToast('UP已经收到了～');
      return false;
    }
    // 分别执行点赞和收藏操作
    try {
      // 点赞
      if (!hasLike.value) {
        await OttohubService.toggleLike(vid: vid);
        hasLike.value = true;
      }
      // 收藏
      if (!hasFav.value) {
        await OttohubService.toggleFavorite(vid: vid);
        hasFav.value = true;
      }
      SmartDialog.showToast('操作成功');
    } catch (e) {
      SmartDialog.showToast('操作失败：${e.toString()}');
    }
  }

  // （取消）点赞
  Future actionLikeVideo() async {
    if (userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    try {
      await OttohubService.toggleLike(vid: vid);
      if (!hasLike.value) {
        SmartDialog.showToast('点赞成功');
        hasLike.value = true;
      } else if (hasLike.value) {
        SmartDialog.showToast('取消赞');
        hasLike.value = false;
      }
      hasLike.refresh();
      // 重新获取视频详情以更新点赞数
      videoDetail.value = await OttohubService.getVideoDetail(vid);
    } catch (e) {
      SmartDialog.showToast('操作失败：${e.toString()}');
    }
  }

  // （取消）收藏
  Future actionFavVideo({type = 'choose'}) async {
    if (userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    try {
      await OttohubService.toggleFavorite(vid: vid);
      if (!hasFav.value) {
        SmartDialog.showToast('收藏成功');
        hasFav.value = true;
      } else {
        SmartDialog.showToast('取消收藏');
        hasFav.value = false;
      }
      hasFav.refresh();
      // 重新获取视频详情以更新收藏数
      videoDetail.value = await OttohubService.getVideoDetail(vid);
    } catch (e) {
      SmartDialog.showToast('操作失败：${e.toString()}');
    }
  }

  // 分享视频
  Future actionShareVideo() async {
    var result = await Share.share(
            '${videoDetail.value.title} UP主: ${videoDetail.value.username} - https://ottohub.cn/video/$vid')
        .whenComplete(() {});
    return result;
  }

  // 查询关注状态
  Future queryFollowStatus() async {
    try {
      var result = await OttohubService.getFollowStatus(
          followingUid: videoDetail.value.uid);
      followStatus.value = result.followStatus == 1;
    } catch (e) {
      SmartDialog.showToast('获取关注状态失败：${e.toString()}');
    }
  }

  // 关注/取关up
  Future actionRelationMod() async {
    feedBack();
    if (userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    final bool currentStatus = followStatus.value;
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          content: Text(currentStatus == false ? '关注UP主?' : '取消关注UP主?'),
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
                  await OttohubService.followUser(
                      followingUid: videoDetail.value.uid);
                  followStatus.value = !currentStatus;
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text(currentStatus == false ? '关注成功' : '取消关注成功'),
                        duration: const Duration(seconds: 2),
                        showCloseIcon: true,
                      ),
                    );
                  }
                } catch (e) {
                  SmartDialog.showToast('操作失败：${e.toString()}');
                }
                SmartDialog.dismiss();
              },
              child: const Text('确认'),
            )
          ],
        );
      },
    );
  }

  // 修改分P或番剧分集
  Future changeSeasonOrbangu(
    int vid,
    String? cover,
  ) async {
    // 重新获取视频资源
    final VideoDetailController videoDetailCtr =
        Get.find<VideoDetailController>(tag: heroTag);

    videoDetailCtr
      ..vid = vid
      ..cover.value = cover ?? ''
      ..getVideoDetail()
      ..clearSubtitleContent();
    await videoDetailCtr.getSubtitle();
    videoDetailCtr.setSubtitleContent();
    // 重新请求评论
    try {
      /// 未渲染回复组件时可能异常
      final VideoReplyController videoReplyCtr =
          Get.find<VideoReplyController>(tag: heroTag);
      videoReplyCtr.updateVid(vid);
      videoReplyCtr.queryReplyList(type: 'init');
    } catch (_) {}
    this.vid = vid;
    await queryVideoIntro();
  }



  /// 列表循环或者顺序播放时，自动播放下一个
  void nextPlay() {
    // Ottohub API 暂不支持自动播放下一个视频
  }

  // 设置关注分组
  void setFollowGroup() {
    // Ottohub API 暂不支持关注分组
    SmartDialog.showToast('暂不支持此功能');
  }



  //
  oneThreeDialog() {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          title: const Text('提示'),
          content: const Text('是否一键点赞和收藏'),
          actions: [
            TextButton(
              onPressed: () => navigator!.pop(),
              child: Text(
                '取消',
                style: TextStyle(
                    color: Theme.of(Get.context!).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                actionOneThree();
                navigator!.pop();
              },
              child: const Text('确认'),
            )
          ],
        );
      },
    );
  }
}
