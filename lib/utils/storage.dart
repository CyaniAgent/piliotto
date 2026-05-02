import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:piliotto/models/user/info.dart';
import 'package:piliotto/services/loggeer.dart';

class GStrorage {
  static late final Box<dynamic> _userInfo;
  static late final Box<dynamic> _historyword;
  static late final Box<dynamic> _localCache;
  static late final Box<dynamic> _setting;
  static late final Box<dynamic> _video;

  static Box<dynamic> get userInfo => _SafeBox(_userInfo, 'userInfo');
  static Box<dynamic> get historyword => _SafeBox(_historyword, 'historyword');
  static Box<dynamic> get localCache => _SafeBox(_localCache, 'localCache');
  static Box<dynamic> get setting => _SafeBox(_setting, 'setting');
  static Box<dynamic> get video => _SafeBox(_video, 'video');

  static Future<void> init() async {
    final Directory dir = await getApplicationSupportDirectory();
    final String path = dir.path;
    await Hive.initFlutter('$path/hive');
    regAdapter();
    _userInfo = await Hive.openBox(
      'userInfo',
      compactionStrategy: (int entries, int deletedEntries) {
        return deletedEntries > 2;
      },
    );
    _localCache = await Hive.openBox(
      'localCache',
      compactionStrategy: (int entries, int deletedEntries) {
        return deletedEntries > 4;
      },
    );
    _setting = await Hive.openBox('setting');
    _historyword = await Hive.openBox(
      'historyWord',
      compactionStrategy: (int entries, int deletedEntries) {
        return deletedEntries > 10;
      },
    );
    _video = await Hive.openBox('video');
  }

  static void regAdapter() {
    Hive.registerAdapter(UserInfoDataAdapter());
    Hive.registerAdapter(LevelInfoAdapter());
  }
}

class _SafeBox implements Box<dynamic> {
  final Box<dynamic> _box;
  final String _boxName;

  _SafeBox(this._box, this._boxName);

  void _logError(String operation, dynamic key, dynamic error) {
    getLogger().w('Hive[$_boxName] $operation failed (key: $key): $error');
  }

  void _logErrorSimple(String operation, dynamic error) {
    getLogger().w('Hive[$_boxName] $operation failed: $error');
  }

  @override
  dynamic get(dynamic key, {dynamic defaultValue}) {
    try {
      return _box.get(key, defaultValue: defaultValue);
    } catch (e) {
      _logError('get', key, e);
      return defaultValue;
    }
  }

  @override
  Future<void> put(dynamic key, dynamic value) async {
    try {
      await _box.put(key, value);
    } catch (e) {
      _logError('put', key, e);
    }
  }

  @override
  Future<void> delete(dynamic key) async {
    try {
      await _box.delete(key);
    } catch (e) {
      _logError('delete', key, e);
    }
  }

  @override
  bool containsKey(dynamic key) {
    try {
      return _box.containsKey(key);
    } catch (e) {
      _logError('containsKey', key, e);
      return false;
    }
  }

  @override
  Iterable<dynamic> get keys {
    try {
      return _box.keys;
    } catch (e) {
      _logErrorSimple('keys', e);
      return [];
    }
  }

  @override
  int get length {
    try {
      return _box.length;
    } catch (e) {
      _logErrorSimple('length', e);
      return 0;
    }
  }

  @override
  Map<dynamic, dynamic> toMap() {
    try {
      return _box.toMap();
    } catch (e) {
      _logErrorSimple('toMap', e);
      return {};
    }
  }

  @override
  dynamic getAt(int index) {
    try {
      return _box.getAt(index);
    } catch (e) {
      _logError('getAt', index, e);
      return null;
    }
  }

  @override
  Future<void> putAt(int index, dynamic value) async {
    try {
      await _box.putAt(index, value);
    } catch (e) {
      _logError('putAt', index, e);
    }
  }

  @override
  Future<void> deleteAt(int index) async {
    try {
      await _box.deleteAt(index);
    } catch (e) {
      _logError('deleteAt', index, e);
    }
  }

  @override
  Future<int> add(dynamic value) async {
    try {
      return await _box.add(value);
    } catch (e) {
      _logErrorSimple('add', e);
      return -1;
    }
  }

  @override
  Future<Iterable<int>> addAll(Iterable<dynamic> entries) async {
    try {
      return await _box.addAll(entries);
    } catch (e) {
      _logErrorSimple('addAll', e);
      return [];
    }
  }

  @override
  Future<void> deleteAll(Iterable<dynamic> keys) async {
    try {
      await _box.deleteAll(keys);
    } catch (e) {
      _logErrorSimple('deleteAll', e);
    }
  }

  @override
  Future<void> putAll(Map<dynamic, dynamic> entries) async {
    try {
      await _box.putAll(entries);
    } catch (e) {
      _logErrorSimple('putAll', e);
    }
  }

  @override
  bool get isEmpty => length == 0;

  @override
  bool get isNotEmpty => length > 0;

  @override
  bool get isOpen {
    try {
      return _box.isOpen;
    } catch (e) {
      _logErrorSimple('isOpen', e);
      return false;
    }
  }

  @override
  String get name => _box.name;

  @override
  String? get path => _box.path;

  @override
  Future<int> clear() async {
    try {
      return await _box.clear();
    } catch (e) {
      _logErrorSimple('clear', e);
      return 0;
    }
  }

  @override
  Future<void> compact() async {
    try {
      await _box.compact();
    } catch (e) {
      _logErrorSimple('compact', e);
    }
  }

  @override
  Future<void> close() async {
    try {
      await _box.close();
    } catch (e) {
      _logErrorSimple('close', e);
    }
  }

  @override
  Iterable<dynamic> get values {
    try {
      return _box.values;
    } catch (e) {
      _logErrorSimple('values', e);
      return [];
    }
  }

  @override
  Iterable<dynamic> valuesBetween({dynamic startKey, dynamic endKey}) {
    try {
      return _box.valuesBetween(startKey: startKey, endKey: endKey);
    } catch (e) {
      _logErrorSimple('valuesBetween', e);
      return [];
    }
  }

  @override
  dynamic keyAt(int index) {
    try {
      return _box.keyAt(index);
    } catch (e) {
      _logError('keyAt', index, e);
      return null;
    }
  }

  @override
  Future<void> deleteFromDisk() async {
    try {
      await _box.deleteFromDisk();
    } catch (e) {
      _logErrorSimple('deleteFromDisk', e);
    }
  }

  @override
  bool get lazy => _box.lazy;

  @override
  Stream<BoxEvent> watch({dynamic key}) {
    try {
      return _box.watch(key: key);
    } catch (e) {
      _logError('watch', key, e);
      return const Stream.empty();
    }
  }

  @override
  Future<void> flush() async {
    try {
      await _box.flush();
    } catch (e) {
      _logErrorSimple('flush', e);
    }
  }
}

class SettingBoxKey {
  static const String btmProgressBehavior = 'btmProgressBehavior',
      defaultVideoSpeed = 'defaultVideoSpeed',
      autoUpgradeEnable = 'autoUpgradeEnable',
      feedBackEnable = 'feedBackEnable',
      defaultVideoQa = 'defaultVideoQa',
      defaultLiveQa = 'defaultLiveQa',
      defaultAudioQa = 'defaultAudioQa',
      autoPlayEnable = 'autoPlayEnable',
      fullScreenMode = 'fullScreenMode',
      defaultDecode = 'defaultDecode',
      danmakuEnable = 'danmakuEnable',
      defaultToastOp = 'defaultToastOp',
      defaultPicQa = 'defaultPicQa',
      enableHA = 'enableHA',
      enableOnlineTotal = 'enableOnlineTotal',
      enableAutoBrightness = 'enableAutoBrightness',
      enableAutoEnter = 'enableAutoEnter',
      enableAutoExit = 'enableAutoExit',
      p1080 = 'p1080',
      enableCDN = 'enableCDN',
      autoPiP = 'autoPiP',
      enableAutoLongPressSpeed = 'enableAutoLongPressSpeed',
      enablePlayerControlAnimation = 'enablePlayerControlAnimation',
      defaultAoOutput = 'defaultAoOutput',
      enableGATMode = 'enableGATMode',
      enableQuickDouble = 'enableQuickDouble',
      enableShowDanmaku = 'enableShowDanmaku',
      enableBackgroundPlay = 'enableBackgroundPlay',
      fullScreenGestureMode = 'fullScreenGestureMode',
      blackMidsList = 'blackMidsList',
      enableRcmdDynamic = 'enableRcmdDynamic',
      defaultRcmdType = 'defaultRcmdType',
      enableSaveLastData = 'enableSaveLastData',
      minDurationForRcmd = 'minDurationForRcmd',
      minLikeRatioForRecommend = 'minLikeRatioForRecommend',
      exemptFilterForFollowed = 'exemptFilterForFollowed',
      applyFilterToRelatedVideos = 'applyFilterToRelatedVideos',
      autoUpdate = 'autoUpdate',
      replySortType = 'replySortType',
      defaultDynamicType = 'defaultDynamicType',
      enableHotKey = 'enableHotKey',
      enableQuickFav = 'enableQuickFav',
      enableWordRe = 'enableWordRe',
      enableSearchWord = 'enableSearchWord',
      enableSystemProxy = 'enableSystemProxy',
      enableAi = 'enableAi',
      defaultHomePage = 'defaultHomePage',
      enableRelatedVideo = 'enableRelatedVideo';

  static const String themeMode = 'themeMode',
      defaultTextScale = 'textScale',
      dynamicColor = 'dynamicColor',
      customColor = 'customColor',
      enableSingleRow = 'enableSingleRow',
      displayMode = 'displayMode',
      customRows = 'customRows',
      enableMYBar = 'enableMYBar',
      hideSearchBar = 'hideSearchBar',
      hideTabBar = 'hideTabBar',
      tabbarSort = 'tabbarSort',
      dynamicBadgeMode = 'dynamicBadgeMode',
      enableGradientBg = 'enableGradientBg',
      navBarSort = 'navBarSort',
      actionTypeSort = 'actionTypeSort',
      dynamicWideScreenLayout = 'dynamicWideScreenLayout',
      useDrawerForUser = 'useDrawerForUser';
}

class LocalCacheKey {
  static const String historyPause = 'historyPause',
      accessKey = 'accessKey',
      wbiKeys = 'wbiKeys',
      timeStamp = 'timeStamp',
      danmakuBlockType = 'danmakuBlockType',
      danmakuShowArea = 'danmakuShowArea',
      danmakuOpacity = 'danmakuOpacity',
      danmakuFontScale = 'danmakuFontScale',
      danmakuDuration = 'danmakuDuration',
      strokeWidth = 'strokeWidth',
      systemProxyHost = 'systemProxyHost',
      systemProxyPort = 'systemProxyPort';

  static const String isDisableBatteryOptLocal = 'isDisableBatteryOptLocal',
      isManufacturerBatteryOptimizationDisabled =
          'isManufacturerBatteryOptimizationDisabled';
}

class VideoBoxKey {
  static const String videoFit = 'videoFit',
      videoBrightness = 'videoBrightness',
      videoSpeed = 'videoSpeed',
      playRepeat = 'playRepeat',
      playSpeedSystem = 'playSpeedSystem',
      playSpeedDefault = 'playSpeedDefault',
      longPressSpeedDefault = 'longPressSpeedDefault',
      customSpeedsList = 'customSpeedsList',
      cacheVideoFit = 'cacheVideoFit';
}
