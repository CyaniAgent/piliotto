import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NoData extends StatelessWidget {
  const NoData({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.iconSize,
    this.showRefreshButton = false,
    this.onRefresh,
  });

  final String? title;
  final String? subtitle;
  final Widget? icon;
  final double? iconSize;
  final bool showRefreshButton;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final bool shouldShowRefreshButton = showRefreshButton || onRefresh != null;

    return SizedBox(
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon ??
              SvgPicture.asset(
                "assets/images/error.svg",
                height: iconSize ?? 200,
              ),
          const SizedBox(height: 20),
          Text(
            title ?? '没有数据',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
          ],
          if (shouldShowRefreshButton) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('刷新'),
            ),
          ],
        ],
      ),
    );
  }
}
