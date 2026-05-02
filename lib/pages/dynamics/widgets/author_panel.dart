import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/utils.dart';

class AuthorPanel extends StatelessWidget {
  final dynamic item;

  const AuthorPanel({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final author = item.modules?.moduleAuthor;
    final desc = item.modules?.moduleDynamic?.desc;

    if (author == null) return const SizedBox.shrink();

    final heroTag = Utils.makeHeroTag(author.mid);
    final avatarUrl = author.face ?? '';
    final pubTime = author.pubTime ?? '';
    // 使用内容标题，如果没有标题则使用"动态"
    final title =
        (desc?.title != null && desc!.title!.isNotEmpty) ? desc.title! : '动态';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            feedBack();
            context.push(
              '/member?mid=${author.mid}',
              extra: {
                'face': avatarUrl,
                'heroTag': heroTag,
              },
            );
          },
          child: Hero(
            tag: heroTag,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.primaryContainer,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: NetworkImgLayer(
                  width: 44,
                  height: 44,
                  type: 'avatar',
                  src: avatarUrl,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                pubTime,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
