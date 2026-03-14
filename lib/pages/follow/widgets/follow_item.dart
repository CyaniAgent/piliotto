import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/api/models/following.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/utils.dart';

class FollowItem extends StatelessWidget {
  final FollowingUser user;
  const FollowItem({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    String heroTag = Utils.makeHeroTag(user.uid);
    return ListTile(
      onTap: () {
        feedBack();
        Get.toNamed('/member?mid=${user.uid}',
            arguments: {'face': user.avatarUrl, 'heroTag': heroTag});
      },
      leading: Hero(
        tag: heroTag,
        child: NetworkImgLayer(
          width: 45,
          height: 45,
          type: 'avatar',
          src: user.avatarUrl,
        ),
      ),
      title: Text(
        user.username,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14),
      ),
      dense: true,
    );
  }
}
