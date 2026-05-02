import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:piliotto/common/skeleton/video_card_h.dart';
import 'package:piliotto/common/widgets/no_data.dart';
import 'package:piliotto/common/widgets/video_card_h.dart';
import 'package:piliotto/pages/member_archive/provider.dart';
import 'package:piliotto/utils/route_arguments.dart';

class MemberArchivePage extends ConsumerStatefulWidget {
  const MemberArchivePage({super.key});

  @override
  ConsumerState<MemberArchivePage> createState() => _MemberArchivePageState();
}

class _MemberArchivePageState extends ConsumerState<MemberArchivePage> {
  late Future _futureBuilderFuture;
  late int mid;

  @override
  void initState() {
    super.initState();
    mid = int.parse(routeArguments.queryParameters['mid']!);
    _futureBuilderFuture =
        ref.read(memberArchiveProvider.notifier).getMemberArchive('init');
    final scrollController = ref.read(memberArchiveProvider.notifier).scrollController;
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          EasyThrottle.throttle(
              'member_archives', const Duration(milliseconds: 500), () {
            ref.read(memberArchiveProvider.notifier).onLoad();
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memberArchiveProvider);
    final notifier = ref.read(memberArchiveProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: false,
        title: Text(
            '他的投稿 - ${state.currentOrder['label']}',
            style: Theme.of(context).textTheme.titleMedium),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              notifier.setCurrentOrder(value);
            },
            itemBuilder: (BuildContext context) =>
                state.orderList.map(
              (e) {
                return PopupMenuItem(
                  value: e,
                  child: Text(e['label']!),
                );
              },
            ).toList(),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: CustomScrollView(
        controller: notifier.scrollController,
        slivers: [
          FutureBuilder(
            future: _futureBuilderFuture,
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final list = state.archivesList;
                if (list.isNotEmpty) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, index) {
                        return VideoCardH(
                          videoItem: list[index],
                          showOwner: false,
                          showPubdate: true,
                          showCharge: true,
                        );
                      },
                      childCount: list.length,
                    ),
                  );
                } else if (state.isLoading) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      return const VideoCardHSkeleton();
                    }, childCount: 10),
                  );
                } else {
                  return const SliverToBoxAdapter(child: NoData());
                }
              } else {
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return const VideoCardHSkeleton();
                  }, childCount: 10),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
