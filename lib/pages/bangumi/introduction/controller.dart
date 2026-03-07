import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/http/constants.dart';
import 'package:piliotto/http/search.dart';
import 'package:piliotto/http/video.dart';
import 'package:piliotto/models/bangumi/info.dart';
import 'package:piliotto/models/user/fav_folder.dart';
import 'package:piliotto/pages/video/detail/index.dart';
import 'package:piliotto/pages/video/detail/reply/index.dart';
import 'package:piliotto/plugin/pl_player/models/play_repeat.dart';
import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/id_utils.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:share_plus/share_plus.dart';

import '../../../common/pages_bottom_sheet.dart';
import '../../../models/common/video_episode_type.dart';
import '../../../utils/drawer.dart';

class BangumiIntroController extends GetxController {
  // 视频bvid
  String bvid = Get.parameters['bvid']!;
  var seasonId = Get.parameters['seasonId'] != null
      ? int.parse(Get.parameters['seasonId']!)
      : null;
  var epId = Get.parameters['epId'] != null
      ? int.tryParse(Get.parameters['epId']!)
      : null;

  // 请求状态
  RxBool isLoading = false.obs;

  // 视频详情 请求返回
  Rx<BangumiInfoModel> bangumiDetail = BangumiInfoModel().obs;

  // 请求返回的信息
  String responseMsg = '请求异常';

  // up主粉丝数
  Map userStat = {'follower': '-'};

  // 是否点赞
  RxBool hasLike = false.obs;
  // 是否投币
  RxBool hasCoin = false.obs;
  // 是否收藏
  RxBool hasFav = false.obs;
  Box userInfoCache = GStrorage.userInfo;
  bool userLogin = false;
  Rx<FavFolderData> favFolderData = FavFolderData().obs;
  List addMediaIdsNew = [];
  List delMediaIdsNew = [];
  // 关注状态 默认未关注
  RxMap followStatus = {}.obs;
  int _tempThemeValue = -1;
  var userInfo;
  PersistentBottomSheetController? bottomSheetController;

  @override
  void onInit() {
    super.onInit();
    userInfo = userInfoCache.get('userInfoCache');
    userLogin = userInfo != null;
  }

  // 获取番剧简介&选集
  Future queryBangumiIntro() async {
    if (userLogin) {
      // 获取点赞状态
      queryHasLikeVideo();
      // 获取投币状态
      queryHasCoinVideo();
      // 获取收藏状态
      queryHasFavVideo();
    }
    var result = await SearchHttp.bangumiInfo(seasonId: seasonId, epId: epId);
    if (result['status']) {
      bangumiDetail.value = result['data'];
      epId = bangumiDetail.value.episodes!.first.id;
    }
    return result;
  }

  // 获取点赞状态
  Future queryHasLikeVideo() async {
    var result = await VideoHttp.hasLikeVideo(bvid: bvid);
    // data	num	被点赞标志	0：未点赞  1：已点赞
    hasLike.value = result["data"] == 1 ? true : false;
  }

  // 获取投币状态
  Future queryHasCoinVideo() async {
    var result = await VideoHttp.hasCoinVideo(bvid: bvid);
    hasCoin.value = result["data"]['multiply'] == 0 ? false : true;
  }

  // 获取收藏状态
  Future queryHasFavVideo() async {
    var result = await VideoHttp.hasFavVideo(aid: IdUtils.bv2av(bvid));
    if (result['status']) {
      hasFav.value = result["data"]['favoured'];
    } else {
      hasFav.value = false;
    }
  }

  // （取消）点赞
  Future actionLikeVideo() async {
    var result = await VideoHttp.likeVideo(bvid: bvid, type: !hasLike.value);
    if (result['status']) {
      SmartDialog.showToast(!hasLike.value ? '点赞成功 👍' : '取消赞');
      hasLike.value = !hasLike.value;
      bangumiDetail.value.stat!['likes'] =
          bangumiDetail.value.stat!['likes'] + (!hasLike.value ? 1 : -1);
      hasLike.refresh();
    } else {
      SmartDialog.showToast(result['msg']);
    }
  }

  // 投币
  Future actionCoinVideo() async {
    if (userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    showDialog(
        context: Get.context!,
        builder: (context) {
          return AlertDialog(
            title: const Text('选择投币个数'),
            contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
            content: StatefulBuilder(builder: (context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [1, 2]
                    .map(
                      (e) => RadioListTile(
                        value: e,
                        title: Text('$e枚'),
                        groupValue: _tempThemeValue,
                        onChanged: (value) async {
                          _tempThemeValue = value!;
                          setState(() {});
                          var res = await VideoHttp.coinVideo(
                              bvid: bvid, multiply: _tempThemeValue);
                          if (res['status']) {
                            SmartDialog.showToast('投币成功 👏');
                            hasCoin.value = true;
                            bangumiDetail.value.stat!['coins'] =
                                bangumiDetail.value.stat!['coins'] +
                                    _tempThemeValue;
                          } else {
                            SmartDialog.showToast(res['msg']);
                          }
                          Get.back();
                        },
                      ),
                    )
                    .toList(),
              );
            }),
          );
        });
  }

  // （取消）收藏
  Future actionFavVideo() async {
    try {
      for (var i in favFolderData.value.list!.toList()) {
        if (i.favState == 1) {
          addMediaIdsNew.add(i.id);
        } else {
          delMediaIdsNew.add(i.id);
        }
      }
    } catch (_) {}
    var result = await VideoHttp.favVideo(
        aid: IdUtils.bv2av(bvid),
        addIds: addMediaIdsNew.join(','),
        delIds: delMediaIdsNew.join(','));
    if (result['status']) {
      addMediaIdsNew = [];
      delMediaIdsNew = [];
      // 重新获取收藏状态
      queryHasFavVideo();
      SmartDialog.showToast('✅ 操作成功');
      Get.back();
    }
  }

  // 分享视频
  Future actionShareVideo() async {
    var result = await Share.share('${HttpString.baseUrl}/video/$bvid')
        .whenComplete(() {});
    return result;
  }

  // 选择文件夹
  onChoose(bool checkValue, int index) {
    feedBack();
    List<FavFolderItemData> datalist = favFolderData.value.list!;
    for (var i = 0; i < datalist.length; i++) {
      if (i == index) {
        datalist[i].favState = checkValue == true ? 1 : 0;
        datalist[i].mediaCount = checkValue == true
            ? datalist[i].mediaCount! + 1
            : datalist[i].mediaCount! - 1;
      }
    }
    favFolderData.value.list = datalist;
    favFolderData.refresh();
  }

  // 修改分P或番剧分集
  Future changeSeasonOrbangu(bvid, cid, aid, cover) async {
    // 重新获取视频资源
    VideoDetailController videoDetailCtr =
        Get.find<VideoDetailController>(tag: Get.arguments['heroTag']);
    videoDetailCtr.bvid = bvid;
    videoDetailCtr.cid.value = cid;
    videoDetailCtr.danmakuCid.value = cid;
    videoDetailCtr.oid.value = aid;
    videoDetailCtr.cover.value = cover;
    videoDetailCtr.queryVideoUrl();
    videoDetailCtr.getSubtitle();
    videoDetailCtr.setSubtitleContent();
    // 重新请求评论
    try {
      /// 未渲染回复组件时可能异常
      VideoReplyController videoReplyCtr =
          Get.find<VideoReplyController>(tag: Get.arguments['heroTag']);
      videoReplyCtr.aid = aid;
      videoReplyCtr.queryReplyList(type: 'init');
    } catch (_) {}
  }

  // 追番
  Future bangumiAdd() async {
    var result =
        await VideoHttp.bangumiAdd(seasonId: bangumiDetail.value.seasonId);
    SmartDialog.showToast(result['msg']);
  }

  // 取消追番
  Future bangumiDel() async {
    var result =
        await VideoHttp.bangumiDel(seasonId: bangumiDetail.value.seasonId);
    SmartDialog.showToast(result['msg']);
  }

  Future queryVideoInFolder() async {
    var result = await VideoHttp.videoInFolder(
        mid: userInfo.mid, rid: IdUtils.bv2av(bvid));
    if (result['status']) {
      favFolderData.value = result['data'];
    }
    return result;
  }

  /// 列表循环或者顺序播放时，自动播放下一个
  void nextPlay() {
    late List episodes;
    if (bangumiDetail.value.episodes != null) {
      episodes = bangumiDetail.value.episodes!;
    }
    VideoDetailController videoDetailCtr =
        Get.find<VideoDetailController>(tag: Get.arguments['heroTag']);
    int currentIndex =
        episodes.indexWhere((e) => e.cid == videoDetailCtr.cid.value);
    int nextIndex = currentIndex + 1;
    PlayRepeat platRepeat = videoDetailCtr.plPlayerController.playRepeat;
    // 列表循环
    if (platRepeat == PlayRepeat.listCycle) {
      if (nextIndex == episodes.length - 1) {
        nextIndex = 0;
      }
    }
    if (nextIndex <= episodes.length - 1 &&
        platRepeat == PlayRepeat.listOrder) {}

    int cid = episodes[nextIndex].cid!;
    String bvid = episodes[nextIndex].bvid!;
    int aid = episodes[nextIndex].aid!;
    String cover = episodes[nextIndex].cover!;
    changeSeasonOrbangu(bvid, cid, aid, cover);
  }

  // 播放器底栏 选集 回调
  void showEposideHandler() {
    late List episodes = bangumiDetail.value.episodes!;
    VideoEpidoesType dataType = VideoEpidoesType.bangumiEpisode;
    if (episodes.isEmpty) {
      return;
    }
    VideoDetailController videoDetailCtr =
        Get.find<VideoDetailController>(tag: Get.arguments['heroTag']);
    DrawerUtils.showRightDialog(
      child: EpisodeBottomSheet(
        episodes: episodes,
        currentCid: videoDetailCtr.cid.value,
        dataType: dataType,
        context: Get.context!,
        sheetHeight: Get.size.height,
        isFullScreen: true,
        changeFucCall: (item, index) {
          changeSeasonOrbangu(item.bvid, item.cid, item.aid, item.cover);
          SmartDialog.dismiss();
        },
      ).buildShowContent(Get.context!),
    );
  }

  hiddenEpisodeBottomSheet() {
    bottomSheetController?.close();
  }
}
