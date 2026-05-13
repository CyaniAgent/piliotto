enum BottomControlType {
  pre,
  playOrPause,
  next,
  time,
  space,
  episode,
  fit,
  speed,
  fullscreen,
  custom,
}

extension BottomControlTypeExtension on BottomControlType {
  static const Map<BottomControlType, String> _descriptions = {
    BottomControlType.pre: '上一集',
    BottomControlType.playOrPause: '播放/暂停',
    BottomControlType.next: '下一集',
    BottomControlType.time: '时间进度',
    BottomControlType.space: '空白占位',
    BottomControlType.episode: '选集',
    BottomControlType.fit: '画面比例',
    BottomControlType.speed: '播放速度',
    BottomControlType.fullscreen: '全屏切换',
    BottomControlType.custom: '自定义',
  };

  static const Map<String, BottomControlType> _codeToType = {
    'pre': BottomControlType.pre,
    'playOrPause': BottomControlType.playOrPause,
    'next': BottomControlType.next,
    'time': BottomControlType.time,
    'space': BottomControlType.space,
    'episode': BottomControlType.episode,
    'fit': BottomControlType.fit,
    'speed': BottomControlType.speed,
    'fullscreen': BottomControlType.fullscreen,
    'custom': BottomControlType.custom,
  };

  static const Map<BottomControlType, String> _typeToCode = {
    BottomControlType.pre: 'pre',
    BottomControlType.playOrPause: 'playOrPause',
    BottomControlType.next: 'next',
    BottomControlType.time: 'time',
    BottomControlType.space: 'space',
    BottomControlType.episode: 'episode',
    BottomControlType.fit: 'fit',
    BottomControlType.speed: 'speed',
    BottomControlType.fullscreen: 'fullscreen',
    BottomControlType.custom: 'custom',
  };

  String get description => _descriptions[this] ?? '未知';

  String get code => _typeToCode[this] ?? 'unknown';

  static BottomControlType? fromCode(String? code) {
    if (code == null || code.isEmpty) return null;
    return _codeToType[code];
  }

  static List<BottomControlType> fromCodeList(List<String>? codes) {
    if (codes == null || codes.isEmpty) return [];
    return codes
        .map((code) => fromCode(code))
        .whereType<BottomControlType>()
        .toList();
  }

  static List<String> toCodeList(List<BottomControlType>? types) {
    if (types == null || types.isEmpty) return [];
    return types.map((type) => type.code).toList();
  }

  bool get requiresCallback {
    switch (this) {
      case BottomControlType.episode:
      case BottomControlType.custom:
        return true;
      default:
        return false;
    }
  }

  bool get isImplemented {
    switch (this) {
      case BottomControlType.pre:
      case BottomControlType.next:
        return false;
      default:
        return true;
    }
  }
}
