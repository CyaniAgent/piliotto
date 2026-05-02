import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:piliotto/common/widgets/video_card_h.dart';
import 'package:piliotto/pages/media/provider.dart';

class MediaPage extends ConsumerStatefulWidget {
  const MediaPage({super.key});

  @override
  ConsumerState<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends ConsumerState<MediaPage>
    with AutomaticKeepAliveClientMixin {
  late Future<Map<String, dynamic>> _futureBuilderFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = ref.read(mediaProvider.notifier).queryFavFolder();
  }

  @override
  void dispose() {
    ref.read(mediaProvider.notifier).scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(mediaProvider);
    final notifier = ref.read(mediaProvider.notifier);
    Color primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(toolbarHeight: 30),
      body: SingleChildScrollView(
        controller: notifier.scrollController,
        child: Column(
          children: [
            ListTile(
              leading: null,
              title: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  '媒体库',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            for (var i in notifier.list) ...[
              ListTile(
                onTap: () => i['onTap'](),
                dense: true,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Icon(
                    i['icon'],
                    color: primary,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.only(left: 15, top: 2, bottom: 2),
                minLeadingWidth: 0,
                title: Text(
                  i['title'],
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
            if (state.userLogin) favFolder(context, state, notifier),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom +
                  kBottomNavigationBarHeight,
            )
          ],
        ),
      ),
    );
  }

  Widget favFolder(BuildContext context, MediaState state, MediaNotifier notifier) {
    return Column(
      children: [
        Divider(
          height: 35,
          color: Theme.of(context).dividerColor.withAlpha(26),
        ),
        ListTile(
          onTap: () => context.push('/fav'),
          leading: null,
          dense: true,
          title: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '收藏夹 ',
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.titleMedium!.fontSize,
                        fontWeight: FontWeight.bold),
                  ),
                  if (state.favFolderData?.totalCount != null)
                    TextSpan(
                      text: state.favFolderData!.totalCount.toString(),
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.titleSmall!.fontSize,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          trailing: IconButton(
            onPressed: () {
              setState(() {
                _futureBuilderFuture = notifier.queryFavFolder();
              });
            },
            icon: const Icon(
              Icons.refresh,
              size: 20,
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: MediaQuery.textScalerOf(context).scale(200),
          child: FutureBuilder(
              future: _futureBuilderFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data == null) {
                    return const SizedBox();
                  }
                  Map data = snapshot.data as Map;
                  if (data['status']) {
                    final videoList = state.favFolderData?.videoList ?? [];
                    return ListView.builder(
                      itemCount: videoList.length,
                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: 280,
                          child: VideoCardH(
                            videoItem: videoList[index],
                            showOwner: false,
                          ),
                        );
                      },
                      scrollDirection: Axis.horizontal,
                    );
                  } else {
                    return SizedBox(
                      height: 160,
                      child: Center(child: Text(data['msg'])),
                    );
                  }
                } else {
                  return const SizedBox();
                }
              }),
        ),
      ],
    );
  }
}
