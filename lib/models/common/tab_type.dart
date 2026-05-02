import 'package:flutter/material.dart';
import 'package:piliotto/pages/hot/index.dart';
import 'package:piliotto/pages/rcmd/index.dart';

enum TabType { rcmd, hot }

extension TabTypeDesc on TabType {
  String get description => ['推荐', '热门'][index];
  String get id => ['rcmd', 'hot'][index];
}

List tabsConfig = [
  {
    'icon': const Icon(
      Icons.thumb_up_off_alt_outlined,
      size: 15,
    ),
    'label': '推荐',
    'type': TabType.rcmd,
    'page': const RcmdPage(),
  },
  {
    'icon': const Icon(
      Icons.whatshot_outlined,
      size: 15,
    ),
    'label': '热门',
    'type': TabType.hot,
    'page': const HotPage(),
  },
];
