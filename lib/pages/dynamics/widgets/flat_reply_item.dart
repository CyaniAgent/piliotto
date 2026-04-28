import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/widgets/badge.dart';
import 'package:piliotto/common/widgets/markdown_text.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/ottohub/models/video/reply/item.dart';
import 'package:piliotto/repositories/i_comment_repository.dart';
import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/global_data_cache.dart';
import 'package:piliotto/utils/utils.dart';

class FlatReplyItem extends StatefulWidget {
  final ReplyItemModel replyItem;
  final int? bid;
  final Function? onReply;
  final Function? onRefresh;
  final bool isBlogComment;

  const FlatReplyItem({
    super.key,
    required this.replyItem,
    this.bid,
    this.onReply,
    this.onRefresh,
    this.isBlogComment = true,
  });

  @override
  State<FlatReplyItem> createState() => _FlatReplyItemState();
}

class _FlatReplyItemState extends State<FlatReplyItem> {
  bool _isExpanded = false;
  final ICommentRepository _commentRepo = Get.find<ICommentRepository>();

  bool get _needsExpandButton {
    final message = widget.replyItem.content?.message ?? '';
    final lineCount = '\n'.allMatches(message).length + 1;
    final estimatedLines = (message.length / 30).ceil();
    return lineCount > 6 || estimatedLines > 6;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final heroTag = Utils.makeHeroTag(widget.replyItem.mid);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: colorScheme.onInverseSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, colorScheme, heroTag),
          const SizedBox(height: 8),
          _buildContent(context),
          if (_needsExpandButton) _buildExpandButton(context),
          _buildBottomAction(context),
          if (widget.replyItem.replyControl?.isShow == true ||
              (widget.replyItem.replies != null &&
                  widget.replyItem.replies!.isNotEmpty))
            _buildReplyRow(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme, String heroTag) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        feedBack();
        Get.toNamed('/member?mid=${widget.replyItem.mid}', arguments: {
          'face': widget.replyItem.member?.avatar,
          'heroTag': heroTag,
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAvatar(context, heroTag),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.replyItem.member?.uname ?? '未知用户',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: widget.replyItem.member?.vip != null &&
                                  widget.replyItem.member!.vip!['vipStatus'] != null &&
                                  widget.replyItem.member!.vip!['vipStatus'] > 0
                              ? const Color.fromARGB(255, 251, 100, 163)
                              : colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.replyItem.member?.ottohubData?['honour'] != null &&
                        widget.replyItem.member!.ottohubData!['honour']
                            .toString()
                            .isNotEmpty)
                      ...widget.replyItem.member!.ottohubData!['honour']
                          .toString()
                          .split(',')
                          .where((e) => e.trim().isNotEmpty)
                          .take(1)
                          .map((title) => Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  title.trim(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              )),
                    if (widget.replyItem.isUp == true)
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: PBadge(
                          text: 'UP',
                          size: 'small',
                          stack: 'normal',
                          fs: 9,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  Utils.dateFormat(widget.replyItem.ctime),
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          _buildMoreButton(context),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, String heroTag) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Hero(
          tag: heroTag,
          child: ClipOval(
            child: NetworkImgLayer(
              src: widget.replyItem.member?.avatar,
              width: 36,
              height: 36,
              type: 'avatar',
            ),
          ),
        ),
        if (widget.replyItem.member?.officialVerify != null &&
            widget.replyItem.member!.officialVerify!['type'] == 0)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: colorScheme.surface,
              ),
              child: Icon(
                Icons.offline_bolt,
                color: colorScheme.primary,
                size: 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 46, right: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.replyItem.isTop == true)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: PBadge(
                text: 'TOP',
                size: 'small',
                stack: 'normal',
                type: 'line',
                fs: 9,
              ),
            ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: MarkdownText(
              text: widget.replyItem.content?.message ?? '',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface,
                height: 1.6,
              ),
              maxLines: 6,
            ),
            secondChild: MarkdownText(
              text: widget.replyItem.content?.message ?? '',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 46, top: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _isExpanded ? '收起' : '展开',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 46, top: 8),
      child: Row(
        children: [
          if (widget.replyItem.upAction?.like == true) ...[
            Icon(
              Icons.thumb_up_outlined,
              size: 14,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'UP主觉得很赞',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (widget.replyItem.cardLabel?.contains('热评') == true) ...[
            Icon(
              Icons.local_fire_department_outlined,
              size: 14,
              color: colorScheme.tertiary,
            ),
            const SizedBox(width: 4),
            Text(
              '热评',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.tertiary,
              ),
            ),
          ],
          const Spacer(),
          _buildReplyButton(context),
        ],
      ),
    );
  }

  Widget _buildReplyButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          feedBack();
          widget.onReply?.call(widget.replyItem);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 16,
                color: colorScheme.outline,
              ),
              const SizedBox(width: 4),
              Text(
                '回复',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isOwner = int.parse(widget.replyItem.member?.mid ?? '0') ==
        (GlobalDataCache().userInfo?.mid ?? -1);

    return PopupMenuButton<String>(
      onSelected: (String value) {
        _handleMenuAction(context, value);
      },
      icon: Icon(
        Icons.more_horiz,
        color: colorScheme.outline,
        size: 20,
      ),
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'copy',
            child: Row(
              children: [
                Icon(Icons.copy_outlined, size: 18),
                SizedBox(width: 12),
                Text('复制'),
              ],
            ),
          ),
          if (isOwner)
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18, color: colorScheme.error),
                  const SizedBox(width: 12),
                  Text('删除', style: TextStyle(color: colorScheme.error)),
                ],
              ),
            ),
        ];
      },
    );
  }

  void _handleMenuAction(BuildContext context, String action) async {
    feedBack();
    switch (action) {
      case 'copy':
        await Clipboard.setData(
          ClipboardData(text: widget.replyItem.content?.message ?? ''),
        );
        SmartDialog.showToast('已复制');
        break;
      case 'delete':
        final bool confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  title: const Text('删除评论'),
                  content: const Text('确定删除这条评论吗？'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(
                        '取消',
                        style: TextStyle(color: Theme.of(ctx).colorScheme.outline),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('确定'),
                    ),
                  ],
                );
              },
            ) ??
            false;
        if (confirmed) {
          try {
            Map<String, dynamic> result;
            if (widget.isBlogComment) {
              result = await _commentRepo.deleteBlogComment(
                bcid: widget.replyItem.rpid!,
              );
            } else {
              result = await _commentRepo.deleteVideoComment(
                vcid: widget.replyItem.rpid!,
              );
            }
            if (result['status'] == 'success') {
              SmartDialog.showToast('删除成功');
              widget.onRefresh?.call();
            } else {
              SmartDialog.showToast(result['message'] ?? '删除失败');
            }
          } catch (e) {
            SmartDialog.showToast('删除失败: $e');
          }
        }
        break;
    }
  }

  Widget _buildReplyRow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final replies = widget.replyItem.replies ?? [];
    final replyControl = widget.replyItem.replyControl;
    final bool isShow = replyControl?.isShow ?? false;

    return Container(
      margin: const EdgeInsets.only(left: 46, top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (replies.isNotEmpty)
            ...replies.take(3).map((reply) => GestureDetector(
                  onTap: () {
                    widget.onReply?.call(widget.replyItem, reply);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${reply.member?.uname ?? ''}：',
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.primary,
                            ),
                          ),
                          TextSpan(
                            text: reply.content?.message ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )),
          if (isShow)
            GestureDetector(
              onTap: () {
                widget.onReply?.call(widget.replyItem, null, true);
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  replyControl?.entryText ?? '查看更多回复',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
