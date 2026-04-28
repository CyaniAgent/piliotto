import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/repositories/i_comment_repository.dart';
import 'package:piliotto/common/widgets/badge.dart';
import 'package:piliotto/common/widgets/markdown_text.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/models/common/reply_type.dart';
import 'package:piliotto/ottohub/models/video/reply/item.dart';
import 'package:piliotto/pages/video/detail/index.dart';
import 'package:piliotto/plugin/pl_popup/index.dart';
import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/global_data_cache.dart';
import 'package:piliotto/utils/id_utils.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:piliotto/utils/utils.dart';
import 'reply_save.dart';

Box setting = GStrorage.setting;

class ReplyItem extends StatefulWidget {
  const ReplyItem({
    this.replyItem,
    this.addReply,
    this.replyLevel,
    this.showReplyRow = true,
    this.replyReply,
    this.replyType,
    this.replySave = false,
    super.key,
  });
  final ReplyItemModel? replyItem;
  final Function? addReply;
  final String? replyLevel;
  final bool? showReplyRow;
  final Function? replyReply;
  final ReplyType? replyType;
  final bool? replySave;

  @override
  State<ReplyItem> createState() => _ReplyItemState();
}

class _ReplyItemState extends State<ReplyItem> {
  bool _isExpanded = false;
  final ICommentRepository _commentRepo = Get.find<ICommentRepository>();

  bool get _needsExpandButton {
    if (widget.replyItem!.content?.isText == true && widget.replyLevel == '1') {
      final message = widget.replyItem!.content!.message ?? '';
      final lineCount = '\n'.allMatches(message).length + 1;
      final estimatedLines = (message.length / 30).ceil();
      return lineCount > 6 || estimatedLines > 6;
    }
    return false;
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
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  _isExpanded ? '折叠' : '展开',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget lfAvtar(BuildContext context, String heroTag) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Hero(
          tag: heroTag,
          child: NetworkImgLayer(
            src: widget.replyItem!.member!.avatar,
            width: 34,
            height: 34,
            type: 'avatar',
          ),
        ),
        if (widget.replyItem!.member!.officialVerify != null &&
            widget.replyItem!.member!.officialVerify!['type'] == 0)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: colorScheme.surface,
              ),
              child: Icon(
                Icons.offline_bolt,
                color: colorScheme.primary,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }

  Widget content(BuildContext context) {
    final String heroTag = Utils.makeHeroTag(widget.replyItem!.mid);
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        /// fix Stack内GestureDetector  onTap无效
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            feedBack();
            Get.toNamed('/member?mid=${widget.replyItem!.mid}', arguments: {
              'face': widget.replyItem!.member!.avatar!,
              'heroTag': heroTag
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              lfAvtar(context, heroTag),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.replyItem!.member!.uname ?? '',
                        style: TextStyle(
                          color: widget.replyItem!.member!.vip != null &&
                                  widget.replyItem!.member!.vip!['vipStatus'] !=
                                      null &&
                                  widget.replyItem!.member!.vip!['vipStatus'] >
                                      0
                              ? const Color.fromARGB(255, 251, 100, 163)
                              : colorScheme.outline,
                          fontSize: 13,
                        ),
                      ),
                      // Ottohub 头衔显示（支持多个称号，用英文逗号分割）
                      if (widget.replyItem!.member!.ottohubData != null &&
                          widget.replyItem!.member!.ottohubData!['honour'] !=
                              null &&
                          widget.replyItem!.member!.ottohubData!['honour']
                              .toString()
                              .isNotEmpty)
                        ...widget.replyItem!.member!.ottohubData!['honour']
                            .toString()
                            .split(',')
                            .where((e) => e.trim().isNotEmpty)
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
                                ))
                            ,
                      if (widget.replyItem!.isUp!)
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
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: Utils.dateFormat(widget.replyItem!.ctime),
                          style: TextStyle(
                            fontSize: textTheme.labelSmall!.fontSize,
                            color: colorScheme.outline,
                          ),
                        ),
                        if (widget.replyItem!.replyControl != null &&
                            widget.replyItem!.replyControl!.location != null &&
                            widget
                                .replyItem!.replyControl!.location!.isNotEmpty)
                          TextSpan(
                            text:
                                ' \u2022 ${widget.replyItem!.replyControl!.location}',
                            style: TextStyle(
                              fontSize: textTheme.labelSmall!.fontSize,
                              color: colorScheme.outline,
                            ),
                          ),
                        if (widget.replyItem!.invisible == true)
                          TextSpan(
                            text: ' \u2022 隐藏的评论',
                            style: TextStyle(
                              color: colorScheme.outline,
                              fontSize: textTheme.labelSmall!.fontSize,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // title
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
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
                  onTimeJump: (duration) {
                    try {
                      SmartDialog.showToast('跳转至：${duration.inSeconds}秒');
                      Get.find<VideoDetailController>(
                        tag: Get.arguments?['heroTag'] ?? 'default',
                      ).plPlayerController.seekTo(duration);
                    } catch (e) {
                      SmartDialog.showToast('跳转失败: $e');
                    }
                  },
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
                  onTimeJump: (duration) {
                    try {
                      SmartDialog.showToast('跳转至：${duration.inSeconds}秒');
                      Get.find<VideoDetailController>(
                        tag: Get.arguments?['heroTag'] ?? 'default',
                      ).plPlayerController.seekTo(duration);
                    } catch (e) {
                      SmartDialog.showToast('跳转失败: $e');
                    }
                  },
                  atNameToMid: widget.replyItem!.content?.atNameToMid
                      ?.cast<String, int>(),
                ),
              ],
            ),
          ),
        ),
        // 展开/折叠按钮
        if (_needsExpandButton) _buildExpandButton(context),
        // 操作区域
        bottonAction(context, widget.replyItem!.replyControl, widget.replySave),
        // 一楼的评论 - 二级评论功能
        if ((widget.replyItem!.replyControl?.isShow == true ||
                (widget.replyItem!.replies != null &&
                    widget.replyItem!.replies!.isNotEmpty)) &&
            widget.showReplyRow == true) ...[
          Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 12),
            child: ReplyItemRow(
              replies: widget.replyItem!.replies,
              replyControl: widget.replyItem!.replyControl,
              replyItem: widget.replyItem,
              replyReply: widget.replyReply,
            ),
          ),
        ],
      ],
    );
  }

  void _handleMenuAction(
      BuildContext context, String action, ReplyItemModel item) async {
    feedBack();
    String message = item.content!.message ?? '';
    switch (action) {
      case 'copyAll':
        await Clipboard.setData(ClipboardData(text: message));
        SmartDialog.showToast('已复制');
        break;
      case 'save':
        Navigator.push(
          context,
          PlPopupRoute(child: ReplySave(replyItem: item)),
        );
        break;
      case 'delete':
        final bool confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  title: const Text('删除评论'),
                  content: const Text('删除评论后，评论下所有回复将被删除，确定删除吗？'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text('取消',
                          style: TextStyle(
                              color: Theme.of(ctx).colorScheme.outline)),
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
        if (confirmed && context.mounted) {
          try {
            final result = await _commentRepo.deleteVideoComment(
              vcid: item.rpid!,
            );
            if (result['status'] == 'success') {
              SmartDialog.showToast('评论删除成功，需手动刷新');
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

  Widget bottonAction(BuildContext context, replyControl, replySave) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      children: <Widget>[
        const SizedBox(width: 32),
        if (widget.replySave!) ...[
          SizedBox(
            height: 32,
            child: TextButton(
              onPressed: () {},
              child: Text(
                IdUtils.av2bv(widget.replyItem!.oid!),
                style: TextStyle(
                  fontSize: textTheme.labelMedium!.fontSize,
                  color: colorScheme.outline,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(width: 2),
        if (widget.replyItem!.upAction!.like!) ...[
          Text(
            'up主觉得很赞',
            style: TextStyle(
                color: colorScheme.primary,
                fontSize: textTheme.labelMedium!.fontSize),
          ),
          const SizedBox(width: 2),
        ],
        if (widget.replyItem!.cardLabel!.isNotEmpty &&
            widget.replyItem!.cardLabel!.contains('热评')) ...[
          Text(
            '热评',
            style: TextStyle(
                color: colorScheme.primary,
                fontSize: textTheme.labelMedium!.fontSize),
          ),
          const Spacer(),
          PopupMenuButton<String>(
            onSelected: (String value) {
              _handleMenuAction(context, value, widget.replyItem!);
            },
            icon: Icon(Icons.more_horiz, color: colorScheme.outline),
            position: PopupMenuPosition.under,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (BuildContext context) {
              final bool isOwner = int.parse(widget.replyItem!.member!.mid!) ==
                  (GlobalDataCache().userInfo?.mid ?? -1);
              return <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'copyAll',
                  child: Row(
                    children: [
                      Icon(Icons.copy_all_outlined, size: 19),
                      SizedBox(width: 12),
                      Text('复制全部'),
                    ],
                  ),
                ),
                if (widget.replyItem!.content!.pictures!.isEmpty)
                  const PopupMenuItem<String>(
                    value: 'save',
                    child: Row(
                      children: [
                        Icon(Icons.save_alt_rounded, size: 19),
                        SizedBox(width: 12),
                        Text('本地保存'),
                      ],
                    ),
                  ),
                if (isOwner)
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline,
                            size: 19, color: colorScheme.error),
                        const SizedBox(width: 12),
                        Text('删除评论',
                            style: TextStyle(color: colorScheme.error)),
                      ],
                    ),
                  ),
              ];
            },
          ),
          const SizedBox(width: 5)
        ],
      ],
    );
  }
}

// ignore: must_be_immutable
class ReplyItemRow extends StatelessWidget {
  ReplyItemRow({
    super.key,
    this.replies,
    this.replyControl,
    // this.f_rpid,
    this.replyItem,
    this.replyReply,
  });
  final List? replies;
  ReplyControl? replyControl;
  // int? f_rpid;
  ReplyItemModel? replyItem;
  Function? replyReply;

  @override
  Widget build(BuildContext context) {
    final bool isShow = replyControl!.isShow!;
    final int extraRow = replyControl != null && isShow ? 1 : 0;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(left: 42, right: 4, top: 0),
      child: Material(
        color: colorScheme.onInverseSurface,
        borderRadius: BorderRadius.circular(6),
        clipBehavior: Clip.hardEdge,
        animationDuration: Duration.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (replies!.isNotEmpty)
              for (int i = 0; i < replies!.length; i++) ...[
                InkWell(
                  onTap: () {
                    replyReply?.call(
                      replyItem,
                      replies![i],
                      replyItem!.replies!.isNotEmpty,
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      8,
                      i == 0 && (extraRow == 1 || replies!.length > 1) ? 8 : 5,
                      8,
                      6,
                    ),
                    child: MarkdownText(
                      text: replies![i].content.message ?? '',
                      style: TextStyle(
                        fontSize: textTheme.titleSmall!.fontSize,
                      ),
                      maxLines: 2,
                      atNameToMid:
                          replies![i].content.atNameToMid?.cast<String, int>(),
                    ),
                  ),
                )
              ],
            if (extraRow == 1)
              InkWell(
                onTap: () => replyReply?.call(replyItem, null, true),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(8, 5, 8, 8),
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: textTheme.labelMedium!.fontSize,
                      ),
                      children: [
                        if (replyControl!.upReply!)
                          const TextSpan(text: 'up主等人 '),
                        TextSpan(
                          text: replyControl!.entryText!,
                          style: TextStyle(
                            color: colorScheme.primary,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}

class MorePanel extends StatelessWidget {
  final dynamic item;
  final bool mainFloor;
  final bool isOwner;

  const MorePanel({
    super.key,
    required this.item,
    this.mainFloor = false,
    this.isOwner = false,
  });

  Future<dynamic> menuActionHandler(BuildContext context, String type) async {
    String message = item.content.message ?? item.content;
    switch (type) {
      case 'copyAll':
        await Clipboard.setData(ClipboardData(text: message));
        SmartDialog.showToast('已复制');
        if (context.mounted) {
          Navigator.of(context).pop();
        }
        break;
      case 'save':
        if (context.mounted) {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            PlPopupRoute(child: ReplySave(replyItem: item)),
          );
        }
        break;
      case 'delete':
        await showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('删除评论'),
              content: const Text('删除评论后，评论下所有回复将被删除，确定删除吗？'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('取消',
                      style:
                          TextStyle(color: Theme.of(ctx).colorScheme.outline)),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    try {
                      final result = await Get.find<ICommentRepository>().deleteVideoComment(
                        vcid: item.rpid!,
                      );
                      if (result['status'] == 'success') {
                        SmartDialog.showToast('评论删除成功，需手动刷新');
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      } else {
                        SmartDialog.showToast(result['message'] ?? '删除失败');
                      }
                    } catch (e) {
                      SmartDialog.showToast('删除失败: $e');
                    }
                  },
                  child: const Text('确定'),
                ),
              ],
            );
          },
        );
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    Color errorColor = colorScheme.error;

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              height: 35,
              padding: const EdgeInsets.only(bottom: 2),
              child: Center(
                child: Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                      color: colorScheme.outline,
                      borderRadius: const BorderRadius.all(Radius.circular(3))),
                ),
              ),
            ),
          ),
          ListTile(
            onTap: () async => await menuActionHandler(context, 'copyAll'),
            minLeadingWidth: 0,
            leading: const Icon(Icons.copy_all_outlined, size: 19),
            title: Text('复制全部', style: textTheme.titleSmall),
          ),
          if (mainFloor && item.content.pictures.isEmpty)
            ListTile(
              onTap: () async => await menuActionHandler(context, 'save'),
              minLeadingWidth: 0,
              leading: const Icon(Icons.save_alt_rounded, size: 19),
              title: Text('本地保存', style: textTheme.titleSmall),
            ),
          if (isOwner)
            ListTile(
              onTap: () async => await menuActionHandler(context, 'delete'),
              minLeadingWidth: 0,
              leading: Icon(Icons.delete_outline, color: errorColor),
              title: Text('删除评论',
                  style: textTheme.titleSmall!.copyWith(color: errorColor)),
            ),
        ],
      ),
    );
  }
}
