import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:piliotto/repositories/i_comment_repository.dart';
import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/storage.dart';

class BlogCommentInput extends StatefulWidget {
  final int bid;
  final int parentBcid;
  final String? placeholder;
  final Function()? onCommentSuccess;

  const BlogCommentInput({
    super.key,
    required this.bid,
    this.parentBcid = 0,
    this.placeholder,
    this.onCommentSuccess,
  });

  @override
  State<BlogCommentInput> createState() => _BlogCommentInputState();
}

class _BlogCommentInputState extends State<BlogCommentInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSubmitting = false;
  bool _hasText = false;
  String? _token;
  final ICommentRepository _commentRepo = Get.find<ICommentRepository>();

  @override
  void initState() {
    super.initState();
    try {
      _token = GStrorage.setting.get('ottohub_token');
    } catch (_) {
      _token = null;
    }
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_isSubmitting) return;

    final content = _controller.text.trim();
    if (content.isEmpty) {
      SmartDialog.showToast('请输入评论内容');
      return;
    }

    if (_token == null || _token!.isEmpty) {
      SmartDialog.showToast('请先登录');
      return;
    }

    feedBack();
    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _commentRepo.commentBlog(
        bid: widget.bid,
        parentBcid: widget.parentBcid,
        content: content,
      );

      if (response['status'] == 'success') {
        SmartDialog.showToast('评论成功喵~');
        _controller.clear();
        _focusNode.unfocus();
        widget.onCommentSuccess?.call();
      } else {
        SmartDialog.showToast(response['message'] ?? '评论失败');
      }
    } catch (e) {
      SmartDialog.showToast('评论失败: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: keyboardHeight > 0 ? keyboardHeight + 8 : bottomPadding + 8,
      ),
      duration: const Duration(milliseconds: 100),
      child: Container(
        padding: const EdgeInsets.only(
          left: 12,
          right: 12,
          top: 8,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 40,
                  maxHeight: 100,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: 5,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: widget.placeholder ?? '发一条友善的评论喵~',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.outline,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    counterText: '',
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _isSubmitting ? null : _submitComment,
              icon: _isSubmitting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: _hasText
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHigh,
                foregroundColor: _hasText
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.outline,
                disabledBackgroundColor: theme.colorScheme.surfaceContainerHigh,
                disabledForegroundColor: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
