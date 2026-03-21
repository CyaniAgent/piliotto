import 'package:flutter/material.dart';
import 'package:piliotto/api/models/message.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:piliotto/utils/utils.dart';

import '../controller.dart';

class ChatItem extends StatelessWidget {
  final Message message;
  final WhisperDetailController ctr;

  const ChatItem({
    super.key,
    required this.message,
    required this.ctr,
  });

  @override
  Widget build(BuildContext context) {
    final userInfo = GStrorage.userInfo.get('userInfoCache');
    final int currentUid = userInfo?.mid ?? 0;
    final bool isOwner = message.sender == currentUid;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isOwner ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isOwner) ...[
            NetworkImgLayer(
              width: 36,
              height: 36,
              type: 'avatar',
              src: message.senderAvatarUrl ?? '',
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isOwner
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    message.content,
                    style: TextStyle(
                      color: isOwner
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Utils.dateFormat(message.time),
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isOwner) ...[
            const SizedBox(width: 8),
            NetworkImgLayer(
              width: 36,
              height: 36,
              type: 'avatar',
              src: message.receiverAvatarUrl ?? '',
            ),
          ],
        ],
      ),
    );
  }
}
