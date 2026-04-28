import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/ottohub/api/models/following.dart';
import 'package:piliotto/repositories/i_user_repository.dart';
import 'package:piliotto/services/loggeer.dart';
import 'package:piliotto/utils/storage.dart';

final _logger = getLogger();

class FollowController extends GetxController {
  final IUserRepository _userRepo = Get.find<IUserRepository>();
  Box userInfoCache = GStrorage.userInfo;
  int offset = 0;
  final int num = 12; // API 限制每次最多获取 12 条
  RxList<FollowingUser> followList = <FollowingUser>[].obs;
  late int mid;
  late String name;
  dynamic userInfo;
  RxString loadingText = '加载中...'.obs;
  RxBool isLoading = false.obs;
  RxBool hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    userInfo = userInfoCache.get('userInfoCache');
    mid = Get.parameters['mid'] != null
        ? int.parse(Get.parameters['mid']!)
        : userInfo?.mid ?? 0;
    name = Get.parameters['name'] != null
        ? _safeDecodeUri(Get.parameters['name']!)
        : userInfo?.uname ?? '';
  }

  String _safeDecodeUri(String value) {
    try {
      return Uri.decodeComponent(value);
    } catch (e) {
      return value;
    }
  }

  Future<void> queryFollowings({bool isLoadMore = false}) async {
    if (isLoading.value) return;

    if (!isLoadMore) {
      offset = 0;
      loadingText.value = '加载中...';
    } else {
      if (!hasMore.value) return;
    }

    isLoading.value = true;

    try {
      final response = await _userRepo.getFollowingList(
        uid: mid,
        offset: offset,
        num: num,
      );

      final List<FollowingUser> users = response.userList;

      if (isLoadMore) {
        followList.addAll(users);
      } else {
        followList.value = users;
      }

      hasMore.value = users.length >= num;
      if (!hasMore.value) {
        loadingText.value = '没有更多了';
      }
      offset += users.length;
    } catch (e) {
      _logger.e('获取关注列表失败: $e');
      SmartDialog.showToast('获取关注列表失败');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onLoad() async {
    await queryFollowings(isLoadMore: true);
  }

  Future<void> onRefresh() async {
    await queryFollowings();
  }
}
