import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:piliotto/ottohub/api/models/video.dart';
import 'package:piliotto/common/constants.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/utils/download.dart';

Future<dynamic> imageSaveDialog(BuildContext context, dynamic videoItem, Function closeFn) {
  final double imgWidth =
      MediaQuery.sizeOf(context).width - StyleString.safeSpace * 2;
  return SmartDialog.show(
    animationType: SmartAnimationType.centerScale_otherSlide,
    builder: (context) => Container(
      margin: const EdgeInsets.symmetric(horizontal: StyleString.safeSpace),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              NetworkImgLayer(
                width: imgWidth,
                height: imgWidth / StyleString.aspectRatio,
                src: videoItem is Video
                    ? videoItem.coverUrl
                    : (videoItem.pic! as String),
                quality: 100,
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20))),
                  child: IconButton(
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(EdgeInsets.zero),
                    ),
                    onPressed: () => closeFn(),
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    videoItem.title! as String,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: '保存封面图',
                  onPressed: () async {
                    String imageUrl;
                    if (videoItem is Video) {
                      imageUrl = videoItem.coverUrl;
                    } else if (videoItem.pic != null) {
                      imageUrl = videoItem.pic as String;
                    } else {
                      imageUrl = videoItem.cover as String;
                    }
                    bool saveStatus = await DownloadUtils.downloadImg(imageUrl);
                    // 保存成功，自动关闭弹窗
                    if (saveStatus) {
                      closeFn();
                    }
                  },
                  icon: const Icon(Icons.download, size: 20),
                )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
