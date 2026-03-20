import 'package:flutter/material.dart';

import '../../pages/dynamics/index.dart';
import '../../pages/home/index.dart';
import '../../pages/mine/index.dart';

List defaultNavigationBars = [
  {
    'id': 0,
    'icon': const Icon(
      Icons.home_outlined,
      size: 21,
    ),
    'selectIcon': const Icon(
      Icons.home,
      size: 21,
    ),
    'label': "首页",
    'count': 0,
    'page': const HomePage(),
  },
  {
    'id': 1,
    'icon': const Icon(
      Icons.motion_photos_on_outlined,
      size: 21,
    ),
    'selectIcon': const Icon(
      Icons.motion_photos_on,
      size: 21,
    ),
    'label': "动态",
    'count': 0,
    'page': const DynamicsPage(),
  },
  {
    'id': 3,
    'icon': const Icon(
      Icons.person_outline,
      size: 21,
    ),
    'selectIcon': const Icon(
      Icons.person,
      size: 21,
    ),
    'label': "我的",
    'count': 0,
    'page': const MinePage(),
  },
];
