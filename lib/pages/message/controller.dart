import 'package:get/get.dart';
import 'package:piliotto/api/models/message.dart';
import 'package:piliotto/repositories/i_message_repository.dart';
import 'package:piliotto/utils/storage.dart';

class MessageController extends GetxController {
  final IMessageRepository _messageRepo = Get.find<IMessageRepository>();
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
      final myUid = GStrorage.userInfo.get('userInfoCache')?.mid ?? 0;

      final allFriends = await _messageRepo.getMergedFriendList(
        uid: myUid,
        offset: _offset,
        pageSize: _pageSize,
      );

      if (allFriends.length < _pageSize) {
        _hasMore = false;
      }

      friendList.addAll(allFriends);
      _offset += allFriends.length;
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
