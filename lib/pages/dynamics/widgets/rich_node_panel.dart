import 'package:flutter/material.dart';

InlineSpan richNode(item, context) {
  final spacer = _VerticalSpaceSpan(0.0);
  try {
    final desc = item.modules?.moduleDynamic?.desc;
    if (desc == null) return spacer;

    final String? title = desc.title;
    final String? text = desc.text;

    if ((title == null || title.isEmpty) && (text == null || text.isEmpty)) {
      return spacer;
    }

    List<InlineSpan> spanChilds = [];

    if (title != null && title.isNotEmpty) {
      spanChilds.add(
        TextSpan(
          text: title,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontWeight: FontWeight.bold, height: 1.4),
        ),
      );
      if (text != null && text.isNotEmpty) {
        spanChilds.add(const TextSpan(text: '\n\n'));
      }
    }

    if (text != null && text.isNotEmpty) {
      spanChilds.add(
        TextSpan(text: text, style: const TextStyle(height: 1.65)),
      );
    }

    return TextSpan(children: spanChilds);
  } catch (err) {
    return spacer;
  }
}

class _VerticalSpaceSpan extends WidgetSpan {
  _VerticalSpaceSpan(double height)
      : super(child: SizedBox(height: height, width: double.infinity));
}
