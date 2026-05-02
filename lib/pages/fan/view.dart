import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:piliotto/common/widgets/user_list_page.dart';
import 'package:piliotto/pages/fan/provider.dart';

class FansPage extends ConsumerWidget {
  const FansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fanProvider);
    final notifier = ref.read(fanProvider.notifier);

    return UserListPage(
      title: '${state.name}的粉丝',
      onRefresh: notifier.onRefresh,
      onLoad: notifier.onLoad,
      onInit: notifier.onRefresh,
      userList: state.fanList,
      isLoading: state.isLoading,
      hasMore: state.hasMore,
      loadingText: state.loadingText,
    );
  }
}
