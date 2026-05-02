import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:piliotto/common/widgets/markdown_text.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/plugin/pl_gallery/index.dart';
import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/utils.dart';

class DynamicDetailHeader extends StatefulWidget {
  final dynamic item;

  const DynamicDetailHeader({super.key, required this.item});

  @override
  State<DynamicDetailHeader> createState() => _DynamicDetailHeaderState();
}

class _DynamicDetailHeaderState extends State<DynamicDetailHeader> {
  List<String> picList = [];
  List<String> heroTags = [];
  bool get hasPics => picList.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadPics();
  }

  void _loadPics() {
    final major = widget.item.modules?.moduleDynamic?.major;
    if (major?.draw?.items != null) {
      picList = major!.draw!.items!
          .map((item) => item.src ?? '')
          .cast<String>()
          .toList();
      heroTags = picList
          .asMap()
          .entries
          .map((e) => Utils.makeHeroTag('${e.value}_${e.key}'))
          .toList();
    }
  }

  void onPreviewImg(int initIndex) {
    if (!mounted) return;
    Navigator.of(context).push(
      HeroDialogRoute<void>(
        builder: (context) => InteractiveviewerGallery(
          sources: picList,
          initIndex: initIndex,
          heroTags: heroTags,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final author = widget.item.modules?.moduleAuthor;
    final desc = widget.item.modules?.moduleDynamic?.desc;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAuthorSection(theme, colorScheme, author),
          if (desc != null && desc.text != null && desc.text!.isNotEmpty) ...[
            const SizedBox(height: 12),
            MarkdownText(
              text: desc.text!,
              selectable: true,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                height: 1.6,
              ),
            ),
          ],
          if (hasPics) ...[
            const SizedBox(height: 12),
            _buildPicsGrid(),
          ],
        ],
      ),
    );
  }

  Widget _buildAuthorSection(
      ThemeData theme, ColorScheme colorScheme, dynamic author) {
    if (author == null) return const SizedBox.shrink();

    final heroTag = Utils.makeHeroTag(author.mid);
    final avatarUrl = author.face ?? '';
    final pubTime = author.pubTime ?? '';
    final desc = widget.item.modules?.moduleDynamic?.desc;
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

  Widget _buildPicsGrid() {
    final count = picList.length;

    if (count == 1) {
      return _buildSingleImage();
    }

    return _buildImageGrid(count);
  }

  Widget _buildSingleImage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final height = maxWidth * 0.6;

        return GestureDetector(
          onTap: () => onPreviewImg(0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Hero(
              tag: heroTags.first,
              child: NetworkImgLayer(
                src: picList.first,
                width: maxWidth,
                height: height,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageGrid(int count) {
    final crossAxisCount = count < 3 ? 2 : 3;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final itemSize = (maxWidth - (crossAxisCount - 1) * 8) / crossAxisCount;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(count.clamp(0, 9), (index) {
            return GestureDetector(
              onTap: () => onPreviewImg(index),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Hero(
                  tag: heroTags[index],
                  child: NetworkImgLayer(
                    src: picList[index],
                    width: itemSize,
                    height: itemSize,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
