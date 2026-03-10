import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/pages/member/index.dart';
import 'package:piliotto/utils/utils.dart';

import 'widgets/profile.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({super.key});

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage>
    with SingleTickerProviderStateMixin {
  late String heroTag;
  late MemberController _memberController;
  late Future _futureBuilderFuture;
  final ScrollController _extendNestCtr = ScrollController();
  final StreamController<bool> appbarStream =
      StreamController<bool>.broadcast();
  late int mid;

  @override
  void initState() {
    super.initState();
    mid = int.parse(Get.parameters['mid']!);
    heroTag = Get.arguments['heroTag'] ?? Utils.makeHeroTag(mid);
    _memberController = Get.put(MemberController(), tag: heroTag);
    _futureBuilderFuture = _memberController.getInfo();
    _extendNestCtr.addListener(
      () {
        final double offset = _extendNestCtr.position.pixels;
        if (offset > 100) {
          appbarStream.add(true);
        } else {
          appbarStream.add(false);
        }
      },
    );
  }

  @override
  void dispose() {
    _extendNestCtr.removeListener(() {});
    appbarStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 16,
        title: StreamBuilder(
          stream: appbarStream.stream.distinct(),
          initialData: false,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return AnimatedOpacity(
              opacity: snapshot.data ? 1 : 0,
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 500),
              child: Row(
                children: [
                  Row(
                    children: [
                      Obx(
                        () => NetworkImgLayer(
                          width: 35,
                          height: 35,
                          type: 'avatar',
                          src: _memberController.face.value,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Obx(
                        () => Text(
                          _memberController.memberInfo.value.name ?? '',
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.onSurface,
                              fontSize: 14),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(
                '/memberSearch?mid=$mid&uname=${_memberController.memberInfo.value.name!}'),
            icon: const Icon(Icons.search_outlined),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              if (_memberController.ownerMid != _memberController.mid) ...[
                PopupMenuItem(
                  onTap: () => _memberController.blockUser(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.block, size: 19),
                      const SizedBox(width: 10),
                      Text(_memberController.attribute.value != 128
                          ? '加入黑名单'
                          : '移除黑名单'),
                    ],
                  ),
                )
              ],
              PopupMenuItem(
                onTap: () => _memberController.shareUser(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.share_outlined, size: 19),
                    const SizedBox(width: 10),
                    Text(_memberController.ownerMid != _memberController.mid
                        ? '分享UP主'
                        : '分享我的主页'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        controller: _extendNestCtr,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 20,
        ),
        children: [
          profileWidget(),

          /// 动态链接
          Obx(
            () => buildSettingItem(
              Icons.dynamic_feed_outlined,
              '${_memberController.isOwner.value ? '我' : 'Ta'}的动态',
              '',
              _memberController.pushDynamicsPage,
            ),
          ),

          /// 视频
          Obx(
            () => buildSettingItem(
              Icons.play_circle_outlined,
              '${_memberController.isOwner.value ? '我' : 'Ta'}的投稿',
              '',
              _memberController.pushArchivesPage,
            ),
          ),

          /// 他的收藏夹
          Obx(
            () => buildSettingItem(
              Icons.favorite_border_outlined,
              '${_memberController.isOwner.value ? '我' : 'Ta'}的收藏',
              '',
              _memberController.pushfavPage,
            ),
          ),

          /// 专栏
          Obx(
            () => buildSettingItem(
              Icons.article_outlined,
              '${_memberController.isOwner.value ? '我' : 'Ta'}的专栏',
              '',
              _memberController.pushArticlePage,
            ),
          ),


        ],
      ),
    );
  }

  Widget buildSettingItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        size: 24,
        color: colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_outlined, size: 19),
    );
  }

  Widget profileWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, bottom: 20, top: 10),
      child: FutureBuilder(
        future: _futureBuilderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Map? data = snapshot.data;
            if (data != null && data['status'] == 'success') {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfilePanel(ctr: _memberController),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Flexible(
                          child: Text(
                        _memberController.memberInfo.value.name!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                fontWeight: FontWeight.bold),
                      )),
                      const SizedBox(width: 2),
                      if (_memberController.memberInfo.value.sex == '女')
                        const Icon(
                          FontAwesomeIcons.venus,
                          size: 14,
                          color: Colors.pink,
                        ),
                      if (_memberController.memberInfo.value.sex == '男')
                        const Icon(
                          FontAwesomeIcons.mars,
                          size: 14,
                          color: Colors.blue,
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (_memberController.memberInfo.value.sign != '')
                    SelectableText(
                      _memberController.memberInfo.value.sign!,
                    ),
                ],
              );
            } else {
              return const SizedBox();
            }
          } else {
            // 骨架屏
            return ProfilePanel(ctr: _memberController, loadingStatus: true);
          }
        },
      ),
    );
  }

  Widget commenWidget(msg) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        bottom: 30,
      ),
      child: Center(
        child: Text(
          msg,
          style: Theme.of(context)
              .textTheme
              .labelMedium!
              .copyWith(color: Theme.of(context).colorScheme.outline),
        ),
      ),
    );
  }
}
