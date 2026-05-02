import 'package:flutter/services.dart';
import 'storage.dart';

void feedBack() {
  bool enable = false;
  try {
    enable = GStrorage.setting
        .get(SettingBoxKey.feedBackEnable, defaultValue: false) as bool;
  } catch (_) {}
  if (enable) {
    HapticFeedback.lightImpact();
  }
}
