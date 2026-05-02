import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:piliotto/common/widgets/badge.dart';
import 'package:piliotto/common/widgets/markdown_text.dart';
import 'package:piliotto/models/common/reply_type.dart';
import 'package:piliotto/ottohub/models/video/reply/item.dart';

class ReplyItem extends StatefulWidget {
  const ReplyItem({
    this.replyItem,
    this.addReply,
    this.replyLevel,
    this.showReplyRow = true,
    this.replyReply,
    this.replyType,
    this.replySave = false,
    this.onTimeJump,
    super.key,
  });
  final ReplyItemModel? replyItem;
  final Function? addReply;
  final String? replyLevel;
  final bool? showReplyRow;
  final Function? replyReply;
  final ReplyType? replyType;
  final bool? replySave;
  final Function(Duration)? onTimeJump;

  @override
  State<ReplyItem> createState() => _ReplyItemState();
}

class _ReplyItemState extends State<ReplyItem> {
  bool _isExpanded = false;

  bool get _needsExpandButton {
    if (widget.replyItem!.content?.isText == true && widget.replyLevel == '1') {
      final message = widget.replyItem!.content!.message ?? '';
      final lineCount = '\n'.allMatches(message).length + 1;
      final estimatedLines = (message.length / 30).ceil();
      return lineCount > 6 || estimatedLines > 6;
    }
    return false;
  }

  void _handleTimeJump(Duration duration) {
    SmartDialog.showToast('跳转至：${duration.inSeconds}秒');
    widget.onTimeJump?.call(duration);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 8, 5),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          width: 1,
          color: Theme.of(context)
              .colorScheme
              .onInverseSurface
              .withValues(alpha: 0.5),
        ))),
        child: content(context),
      ),
    );
  }

  Widget _buildExpandButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 45, top: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Row(
            children: [
              Text(
                _isExpanded ? '收起' : '展开',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.primary,
                ),
              ),
              Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 18,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget content(BuildContext context) {
    return Column(
      children: [
        AnimatedCrossFade(
          firstChild: Container(
            margin:
                const EdgeInsets.only(top: 10, left: 45, right: 6, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.replyItem!.isTop == true)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: PBadge(
                      text: 'TOP',
                      size: 'small',
                      stack: 'normal',
                      type: 'line',
                      fs: 9,
                    ),
                  ),
                MarkdownText(
                  text: widget.replyItem!.content?.message ?? '',
                  style: const TextStyle(height: 1.75),
                  maxLines: widget.replyItem!.content?.isText == true &&
                          widget.replyLevel == '1'
                      ? 6
                      : null,
                  enableTimeJump: true,
                  onTimeJump: _handleTimeJump,
                  atNameToMid: widget.replyItem!.content?.atNameToMid
                      ?.cast<String, int>(),
                ),
              ],
            ),
          ),
          secondChild: Container(
            margin:
                const EdgeInsets.only(top: 10, left: 45, right: 6, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.replyItem!.isTop == true)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: PBadge(
                      text: 'TOP',
                      size: 'small',
                      stack: 'normal',
                      type: 'line',
                      fs: 9,
                    ),
                  ),
                MarkdownText(
                  text: widget.replyItem!.content?.message ?? '',
                  style: const TextStyle(height: 1.75),
                  enableTimeJump: true,
                  onTimeJump: _handleTimeJump,
                  atNameToMid: widget.replyItem!.content?.atNameToMid
                      ?.cast<String, int>(),
                ),
              ],
            ),
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        if (_needsExpandButton) _buildExpandButton(context),
        bottonAction(
            context, widget.replyItem!.replyControl, widget.replySave ?? false),
        if ((widget.replyItem!.replyControl?.isShow == true ||
                (widget.replyItem!.replies != null &&
                    widget.replyItem!.replies!.isNotEmpty)) &&
            widget.showReplyRow == true) ...[
          Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 12),
            child: ReplyItemRow(
              replies: widget.replyItem!.replies?.cast<ReplyItemModel>(),
              replyControl: widget.replyItem!.replyControl,
              replyItem: widget.replyItem,
              replyReply: widget.replyReply,
            ),
          ),
        ],
      ],
    );
  }
}

Widget bottonAction(
    BuildContext context, ReplyControl? replyControl, bool replySave) {
  return Container();
}

class ReplyItemRow extends StatelessWidget {
  const ReplyItemRow({
    this.replies,
    this.replyControl,
    this.replyItem,
    this.replyReply,
    super.key,
  });

  final List<ReplyItemModel>? replies;
  final ReplyControl? replyControl;
  final ReplyItemModel? replyItem;
  final Function? replyReply;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
