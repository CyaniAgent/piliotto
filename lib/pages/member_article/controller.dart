import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/models/member/article.dart';

class MemberArticleController extends GetxController {
  final ScrollController scrollController = ScrollController();
  late int mid;
  int pn = 1;
  String? offset;
  bool hasMore = true;
  String? wWebid;
  RxBool isLoading = false.obs;
  RxList<MemberArticleItemModel> articleList = <MemberArticleItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    mid = int.parse(Get.parameters['mid']!);
  }

  // TODO: 迁移到 Ottohub API（如果有专栏功能）
  Future getWWebid() async {
    wWebid = '-1';
  }

  Future getMemberArticle(type) async {
    return {'status': false, 'msg': 'TODO: 迁移到 Ottohub API'};
  }
}
