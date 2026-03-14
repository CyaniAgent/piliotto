import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/utils/extension.dart';
import 'package:piliotto/utils/global_data_cache.dart';
import '../../utils/storage.dart';
import '../constants.dart';

Box<dynamic> setting = GStrorage.setting;

class NetworkImgLayer extends StatelessWidget {
  const NetworkImgLayer({
    super.key,
    this.src,
    required this.width,
    required this.height,
    this.type,
    this.fadeOutDuration,
    this.fadeInDuration,
    // 图片质量 默认1%
    this.quality,
    this.origAspectRatio,
  });

  final String? src;
  final double width;
  final double height;
  final String? type;
  final Duration? fadeOutDuration;
  final Duration? fadeInDuration;
  final int? quality;
  final double? origAspectRatio;

  @override
  Widget build(BuildContext context) {
    final int defaultImgQuality = GlobalDataCache().imgQuality;
    if (src == '' || src == null) {
      return placeholder(context);
    }
    // 检查是否是Ottohub的图片URL，如果是则不添加后缀
    String imageUrl;
    if (src!.contains('ottohub.cn')) {
      imageUrl = src!.startsWith('//') ? 'https:${src!}' : src!;
    } else {
      imageUrl = '${src!.startsWith('//') ? 'https:${src!}' : src!}@${quality ?? defaultImgQuality}q.webp';
    }
    int? memCacheWidth, memCacheHeight;
    double aspectRatio = (width / height).toDouble();

    void setMemCacheSizes() {
      if (aspectRatio > 1) {
        memCacheHeight = height.cacheSize(context);
      } else if (aspectRatio < 1) {
        memCacheWidth = width.cacheSize(context);
      } else {
        if (origAspectRatio != null && origAspectRatio! > 1) {
          memCacheWidth = width.cacheSize(context);
        } else if (origAspectRatio != null && origAspectRatio! < 1) {
          memCacheHeight = height.cacheSize(context);
        } else {
          memCacheWidth = width.cacheSize(context);
          memCacheHeight = height.cacheSize(context);
        }
      }
    }

    setMemCacheSizes();

    if (memCacheWidth == null && memCacheHeight == null) {
      memCacheWidth = width.toInt();
    }

    return src != '' && src != null
        ? ClipRRect(
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(
              type == 'avatar'
                  ? 50
                  : type == 'emote'
                      ? 0
                      : StyleString.imgRadius.x,
            ),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: width,
              height: height,
              memCacheWidth: memCacheWidth,
              memCacheHeight: memCacheHeight,
              fit: BoxFit.cover,
              fadeOutDuration:
                  fadeOutDuration ?? const Duration(milliseconds: 120),
              fadeInDuration:
                  fadeInDuration ?? const Duration(milliseconds: 120),
              filterQuality: FilterQuality.low,
              errorWidget: (BuildContext context, String url, Object error) =>
                  placeholder(context),
              placeholder: (BuildContext context, String url) =>
                  placeholder(context),
            ),
          )
        : placeholder(context);
  }

  Widget placeholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.onInverseSurface.withValues(alpha: 0.4 * 255),
        borderRadius: BorderRadius.circular(type == 'avatar'
            ? 50
            : type == 'emote'
                ? 0
                : StyleString.imgRadius.x),
      ),
      child: type == 'bg'
          ? const SizedBox()
          : Center(
              child: type == 'avatar'
                  ? Icon(
                      Icons.person,
                      size: width * 0.6,
                      color: colorScheme.outline.withValues(alpha: 0.5),
                    )
                  : SizedBox(
                      width: width * 0.3 > 24 ? 24.0 : width * 0.3,
                      height: height * 0.3 > 24 ? 24.0 : height * 0.3,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.outline.withValues(alpha: 0.5),
                      ),
                    ),
            ),
    );
  }
}
