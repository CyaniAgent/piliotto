import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:piliotto/providers/repository_provider.dart';
import 'package:piliotto/router/app_router.dart';
import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/route_arguments.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:piliotto/services/loggeer.dart';
import 'package:share_plus/share_plus.dart';

import 'package:piliotto/ottohub/api/models/video.dart';

part 'provider.g.dart';

class VideoIntroState {
  final int vid;
  final Video? videoDetail;
  final int follower;
  final bool hasLike;
  final bool hasFav;
  final bool followStatus;
  final bool userLogin;
  final dynamic userInfo;

  const VideoIntroState({
    this.vid = 0,
    this.videoDetail,
    this.follower = 0,
    this.hasLike = false,
    this.hasFav = false,
    this.followStatus = false,
    this.userLogin = false,
    this.userInfo,
  });

  VideoIntroState copyWith({
    int? vid,
    Video? videoDetail,
    int? follower,
    bool? hasLike,
    bool? hasFav,
    bool? followStatus,
    bool? userLogin,
    dynamic userInfo,
  }) {
    return VideoIntroState(
      vid: vid ?? this.vid,
      videoDetail: videoDetail ?? this.videoDetail,
      follower: follower ?? this.follower,
      hasLike: hasLike ?? this.hasLike,
      hasFav: hasFav ?? this.hasFav,
      followStatus: followStatus ?? this.followStatus,
      userLogin: userLogin ?? this.userLogin,
      userInfo: userInfo ?? this.userInfo,
    );
  }
}

@riverpod
class VideoIntroNotifier extends _$VideoIntroNotifier {
  String heroTag = '';
  PersistentBottomSheetController? bottomSheetController;

  @override
  VideoIntroState build(int vid) {
    heroTag = routeArguments['heroTag'] ?? '';
    dynamic userInfo;
    try {
      userInfo = GStrorage.userInfo.get('userInfoCache');
    } catch (_) {
      userInfo = null;
    }

    final initialState = VideoIntroState(
      vid: vid,
      userInfo: userInfo,
      userLogin: userInfo != null,
    );

    Future.microtask(() => queryVideoIntro());

    return initialState;
  }

  Future queryVideoIntro() async {
    try {
      final videoDetail = await ref.read(videoRepositoryProvider).getVideoDetail(state.vid);
      state = state.copyWith(videoDetail: videoDetail);
      queryUserStat();
    } catch (e) {
      SmartDialog.showToast('获取视频详情失败：${e.toString()}');
    }
    if (state.userLogin) {
      queryHasLikeVideo();
      queryHasFavVideo();
      queryFollowStatus();
    }
  }

  Future queryUserStat() async {
    if (state.videoDetail?.uid == null || state.videoDetail!.uid == 0) return;
    try {
      final memberInfo =
          await ref.read(userRepositoryProvider).getUserDetail(uid: state.videoDetail!.uid);
      state = state.copyWith(follower: memberInfo.fans ?? 0);
    } catch (e) {
      getLogger().e('获取用户粉丝数失败: $e');
    }
  }

  Future queryHasLikeVideo() async {
    state = state.copyWith(hasLike: (state.videoDetail?.ifLike ?? 0) == 1);
  }

  Future queryHasFavVideo() async {
    state = state.copyWith(hasFav: (state.videoDetail?.ifFavorite ?? 0) == 1);
  }

  Future actionOneThree() async {
    if (state.userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    if (state.hasLike && state.hasFav) {
      SmartDialog.showToast('UP已经收到了～');
      return;
    }
    try {
      if (!state.hasLike) {
        await ref.read(videoRepositoryProvider).toggleLike(vid: state.vid);
        state = state.copyWith(hasLike: true);
      }
      if (!state.hasFav) {
        await ref.read(videoRepositoryProvider).toggleFavorite(vid: state.vid);
        state = state.copyWith(hasFav: true);
      }
      SmartDialog.showToast('操作成功');
    } catch (e) {
      SmartDialog.showToast('操作失败：${e.toString()}');
    }
  }

  Future actionLikeVideo() async {
    if (state.userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    try {
      await ref.read(videoRepositoryProvider).toggleLike(vid: state.vid);
      if (!state.hasLike) {
        SmartDialog.showToast('点赞成功');
        state = state.copyWith(hasLike: true);
      } else {
        SmartDialog.showToast('取消赞');
        state = state.copyWith(hasLike: false);
      }
      final videoDetail = await ref.read(videoRepositoryProvider).getVideoDetail(state.vid);
      state = state.copyWith(videoDetail: videoDetail);
    } catch (e) {
      SmartDialog.showToast('操作失败：${e.toString()}');
    }
  }

  Future<void> actionFavVideo({String type = 'choose'}) async {
    if (state.userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    try {
      await ref.read(videoRepositoryProvider).toggleFavorite(vid: state.vid);
      if (!state.hasFav) {
        SmartDialog.showToast('收藏成功');
        state = state.copyWith(hasFav: true);
      } else {
        SmartDialog.showToast('取消收藏');
        state = state.copyWith(hasFav: false);
      }
      final videoDetail = await ref.read(videoRepositoryProvider).getVideoDetail(state.vid);
      state = state.copyWith(videoDetail: videoDetail);
    } catch (e) {
      SmartDialog.showToast('操作失败：${e.toString()}');
    }
  }

  Future actionShareVideo() async {
    var result = await SharePlus.instance.share(
      ShareParams(
        text:
            '${state.videoDetail?.title ?? ''} UP主: ${state.videoDetail?.username ?? ''} - https://ottohub.cn/video/${state.vid}',
      ),
    );
    return result;
  }

  Future queryFollowStatus() async {
    if (!state.userLogin || state.userInfo == null) {
      state = state.copyWith(followStatus: false);
      return;
    }
    try {
      var result =
          await ref.read(userRepositoryProvider).getFollowStatus(followingUid: state.videoDetail?.uid ?? 0);
      state = state.copyWith(followStatus: result.followStatus == 1);
    } catch (e) {
      state = state.copyWith(followStatus: false);
    }
  }

  Future actionRelationMod() async {
    feedBack();
    if (state.userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    final bool currentStatus = state.followStatus;
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
                  await ref.read(userRepositoryProvider).followUser(
                      followingUid: state.videoDetail?.uid ?? 0);
                  state = state.copyWith(followStatus: !currentStatus);
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

  Future switchVideo(int vid, String? cover) async {
    state = state.copyWith(vid: vid);
    await queryVideoIntro();
  }

  void nextPlay() {
  }

  void setFollowGroup() {
    SmartDialog.showToast('暂不支持此功能');
  }

  void oneThreeDialog() {
    final BuildContext? ctx = rootNavigatorKey.currentContext;
    if (ctx == null) return;
    showDialog(
      context: ctx,
      builder: (context) {
        return AlertDialog(
          title: const Text('提示'),
          content: const Text('是否一键点赞和收藏'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                '取消',
                style: TextStyle(
                    color: Theme.of(ctx).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                actionOneThree();
                Navigator.of(ctx).pop();
              },
              child: const Text('确认'),
            )
          ],
        );
      },
    );
  }
}
