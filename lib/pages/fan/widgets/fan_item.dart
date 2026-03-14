import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/api/models/following.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/utils/utils.dart';

class FanItem extends StatelessWidget {
  final FollowingUser user;
  const FanItem({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    String heroTag = Utils.makeHeroTag(user.uid);
    return ListTile(
      onTap: () => Get.toNamed('/member?mid=${user.uid}',
          arguments: {'face': user.avatarUrl, 'heroTag': heroTag}),
      leading: Hero(
        tag: heroTag,
        child: NetworkImgLayer(
          width: 38,
          height: 38,
          type: 'avatar',
          src: user.avatarUrl,
        ),
      ),
      title: Text(user.username),
      dense: true,
      trailing: const SizedBox(width: 6),
    );
  }
}
