import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/services/ottohub_service.dart';
import '../../../../api/models/video.dart';

class RelatedController extends GetxController {
  // 视频vid
  int vid = int.parse(Get.parameters['vid'] ?? '0');
  // 推荐视频列表
  RxList relatedVideoList = <Video>[].obs;

  OverlayEntry? popupDialog;

  Future<dynamic> queryRelatedVideo() async {
    try {
      final VideoListResponse response =
          await OttohubService.getRelatedVideos(vid);
      relatedVideoList.value = response.videoList;
      return {'status': true, 'data': response.videoList};
    } catch (e) {
      return {'status': false, 'message': e.toString()};
    }
  }
}
