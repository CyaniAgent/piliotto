import 'package:flutter/material.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/plugin/pl_gallery/index.dart';

class Content extends StatefulWidget {
  final dynamic item;
  final String? source;

  const Content({super.key, this.item, this.source});

  @override
  State<Content> createState() => _ContentState();
}

class _ContentState extends State<Content> {
  List<String> picList = [];
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
    }
  }

  void onPreviewImg(int initIndex) {
    Navigator.of(context).push(
      HeroDialogRoute<void>(
        builder: (context) => InteractiveviewerGallery(
          sources: picList,
          initIndex: initIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final desc = widget.item.modules?.moduleDynamic?.desc;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (desc != null && desc.text != null && desc.text!.isNotEmpty)
          SelectionArea(
            child: Text(
              desc.text!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              maxLines: widget.source == 'detail' ? null : 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (hasPics) ...[
          const SizedBox(height: 12),
          _buildPicsGrid(),
        ],
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
              tag: picList.first,
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
                  tag: picList[index],
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
