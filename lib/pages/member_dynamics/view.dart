import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:piliotto/pages/member_dynamics/index.dart';
import 'package:piliotto/utils/responsive_util.dart';
import 'package:piliotto/utils/route_arguments.dart';

import '../dynamics/widgets/dynamic_panel.dart';

class MemberDynamicsPage extends ConsumerStatefulWidget {
  const MemberDynamicsPage({super.key});

  @override
  ConsumerState<MemberDynamicsPage> createState() => _MemberDynamicsPageState();
}

class _MemberDynamicsPageState extends ConsumerState<MemberDynamicsPage> {
  Future? _futureBuilderFuture;
  late ScrollController scrollController;
  late int mid;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    mid = int.parse(routeArguments.queryParameters['mid']!);
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _futureBuilderFuture = ref
          .read(memberDynamicsProvider(mid).notifier)
          .getMemberDynamic('onRefresh');
    }
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      EasyThrottle.throttle(
          'member_dynamics', const Duration(milliseconds: 1000), () {
        ref.read(memberDynamicsProvider(mid).notifier).onLoad();
      });
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = ResponsiveUtil.isLg || ResponsiveUtil.isXl;
    final screenWidth = MediaQuery.of(context).size.width;
    const maxContentWidth = 600.0;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: false,
        title: Text('他的动态', style: Theme.of(context).textTheme.titleMedium),
      ),
      body: FutureBuilder(
        future: _futureBuilderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final state = ref.watch(memberDynamicsProvider(mid));
            final list = state.dynamicsList;

            if (list.isNotEmpty) {
              return ListView.builder(
                controller: scrollController,
                padding:
                    _buildPadding(isWideScreen, screenWidth, maxContentWidth),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    width: isWideScreen ? maxContentWidth : null,
                    child: DynamicPanel(
                      item: list[index],
                      onTap: () => context.push('/dynamicDetail', extra: {
                        'item': list[index],
                        'floor': 1,
                      }),
                      onCommentTap: () =>
                          context.push('/dynamicDetail', extra: {
                        'item': list[index],
                        'floor': 1,
                        'action': 'comment',
                      }),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text('暂无动态'));
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  EdgeInsets _buildPadding(
      bool isWideScreen, double screenWidth, double maxWidth) {
    if (isWideScreen) {
      final horizontalPadding = (screenWidth - maxWidth) / 2;
      return EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 80,
      );
    }
    return const EdgeInsets.only(
      left: 12,
      right: 12,
      top: 8,
      bottom: 80,
    );
  }
}
