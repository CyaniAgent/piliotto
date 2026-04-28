import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:piliotto/repositories/i_dynamics_repository.dart';
import 'package:piliotto/ottohub/models/dynamics/result.dart';

class ActionPanel extends StatefulWidget {
  final DynamicItemModel item;
  final VoidCallback? onCommentTap;

  const ActionPanel({
    super.key,
    required this.item,
    this.onCommentTap,
  });

  @override
  State<ActionPanel> createState() => _ActionPanelState();
}

class _ActionPanelState extends State<ActionPanel> {
  final IDynamicsRepository _dynamicsRepo = Get.find<IDynamicsRepository>();
  late ModuleStatModel stat;
  bool isProcessing = false;
  bool isLiked = false;
  String likeCount = '0';

  @override
  void initState() {
    super.initState();
    stat = widget.item.modules?.moduleStat ?? ModuleStatModel();
    isLiked = stat.like?.status ?? false;
    likeCount = stat.like?.count ?? '0';
  }

  Future<void> onLikeDynamic() async {
    if (isProcessing) return;

    if (!mounted) return;
    setState(() => isProcessing = true);

    try {
      final dynamicId = widget.item.idStr ?? '';
      final res = await _dynamicsRepo.likeBlog(
        bid: int.tryParse(dynamicId) ?? 0,
      );

      if (!mounted) return;

      if (res['status'] == 'success') {
        SmartDialog.showToast(isLiked ? '取消点赞' : '点赞成功');
        setState(() {
          isLiked = !isLiked;
          final count = int.tryParse(likeCount) ?? 0;
          likeCount = (isLiked ? count + 1 : count - 1).toString();
        });
      } else {
        SmartDialog.showToast(res['message'] ?? '操作失败');
      }
    } catch (e) {
      if (!mounted) return;
      SmartDialog.showToast('请求失败: $e');
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentCount = stat.comment?.count ?? '0';
    final forwardCount = stat.forward?.count ?? '0';
    final hasForward = forwardCount != '0' && forwardCount.isNotEmpty;

    return Row(
      children: [
        _ActionButton(
          icon: FontAwesomeIcons.comment,
          label: commentCount,
          onTap: widget.onCommentTap ?? () {},
        ),
        _ActionButton(
          icon: isLiked
              ? FontAwesomeIcons.solidThumbsUp
              : FontAwesomeIcons.thumbsUp,
          label: likeCount,
          isActive: isLiked,
          onTap: onLikeDynamic,
        ),
        _ActionButton(
          icon: FontAwesomeIcons.shareFromSquare,
          label: hasForward ? forwardCount : null,
          onTap: () {},
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final dynamic icon;
  final String? label;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = isActive ? colorScheme.primary : colorScheme.outline;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon is FaIconData)
                  FaIcon(icon, size: 16, color: color)
                else if (icon is IconData)
                  Icon(icon, size: 16, color: color),
                if (label != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    label!,
                    style: theme.textTheme.bodySmall?.copyWith(color: color),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
