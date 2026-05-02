import 'dart:io';

import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:piliotto/utils/storage.dart';

void disableBatteryOpt() async {
  if (!Platform.isAndroid) {
    return;
  }
  bool isDisableBatteryOptLocal = false;
  try {
    isDisableBatteryOptLocal =
        GStrorage.localCache.get('isDisableBatteryOptLocal', defaultValue: false);
  } catch (_) {}
  if (!isDisableBatteryOptLocal) {
    final isBatteryOptimizationDisabled =
        await DisableBatteryOptimization.isBatteryOptimizationDisabled;
    if (isBatteryOptimizationDisabled == false) {
      final hasDisabled = await DisableBatteryOptimization
          .showDisableBatteryOptimizationSettings();
      try {
        GStrorage.localCache.put('isDisableBatteryOptLocal', hasDisabled == true);
      } catch (_) {}
    }
  }

  bool isManufacturerBatteryOptimizationDisabled = false;
  try {
    isManufacturerBatteryOptimizationDisabled = GStrorage.localCache
        .get('isManufacturerBatteryOptimizationDisabled', defaultValue: false);
  } catch (_) {}
  if (!isManufacturerBatteryOptimizationDisabled) {
    final isManBatteryOptimizationDisabled = await DisableBatteryOptimization
        .isManufacturerBatteryOptimizationDisabled;
    if (isManBatteryOptimizationDisabled == false) {
      final hasDisabled = await DisableBatteryOptimization
          .showDisableManufacturerBatteryOptimizationSettings(
        "当前设备可能有额外的电池优化",
        "按照步骤操作以禁用电池优化，以保证应用在后台正常运行",
      );
      try {
        GStrorage.localCache.put(
            'isManufacturerBatteryOptimizationDisabled', hasDisabled == true);
      } catch (_) {}
    }
  }
}
