import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class DanmakuSendSheet extends StatefulWidget {
  final int vid;
  final int currentTime;
  final Future<void> Function({
    required int vid,
    required String text,
    required int time,
    required String mode,
    required String color,
    required String fontSize,
  }) onSend;

  const DanmakuSendSheet({
    super.key,
    required this.vid,
    required this.currentTime,
    required this.onSend,
  });

  @override
  State<DanmakuSendSheet> createState() => _DanmakuSendSheetState();

  static void show({
    required int vid,
    required int currentTime,
    required Future<void> Function({
      required int vid,
      required String text,
      required int time,
      required String mode,
      required String color,
      required String fontSize,
    }) onSend,
  }) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DanmakuSendSheet(
          vid: vid,
          currentTime: currentTime,
          onSend: onSend,
        );
      },
    );
  }
}

class _DanmakuSendSheetState extends State<DanmakuSendSheet> {
  final TextEditingController _textController = TextEditingController();
  bool _isSending = false;
  String _danmakuMode = 'scroll';
  String _danmakuColor = 'ffffff';
  String _danmakuFontSize = '25px';

  static const List<Map<String, dynamic>> _modeOptions = [
    {'value': 'scroll', 'label': '滚动', 'icon': Icons.swap_horiz},
    {'value': 'top', 'label': '顶部', 'icon': Icons.vertical_align_top},
    {'value': 'bottom', 'label': '底部', 'icon': Icons.vertical_align_bottom},
  ];

  static const List<Map<String, dynamic>> _colorOptions = [
    {'value': 'ffffff', 'color': Colors.white},
    {'value': 'ff0000', 'color': Colors.red},
    {'value': 'ff9900', 'color': Colors.orange},
    {'value': 'ffff00', 'color': Colors.yellow},
    {'value': '00ff00', 'color': Colors.green},
    {'value': '00ffff', 'color': Colors.cyan},
    {'value': '0099ff', 'color': Colors.blue},
    {'value': 'ff00ff', 'color': Colors.purple},
  ];

  static const List<Map<String, dynamic>> _fontSizeOptions = [
    {'value': '18px', 'label': '小'},
    {'value': '25px', 'label': '中'},
    {'value': '36px', 'label': '大'},
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final String msg = _textController.text;
    if (msg.isEmpty) {
      SmartDialog.showToast('弹幕内容不能为空');
      return;
    } else if (msg.length > 100) {
      SmartDialog.showToast('弹幕内容不能超过100个字符');
      return;
    }
    setState(() {
      _isSending = true;
    });
    try {
      await widget.onSend(
        vid: widget.vid,
        text: msg,
        time: widget.currentTime,
        mode: _danmakuMode,
        color: _danmakuColor,
        fontSize: _danmakuFontSize,
      );
      SmartDialog.showToast('发送成功');
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      SmartDialog.showToast('发送失败：${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: keyboardHeight > 0 ? keyboardHeight : bottomPadding,
      ),
      duration: const Duration(milliseconds: 100),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '发送弹幕',
                    style: theme.textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      foregroundColor: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
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
                        controller: _textController,
                        maxLines: 3,
                        minLines: 1,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: '发一条弹幕喵~',
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
                    onPressed: _isSending ? null : _handleSend,
                    icon: _isSending
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '弹幕类型',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: _modeOptions.map((option) {
                  final isSelected = _danmakuMode == option['value'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            option['icon'] as IconData,
                            size: 16,
                            color: isSelected
                                ? theme.colorScheme.onSecondaryContainer
                                : theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(option['label'] as String),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _danmakuMode = option['value'] as String;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Text(
                '弹幕颜色',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _colorOptions.map((option) {
                  final isSelected = _danmakuColor == option['value'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _danmakuColor = option['value'] as String;
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: option['color'] as Color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 18,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Text(
                '字体大小',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: _fontSizeOptions.map((option) {
                  final isSelected = _danmakuFontSize == option['value'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(option['label'] as String),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _danmakuFontSize = option['value'] as String;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}