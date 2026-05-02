import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:piliotto/common/widgets/user_list_page.dart';
import 'package:piliotto/pages/follow/provider.dart';

class FollowPage extends ConsumerWidget {
  const FollowPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(followProvider);
    final notifier = ref.read(followProvider.notifier);

    return UserListPage(
      title: '${state.name}的关注',
      onRefresh: notifier.onRefresh,
      onLoad: notifier.onLoad,
      onInit: notifier.onRefresh,
      userList: state.followList,
      isLoading: state.isLoading,
      hasMore: state.hasMore,
      loadingText: state.loadingText,
    );
  }
}
