import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/repositories/i_video_repository.dart';
import 'package:piliotto/repositories/i_user_repository.dart';
import 'package:piliotto/pages/video/detail/controller.dart';
import 'package:piliotto/pages/video/detail/reply/index.dart';
import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:piliotto/services/loggeer.dart';
import 'package:share_plus/share_plus.dart';

import 'package:piliotto/ottohub/api/models/video.dart';

class VideoIntroController extends GetxController {
  VideoIntroController({required this.vid});
  final IVideoRepository _videoRepo = Get.find<IVideoRepository>();
  final IUserRepository _userRepo = Get.find<IUserRepository>();
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
      videoDetail.value = await _videoRepo.getVideoDetail(vid);
      final VideoDetailController videoDetailCtr =
          Get.find<VideoDetailController>(tag: heroTag);
      videoDetailCtr.tabs.value = ['简介', '评论'];
      videoDetailCtr.cover.value = videoDetail.value.coverUrl;
      // 获取UP主粉丝数
      queryUserStat();
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

  // 获取弹幕数量
  int get danmakuCount {
    try {
      final VideoDetailController videoDetailCtr =
          Get.find<VideoDetailController>(tag: heroTag);
      return videoDetailCtr.danmakuCount;
    } catch (e) {
      return 0;
    }
  }

  // 获取up主粉丝数
  Future queryUserStat() async {
    if (videoDetail.value.uid == 0) return;
    try {
      final memberInfo =
          await _userRepo.getUserDetail(uid: videoDetail.value.uid);
      follower.value = memberInfo.fans ?? 0;
    } catch (e) {
      getLogger().e('获取用户粉丝数失败: $e');
    }
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
        await _videoRepo.toggleLike(vid: vid);
        hasLike.value = true;
      }
      if (!hasFav.value) {
        await _videoRepo.toggleFavorite(vid: vid);
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
      await _videoRepo.toggleLike(vid: vid);
      if (!hasLike.value) {
        SmartDialog.showToast('点赞成功');
        hasLike.value = true;
      } else if (hasLike.value) {
        SmartDialog.showToast('取消赞');
        hasLike.value = false;
      }
      hasLike.refresh();
      videoDetail.value = await _videoRepo.getVideoDetail(vid);
    } catch (e) {
      SmartDialog.showToast('操作失败：${e.toString()}');
    }
  }

  // （取消）收藏
  Future<void> actionFavVideo({String type = 'choose'}) async {
    if (userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    try {
      await _videoRepo.toggleFavorite(vid: vid);
      if (!hasFav.value) {
        SmartDialog.showToast('收藏成功');
        hasFav.value = true;
      } else {
        SmartDialog.showToast('取消收藏');
        hasFav.value = false;
      }
      hasFav.refresh();
      videoDetail.value = await _videoRepo.getVideoDetail(vid);
    } catch (e) {
      SmartDialog.showToast('操作失败：${e.toString()}');
    }
  }

  // 分享视频
  Future actionShareVideo() async {
    var result = await SharePlus.instance.share(
      ShareParams(
        text:
            '${videoDetail.value.title} UP主: ${videoDetail.value.username} - https://ottohub.cn/video/$vid',
      ),
    );
    return result;
  }

  // 查询关注状态
  Future queryFollowStatus() async {
    if (!userLogin || userInfo == null) {
      followStatus.value = false;
      return;
    }
    try {
      var result =
          await _userRepo.getFollowStatus(followingUid: videoDetail.value.uid);
      followStatus.value = result.followStatus == 1;
    } catch (e) {
      followStatus.value = false;
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
                  await _userRepo.followUser(
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

  // 切换视频（用于相关视频推荐等场景）
  Future switchVideo(
    int vid,
    String? cover,
  ) async {
    // 重新获取视频资源
    final VideoDetailController videoDetailCtr =
        Get.find<VideoDetailController>(tag: heroTag);

    videoDetailCtr
      ..vid = vid
      ..cover.value = cover ?? ''
      ..getVideoDetail();
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
  void oneThreeDialog() {
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
