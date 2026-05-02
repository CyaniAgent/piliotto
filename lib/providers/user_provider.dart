import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:piliotto/models/user/info.dart';
import 'package:piliotto/utils/storage.dart';

part 'user_provider.g.dart';

@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  UserInfoData? build() {
    return _loadUserFromStorage();
  }

  UserInfoData? _loadUserFromStorage() {
    try {
      final userInfo = GStrorage.userInfo.get('userInfo');
      if (userInfo != null && userInfo is UserInfoData) {
        return userInfo;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  void setUser(UserInfoData user) {
    state = user;
    GStrorage.userInfo.put('userInfo', user);
  }

  void logout() {
    state = null;
    GStrorage.userInfo.delete('userInfo');
  }

  bool get isLogin => state?.isLogin ?? false;

  int? get mid => state?.mid;

  String? get username => state?.uname;

  String? get face => state?.face;
}

@riverpod
bool isUserLoggedIn(Ref ref) {
  final user = ref.watch(userProvider);
  return user?.isLogin ?? false;
}

@riverpod
int? currentUserId(Ref ref) {
  final user = ref.watch(userProvider);
  return user?.mid;
}
