import 'package:flutter/material.dart';
import 'package:piliotto/ottohub/models/dynamics/result.dart';

import 'action_panel.dart';
import 'author_panel.dart';
import 'content_panel.dart';

class DynamicPanel extends StatelessWidget {
  final DynamicItemModel item;
  final String? source;
  final VoidCallback? onTap;
  final VoidCallback? onCommentTap;

  const DynamicPanel({
    required this.item,
    this.source,
    this.onTap,
    this.onCommentTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withAlpha(50),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AuthorPanel(item: item),
              if (item.modules?.moduleDynamic?.desc != null ||
                  item.modules?.moduleDynamic?.major != null) ...[
                const SizedBox(height: 10),
                Content(item: item, source: source),
              ],
              const SizedBox(height: 4),
              if (source == null)
                ActionPanel(item: item, onCommentTap: onCommentTap),
            ],
          ),
        ),
      ),
    );
  }
}
