import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/pages/dynamics/index.dart';
import 'action_panel.dart';
import 'author_panel.dart';
import 'content_panel.dart';

class DynamicPanel extends StatelessWidget {
  final dynamic item;
  final String? source;

  const DynamicPanel({
    required this.item,
    this.source,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controller = Get.find<DynamicsController>();

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
        onTap: () => controller.pushDetail(item, 1),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AuthorPanel(item: item),
              if (item.modules?.moduleDynamic?.desc != null ||
                  item.modules?.moduleDynamic?.major != null) ...[
                const SizedBox(height: 12),
                Content(item: item, source: source),
              ],
              const SizedBox(height: 8),
              if (source == null) ActionPanel(item: item),
            ],
          ),
        ),
      ),
    );
  }
}
