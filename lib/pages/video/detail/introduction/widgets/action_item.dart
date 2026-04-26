import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/constants.dart';
import 'package:piliotto/utils/feed_back.dart';

class ActionItem extends StatelessWidget {
  final dynamic icon;
  final dynamic selectIcon;
  final Function? onTap;
  final Function? onLongPress;
  final String? text;
  final bool selectStatus;

  const ActionItem({
    super.key,
    this.icon,
    this.selectIcon,
    this.onTap,
    this.onLongPress,
    this.text,
    this.selectStatus = false,
  });

  Widget _buildIcon(dynamic iconData, Color color) {
    if (iconData is FaIconData) {
      return FaIcon(
        iconData,
        color: color,
        size: 20,
      );
    } else if (iconData is Icon) {
      return Icon(
        iconData.icon,
        color: color,
        size: 20,
      );
    } else if (iconData is IconData) {
      return Icon(
        iconData,
        color: color,
        size: 20,
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {
        feedBack(),
        onTap!(),
      },
      onLongPress: () => {
        if (onLongPress != null) {onLongPress!()}
      },
      borderRadius: StyleString.mdRadius,
      child: SizedBox(
        width: (Get.size.width - 24) / 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: _buildIcon(
                selectStatus
                    ? (selectIcon ?? icon)
                    : icon,
                selectStatus
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              text ?? '',
              style: TextStyle(
                color:
                    selectStatus ? Theme.of(context).colorScheme.primary : null,
                fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
