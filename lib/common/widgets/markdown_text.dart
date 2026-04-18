import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:piliotto/utils/utils.dart';

class MarkdownText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool selectable;
  final void Function(String)? onLinkTap;
  final bool enableTimeJump;
  final void Function(Duration)? onTimeJump;
  final Map<String, int>? atNameToMid;

  const MarkdownText({
    super.key,
    required this.text,
    this.style,
    this.maxLines,
    this.overflow,
    this.selectable = true,
    this.onLinkTap,
    this.enableTimeJump = false,
    this.onTimeJump,
    this.atNameToMid,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final defaultStyle = style ?? theme.textTheme.bodyMedium;

    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    final processedText = _processText(text);
    final hasHtml = _hasHtmlTags(processedText);
    final hasMarkdown = _hasMarkdownSyntax(processedText);

    if (hasHtml) {
      return Html(
        data: processedText,
        style: {
          'body': Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
            fontSize: FontSize(defaultStyle?.fontSize ?? 14),
            fontWeight: defaultStyle?.fontWeight,
            color: defaultStyle?.color,
            lineHeight: const LineHeight(1.6),
          ),
          'a': Style(
            color: colorScheme.primary,
            textDecoration: TextDecoration.underline,
          ),
          'strong': Style(
            fontWeight: FontWeight.bold,
          ),
          'em': Style(
            fontStyle: FontStyle.italic,
          ),
          'br': Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
          ),
        },
        onLinkTap: (url, attributes, element) {
          if (url == null) return;
          if (enableTimeJump && onTimeJump != null && _isTimeFormat(url)) {
            onTimeJump!(Duration(seconds: Utils.duration(url)));
            return;
          }
          if (onLinkTap != null) {
            onLinkTap!(url);
          } else {
            Get.toNamed('/webview', parameters: {
              'url': url,
              'type': 'url',
              'pageTitle': url,
            });
          }
        },
      );
    }

    if (!hasMarkdown) {
      final textWidget = Text(
        processedText,
        style: defaultStyle,
        maxLines: maxLines,
        overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
      );

      if (selectable) {
        return SelectionArea(child: textWidget);
      }
      return textWidget;
    }

    return MarkdownBody(
      data: processedText,
      selectable: selectable,
      styleSheet: _buildStyleSheet(theme, colorScheme, defaultStyle),
      onTapLink: _handleTapLink,
    );
  }

  MarkdownStyleSheet _buildStyleSheet(
    ThemeData theme,
    ColorScheme colorScheme,
    TextStyle? defaultStyle,
  ) {
    return MarkdownStyleSheet(
      p: defaultStyle?.copyWith(height: 1.6),
      h1: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
      h2: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
      h3: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
      h4: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
      listBullet: defaultStyle?.copyWith(color: colorScheme.primary),
      blockquote: defaultStyle?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontStyle: FontStyle.italic,
      ),
      code: theme.textTheme.bodySmall?.copyWith(
        fontFamily: 'monospace',
        backgroundColor: colorScheme.surfaceContainerHighest,
      ),
      codeblockDecoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: colorScheme.primary,
            width: 4,
          ),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(left: 12),
      a: defaultStyle?.copyWith(color: colorScheme.primary),
      em: defaultStyle?.copyWith(fontStyle: FontStyle.italic),
      strong: defaultStyle?.copyWith(fontWeight: FontWeight.bold),
      del: defaultStyle?.copyWith(
        decoration: TextDecoration.lineThrough,
      ),
      listBulletPadding: const EdgeInsets.only(right: 4),
    );
  }

  void Function(String, String?, String?)? get _handleTapLink {
    return (text, href, title) {
      if (href == null) return;

      if (enableTimeJump && onTimeJump != null && _isTimeFormat(href)) {
        onTimeJump!(Duration(seconds: Utils.duration(href)));
        return;
      }

      if (onLinkTap != null) {
        onLinkTap!(href);
      } else {
        Get.toNamed('/webview', parameters: {
          'url': href,
          'type': 'url',
          'pageTitle': title ?? href,
        });
      }
    };
  }

  String _processText(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&nbsp;', ' ');
  }

  bool _hasHtmlTags(String text) {
    final htmlPatterns = [
      RegExp(r'<br\s*/?>', caseSensitive: false),
      RegExp(r'<a\s+[^>]*>', caseSensitive: false),
      RegExp(r'</a>', caseSensitive: false),
      RegExp(r'<strong>', caseSensitive: false),
      RegExp(r'</strong>', caseSensitive: false),
      RegExp(r'<em>', caseSensitive: false),
      RegExp(r'</em>', caseSensitive: false),
      RegExp(r'<b>', caseSensitive: false),
      RegExp(r'</b>', caseSensitive: false),
      RegExp(r'<i>', caseSensitive: false),
      RegExp(r'</i>', caseSensitive: false),
      RegExp(r'<p>', caseSensitive: false),
      RegExp(r'</p>', caseSensitive: false),
      RegExp(r'<div>', caseSensitive: false),
      RegExp(r'</div>', caseSensitive: false),
      RegExp(r'<span[^>]*>', caseSensitive: false),
      RegExp(r'</span>', caseSensitive: false),
    ];

    for (final pattern in htmlPatterns) {
      if (pattern.hasMatch(text)) {
        return true;
      }
    }
    return false;
  }

  bool _hasMarkdownSyntax(String text) {
    final markdownPatterns = [
      RegExp(r'\*\*.*?\*\*'),
      RegExp(r'\*[^*]+[^*]\*'),
      RegExp(r'__.*?__'),
      RegExp(r'_[^_]+_'),
      RegExp(r'~~.*?~~'),
      RegExp(r'`[^`]+`'),
      RegExp(r'^#{1,6}\s', multiLine: true),
      RegExp(r'^\s*[-*+]\s', multiLine: true),
      RegExp(r'^\s*\d+\.\s', multiLine: true),
      RegExp(r'^\s*>', multiLine: true),
      RegExp(r'\[.*?\]\(.*?\)'),
      RegExp(r'!\[.*?\]\(.*?\)'),
    ];

    for (final pattern in markdownPatterns) {
      if (pattern.hasMatch(text)) {
        return true;
      }
    }
    return false;
  }

  bool _isTimeFormat(String text) {
    return RegExp(r'^\b(?:\d+[:：])?[0-5]?[0-9][:：][0-5]?[0-9]\b$')
        .hasMatch(text);
  }
}
