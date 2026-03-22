import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:piliotto/api/services/old_api_service.dart';
import 'package:piliotto/models/common/reply_type.dart';
import 'package:piliotto/models/video/reply/item.dart';
import 'package:piliotto/utils/feed_back.dart';

import 'toolbar_icon_button.dart';

class VideoReplyNewDialog extends StatefulWidget {
  final int? oid;
  final int? root;
  final int? parent;
  final ReplyType? replyType;
  final ReplyItemModel? replyItem;

  const VideoReplyNewDialog({
    super.key,
    this.oid,
    this.root,
    this.parent,
    this.replyType,
    this.replyItem,
  });

  @override
  State<VideoReplyNewDialog> createState() => _VideoReplyNewDialogState();
}

class _VideoReplyNewDialogState extends State<VideoReplyNewDialog>
    with WidgetsBindingObserver {
  final TextEditingController _replyContentController = TextEditingController();
  final FocusNode replyContentFocusNode = FocusNode();
  final GlobalKey _formKey = GlobalKey<FormState>();
  double keyboardHeight = 0.0;
  final _debouncer = Debouncer(milliseconds: 200);
  String toolbarType = 'input';
  RxBool isForward = false.obs;
  RxBool showForward = false.obs;
  RxString message = ''.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _autoFocus();
    _focuslistener();
    final String routePath = Get.currentRoute;
    if (routePath.startsWith('/video')) {
      showForward.value = true;
    }
  }

  _autoFocus() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      FocusScope.of(context).requestFocus(replyContentFocusNode);
    }
  }

  _focuslistener() {
    replyContentFocusNode.addListener(() {
      if (replyContentFocusNode.hasFocus) {
        setState(() {
          toolbarType = 'input';
        });
      }
    });
  }

  Future submitReplyAdd() async {
    feedBack();
    if (_replyContentController.text.isEmpty) {
      SmartDialog.showToast('请输入评论内容');
      return;
    }
    try {
      final res = await OldApiService.commentVideo(
        vid: widget.oid!,
        parentVcid: widget.parent ?? 0,
        content: _replyContentController.text,
      );
      if (res['status'] == 'success') {
        SmartDialog.showToast('评论成功');
        Get.back(result: true);
      } else {
        SmartDialog.showToast(res['message'] ?? '评论失败');
      }
    } catch (e) {
      SmartDialog.showToast('评论失败: $e');
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final String routePath = Get.currentRoute;
    if (mounted &&
        (routePath.startsWith('/video') ||
            routePath.startsWith('/dynamicDetail'))) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final viewInsets = EdgeInsets.fromViewPadding(
            View.of(context).viewInsets, View.of(context).devicePixelRatio);
        _debouncer.run(() {
          if (mounted) {
            if (keyboardHeight == 0) {
              setState(() {
                keyboardHeight =
                    keyboardHeight == 0.0 ? viewInsets.bottom : keyboardHeight;
              });
            }
          }
        });
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _replyContentController.dispose();
    replyContentFocusNode.removeListener(() {});
    replyContentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 200,
              minHeight: 120,
            ),
            child: Container(
              padding: const EdgeInsets.only(
                  top: 12, right: 15, left: 15, bottom: 10),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: TextField(
                    controller: _replyContentController,
                    minLines: 3,
                    maxLines: null,
                    autofocus: false,
                    focusNode: replyContentFocusNode,
                    decoration: const InputDecoration(
                        hintText: "输入回复内容",
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 14,
                        )),
                    style: Theme.of(context).textTheme.bodyLarge,
                    onChanged: (text) {
                      message.value = text;
                    },
                  ),
                ),
              ),
            ),
          ),
          Divider(
            height: 1,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
          Container(
            height: 52,
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
            ),
            margin: EdgeInsets.only(
              bottom: toolbarType == 'input' && keyboardHeight == 0.0
                  ? MediaQuery.of(context).padding.bottom
                  : 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ToolbarIconButton(
                  onPressed: () {
                    FocusScope.of(context).requestFocus(replyContentFocusNode);
                  },
                  icon: const Icon(Icons.keyboard, size: 22),
                  toolbarType: toolbarType,
                  selected: toolbarType == 'input',
                ),
                const SizedBox(width: 6),
                Obx(
                  () => showForward.value
                      ? TextButton.icon(
                          onPressed: () {
                            isForward.value = !isForward.value;
                          },
                          icon: Icon(
                              isForward.value
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              size: 22),
                          label: const Text('转发到动态'),
                          style: ButtonStyle(
                            foregroundColor: WidgetStateProperty.all(
                              isForward.value
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        )
                      : const SizedBox(),
                ),
                const Spacer(),
                SizedBox(
                  height: 36,
                  child: Obx(
                    () => FilledButton(
                      onPressed: message.isNotEmpty ? submitReplyAdd : null,
                      child: const Text('发送'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

typedef DebounceCallback = void Function();

class Debouncer {
  DebounceCallback? callback;
  final int? milliseconds;
  Timer? _timer;

  Debouncer({this.milliseconds});

  run(DebounceCallback callback) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds!), () {
      callback();
    });
  }
}
