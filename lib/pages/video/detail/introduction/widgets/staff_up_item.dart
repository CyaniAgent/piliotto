import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/models/video_detail_res.dart';
import 'package:piliotto/utils/utils.dart';

class StaffUpItem extends StatelessWidget {
  final Staff item;

  const StaffUpItem({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final String heroTag = Utils.makeHeroTag(item.mid);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 15),
        GestureDetector(
          onTap: () => context.push(
            '/member?mid=${item.mid}',
            extra: {'face': item.face, 'heroTag': heroTag},
          ),
          child: Hero(
            tag: heroTag,
            child: NetworkImgLayer(
              width: 45,
              height: 45,
              src: item.face,
              type: 'avatar',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: SizedBox(
            width: 85,
            child: Text(
              item.name!,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: item.vip!.status == 1
                    ? const Color.fromARGB(255, 251, 100, 163)
                    : null,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: SizedBox(
            width: 85,
            child: Text(
              item.title!,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
