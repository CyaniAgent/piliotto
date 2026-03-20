import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// TODO: 迁移到 Ottohub API（如果有专栏/图文功能）
// import 'package:piliotto/http/read.dart';
import 'package:piliotto/models/read/read.dart';
import 'package:piliotto/plugin/pl_gallery/hero_dialog_route.dart';
import 'package:piliotto/plugin/pl_gallery/interactiveviewer_gallery.dart';

class ReadPageController extends GetxController {
  late String url;
  RxString title = ''.obs;
  late String id;
  late String articleType;
  Rx<ReadDataModel> cvData = ReadDataModel().obs;
  final ScrollController scrollController = ScrollController();
  late StreamController<bool> appbarStream = StreamController<bool>.broadcast();

  @override
  void onInit() {
    super.onInit();
    title.value = Get.parameters['title'] ?? '';
    id = Get.parameters['id']!;
    articleType = Get.parameters['articleType'] ?? 'read';
    url = 'https://www.bilibili.com/read/cv$id';
    scrollController.addListener(_scrollListener);
    fetchViewInfo();
  }

  Future fetchCvData() async {
    // TODO: 迁移到 Ottohub API（如果有专栏/图文功能）
    // var res = await ReadHttp.parseArticleCv(id: id);
    // if (res['status']) {
    //   cvData.value = res['data'];
    //   title.value = cvData.value.readInfo!.title!;
    // }
    // return res;
    return {'status': false, 'msg': 'TODO: 迁移到 Ottohub API'};
  }

  void _scrollListener() {
    final double offset = scrollController.position.pixels;
    if (offset > 100) {
      appbarStream.add(true);
    } else {
      appbarStream.add(false);
    }
  }

  void onPreviewImg(picList, initIndex, context) {
    Navigator.of(context).push(
      HeroDialogRoute<void>(
        builder: (BuildContext context) => InteractiveviewerGallery(
          sources: picList,
          initIndex: initIndex,
          onPageChanged: (int pageIndex) {},
        ),
      ),
    );
  }

  void fetchViewInfo() {
    // TODO: 迁移到 Ottohub API（如果有专栏/图文功能）
    // ReadHttp.getViewInfo(id: id);
  }

  // 跳转webview
  void onJumpWebview() {
    Get.toNamed('/webview', parameters: {
      'url': url,
      'type': 'webview',
      'pageTitle': title.value,
    });
  }

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    appbarStream.close();
    super.onClose();
  }
}
