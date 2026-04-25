import 'package:get/get.dart';
import 'package:piliotto/api/models/message.dart';
import 'package:piliotto/api/services/message_service.dart';

class MessageController extends GetxController {
  RxList<Friend> friendList = <Friend>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  Rxn<Friend> selectedFriend = Rxn<Friend>();

  int _offset = 0;
  final int _pageSize = 20;
  bool _hasMore = true;

  @override
  void onInit() {
    super.onInit();
    _checkInitialFriend();
    loadFriendList();
  }

  void _checkInitialFriend() {
    final parameters = Get.parameters;
    final mid = parameters['mid'];
    final name = parameters['name'];
    final face = parameters['face'];

    if (mid != null && name != null) {
      selectedFriend.value = Friend(
        uid: int.tryParse(mid) ?? 0,
        username: name,
        avatarUrl: face,
      );
    }
  }

  Future loadFriendList({bool refresh = false}) async {
    if (isLoading.value) return;

    if (refresh) {
      _offset = 0;
      _hasMore = true;
      friendList.clear();
    }

    if (!_hasMore) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final List<Friend> newFriends = await MessageService.getFriendList(
        offset: _offset,
        num: _pageSize,
      );

      if (newFriends.length < _pageSize) {
        _hasMore = false;
      }

      friendList.addAll(newFriends);
      _offset += newFriends.length;
    } catch (e) {
      errorMessage.value = '加载失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void selectFriend(Friend friend) {
    selectedFriend.value = friend;
  }

  void clearSelection() {
    selectedFriend.value = null;
  }
}
