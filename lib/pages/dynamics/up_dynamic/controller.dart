import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:piliotto/api/services/old_api_service.dart';
import 'package:piliotto/models/dynamics/result.dart';
import 'package:piliotto/models/dynamics/up.dart';

class UpDynamicsController extends GetxController {
  UpDynamicsController(this.upInfo);
  UpItem upInfo;
  RxList<DynamicItemModel> dynamicsList = <DynamicItemModel>[].obs;
  RxBool isLoadingDynamic = false.obs;
  String? offset = '';
  int page = 1;

  Future queryFollowDynamic({type = 'init'}) async {
    if (type == 'init') {
      dynamicsList.clear();
    }
    if (type == 'onLoad' && page == 1) {
      return;
    }
    isLoadingDynamic.value = true;
    try {
      final res = await OldApiService.getUserBlogList(
        uid: upInfo.mid ?? 0,
        offset: type == 'init' ? 0 : (int.tryParse(offset ?? '0') ?? 0),
        num: 10,
      );
      isLoadingDynamic.value = false;
      if (res['status'] == 'success') {
        final List<dynamic> blogList = res['blog_list'] as List;
        final items = blogList.map((blog) {
          return DynamicItemModel.fromJson(blog);
        }).toList();

        if (type == 'onLoad' && items.isEmpty) {
          SmartDialog.showToast('没有更多了');
          return;
        }
        if (type == 'init') {
          dynamicsList.value = items;
        } else {
          dynamicsList.addAll(items);
        }
        offset = ((int.tryParse(offset ?? '0') ?? 0) + items.length).toString();
        page++;
      } else {
        SmartDialog.showToast(res['message'] ?? '获取动态失败');
      }
    } catch (e) {
      isLoadingDynamic.value = false;
      SmartDialog.showToast('获取动态失败: $e');
    }
  }
}
