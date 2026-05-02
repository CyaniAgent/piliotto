import 'package:piliotto/models/user/info.dart';
import 'package:piliotto/plugin/pl_player/models/play_repeat.dart';
import 'package:piliotto/plugin/pl_player/models/play_speed.dart';
import 'package:piliotto/utils/storage.dart';
import '../models/common/index.dart';

class GlobalDataCache {
  late int imgQuality;
  late FullScreenGestureMode fullScreenGestureMode;
  late bool enablePlayerControlAnimation;
  late List<String> actionTypeSort;

  /// 播放器相关
  // 弹幕开关
  late bool isOpenDanmu;
  // 弹幕屏蔽类型
  late List<dynamic> blockTypes;
  // 弹幕展示区域
  late double showArea;
  // 弹幕透明度
  late double opacityVal;
  // 弹幕字体大小
  late double fontSizeVal;
  // 弹幕显示时间
  late double danmakuDurationVal;
  // 弹幕描边宽度
  late double strokeWidth;
  // 播放器循环模式
  late PlayRepeat playRepeat;
  // 播放器默认播放速度
  late double playbackSpeed;
  // 播放器自动长按速度
  late bool enableAutoLongPressSpeed;
  // 播放器长按速度
  late double longPressSpeed;
  // 播放器速度列表
  late List<double> speedsList;
  // 用户信息
  UserInfoData? userInfo;

  // 私有构造函数
  GlobalDataCache._();

  // 单例实例
  static final GlobalDataCache _instance = GlobalDataCache._();

  // 获取全局实例
  factory GlobalDataCache() => _instance;

  // 异步初始化方法
  Future<void> initialize() async {
    try {
      imgQuality = await GStrorage.setting
          .get(SettingBoxKey.defaultPicQa, defaultValue: 10);
      fullScreenGestureMode = FullScreenGestureMode.values[GStrorage.setting
          .get(SettingBoxKey.fullScreenGestureMode,
              defaultValue: FullScreenGestureMode.values.last.index) as int];
      enablePlayerControlAnimation = GStrorage.setting
          .get(SettingBoxKey.enablePlayerControlAnimation, defaultValue: true);
      actionTypeSort = await GStrorage.setting.get(SettingBoxKey.actionTypeSort,
          defaultValue: ['like', 'coin', 'collect', 'watchLater', 'share']);

      isOpenDanmu = await GStrorage.setting
          .get(SettingBoxKey.enableShowDanmaku, defaultValue: true);
      blockTypes = await GStrorage.localCache
          .get(LocalCacheKey.danmakuBlockType, defaultValue: []);
      showArea = await GStrorage.localCache
          .get(LocalCacheKey.danmakuShowArea, defaultValue: 0.5);
      opacityVal = await GStrorage.localCache
          .get(LocalCacheKey.danmakuOpacity, defaultValue: 1.0);
      fontSizeVal = await GStrorage.localCache
          .get(LocalCacheKey.danmakuFontScale, defaultValue: 1.0);
      danmakuDurationVal = await GStrorage.localCache
          .get(LocalCacheKey.danmakuDuration, defaultValue: 4.0);
      strokeWidth = await GStrorage.localCache
          .get(LocalCacheKey.strokeWidth, defaultValue: 1.5);

      var defaultPlayRepeat = await GStrorage.video
          .get(VideoBoxKey.playRepeat, defaultValue: PlayRepeat.pause.value);
      playRepeat = PlayRepeat.values
          .toList()
          .firstWhere((e) => e.value == defaultPlayRepeat);
      playbackSpeed = await GStrorage.video
          .get(VideoBoxKey.playSpeedDefault, defaultValue: 1.0);
      enableAutoLongPressSpeed = await GStrorage.setting
          .get(SettingBoxKey.enableAutoLongPressSpeed, defaultValue: false);
      if (!enableAutoLongPressSpeed) {
        longPressSpeed = await GStrorage.video
            .get(VideoBoxKey.longPressSpeedDefault, defaultValue: 2.0);
      } else {
        longPressSpeed = 2.0;
      }
      speedsList = List<double>.from(await GStrorage.video
          .get(VideoBoxKey.customSpeedsList, defaultValue: <double>[]));
      final List<double> playSpeedSystem = await GStrorage.video
          .get(VideoBoxKey.playSpeedSystem, defaultValue: playSpeed);
      speedsList.addAll(playSpeedSystem);

      userInfo = GStrorage.userInfo.get('userInfoCache');
    } catch (_) {
      // 使用默认值
      imgQuality = 10;
      fullScreenGestureMode = FullScreenGestureMode.values.last;
      enablePlayerControlAnimation = true;
      actionTypeSort = ['like', 'coin', 'collect', 'watchLater', 'share'];
      isOpenDanmu = true;
      blockTypes = [];
      showArea = 0.5;
      opacityVal = 1.0;
      fontSizeVal = 1.0;
      danmakuDurationVal = 4.0;
      strokeWidth = 1.5;
      playRepeat = PlayRepeat.pause;
      playbackSpeed = 1.0;
      enableAutoLongPressSpeed = false;
      longPressSpeed = 2.0;
      speedsList = List<double>.from(playSpeed);
    }
  }
}
