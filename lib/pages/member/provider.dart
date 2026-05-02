import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:piliotto/models/user/info.dart';
import 'package:piliotto/ottohub/models/member/archive.dart';
import 'package:piliotto/ottohub/models/member/info.dart';
import 'package:piliotto/providers/repository_provider.dart';
import 'package:piliotto/utils/responsive_util.dart';
import 'package:piliotto/utils/route_arguments.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'provider.g.dart';

class MemberState {
  final MemberInfoModel memberInfo;
  final String face;
  final List<VListItemModel> archiveList;
  final bool isLoadingArchive;
  final int attribute;
  final String attributeText;
  final int crossAxisCount;
  final bool isOwner;

  MemberState({
    MemberInfoModel? memberInfo,
    this.face = '',
    List<VListItemModel>? archiveList,
    this.isLoadingArchive = false,
    this.attribute = -1,
    this.attributeText = '关注',
    this.crossAxisCount = 1,
    this.isOwner = false,
  })  : memberInfo = memberInfo ?? MemberInfoModel(),
        archiveList = archiveList ?? [];

  MemberState copyWith({
    MemberInfoModel? memberInfo,
    String? face,
    List<VListItemModel>? archiveList,
    bool? isLoadingArchive,
    int? attribute,
    String? attributeText,
    int? crossAxisCount,
    bool? isOwner,
  }) {
    return MemberState(
      memberInfo: memberInfo ?? this.memberInfo,
      face: face ?? this.face,
      archiveList: archiveList ?? this.archiveList,
      isLoadingArchive: isLoadingArchive ?? this.isLoadingArchive,
      attribute: attribute ?? this.attribute,
      attributeText: attributeText ?? this.attributeText,
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      isOwner: isOwner ?? this.isOwner,
    );
  }
}

@riverpod
class MemberNotifier extends _$MemberNotifier {
  late int _mid;
  late int _ownerMid;
  dynamic _userInfo;
  int _archiveOffset = 0;

  @override
  MemberState build(int mid) {
    _mid = mid;
    _archiveOffset = 0;
    try {
      _userInfo = GStrorage.userInfo.get('userInfoCache');
    } catch (_) {
      _userInfo = null;
    }
    _ownerMid =
        _userInfo != null ? ((_userInfo as UserInfoData).mid ?? -1) : -1;
    final isOwner = _mid == _ownerMid;
    final face = routeArguments['face'] ?? '';
    final crossAxisCount = _calculateCrossAxisCount();

    Future.microtask(() {
      relationSearch();
    });

    return MemberState(
      face: face,
      isOwner: isOwner,
      crossAxisCount: crossAxisCount,
    );
  }

  int _calculateCrossAxisCount() {
    try {
      return ResponsiveUtil.calculateCrossAxisCount(
        baseCount: 1,
        minCount: 1,
        maxCount: 3,
      );
    } catch (e) {
      return 1;
    }
  }

  void updateCrossAxisCount() {
    final count = _calculateCrossAxisCount();
    state = state.copyWith(crossAxisCount: count);
  }

  Future<void> getInfo() async {
    try {
      final userRepo = ref.read(userRepositoryProvider);
      final memberInfo = await userRepo.getUserDetail(uid: _mid);
      state = state.copyWith(
        memberInfo: memberInfo,
        face: memberInfo.face ?? '',
      );
    } catch (e) {
      SmartDialog.showToast('获取用户信息失败: $e');
    }
  }

  Future<void> getMemberArchive(String type) async {
    if (state.isLoadingArchive) return;
    state = state.copyWith(isLoadingArchive: true);

    if (type == 'init') {
      _archiveOffset = 0;
    }

    try {
      final videoRepo = ref.read(videoRepositoryProvider);
      final items = await videoRepo.getUserVideoList(
        uid: _mid,
        offset: _archiveOffset,
        num: 20,
      );

      final newList = type == 'init' ? items : [...state.archiveList, ...items];
      state = state.copyWith(
        archiveList: newList,
        isLoadingArchive: false,
      );
      _archiveOffset += items.length;
    } catch (e) {
      SmartDialog.showToast('获取投稿失败: $e');
      state = state.copyWith(isLoadingArchive: false);
    }
  }

  Future<void> actionRelationMod() async {
    if (_userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    if (state.attribute == 128) {
      blockUser();
      return;
    }
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          content: Text(state.attributeText == '关注' ? '关注UP主?' : '取消关注UP主?'),
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
                  final userRepo = ref.read(userRepositoryProvider);
                  await userRepo.followUser(followingUid: _mid);
                  await relationSearch();
                  SmartDialog.dismiss();
                } catch (e) {
                  if (!ref.mounted) return;
                  SmartDialog.showToast('操作失败，请重试');
                }
              },
              child: const Text('确认'),
            )
          ],
        );
      },
    );
  }

  Future<void> relationSearch() async {
    if (_userInfo == null) return;
    if (_mid == _ownerMid) return;
    try {
      final userRepo = ref.read(userRepositoryProvider);
      final res = await userRepo.getFollowStatus(followingUid: _mid);
      if (!ref.mounted) return;
      if (res.followStatus == 1) {
        state = state.copyWith(attribute: 2, attributeText: '已关注');
      } else {
        state = state.copyWith(attribute: 0, attributeText: '关注');
      }
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(attribute: -1, attributeText: '关注');
    }
  }

  Future<void> blockUser() async {
    if (_userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          content: Text(state.attribute != 128 ? '确定拉黑UP主?' : '从黑名单移除UP主'),
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
                  final userRepo = ref.read(userRepositoryProvider);
                  if (state.attribute != 128) {
                    await userRepo.blockUser(blockedId: _mid);
                  } else {
                    await userRepo.unblockUser(blockedId: _mid);
                  }
                  if (!ref.mounted) return;
                  SmartDialog.dismiss();
                  final newAttribute = state.attribute != 128 ? 128 : 0;
                  state = state.copyWith(
                    attribute: newAttribute,
                    attributeText: newAttribute == 128 ? '已拉黑' : '关注',
                  );
                  await relationSearch();
                } catch (e) {
                  if (!ref.mounted) return;
                  SmartDialog.showToast('操作失败，请重试');
                }
              },
              child: const Text('确认'),
            )
          ],
        );
      },
    );
  }

  void shareUser() {
    SharePlus.instance.share(
      ShareParams(
        text: '${state.memberInfo.name} - https://www.ottohub.cn/u/$_mid',
      ),
    );
  }
}

@riverpod
class MemberArchiveNotifier extends _$MemberArchiveNotifier {
  @override
  List<VListItemModel> build(int mid) {
    return [];
  }

  Future<void> loadMore(int mid) async {
    final videoRepo = ref.read(videoRepositoryProvider);
    final items = await videoRepo.getUserVideoList(
        uid: mid, offset: state.length, num: 20);
    if (!ref.mounted) return;
    state = [...state, ...items];
  }
}
