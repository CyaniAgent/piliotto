import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:piliotto/utils/storage.dart';

import 'package:piliotto/models/common/nav_bar_config.dart';

class NavigationBarSetPage extends StatefulWidget {
  const NavigationBarSetPage({super.key});

  @override
  State<NavigationBarSetPage> createState() => _NavigationbarSetPageState();
}

class _NavigationbarSetPageState extends State<NavigationBarSetPage> {
  late List defaultNavTabs;
  late List<int> navBarSort;

  @override
  void initState() {
    super.initState();
    defaultNavTabs = defaultNavigationBars;
    try {
      navBarSort =
          GStrorage.setting.get(SettingBoxKey.navBarSort, defaultValue: [0, 1, 3]);
    } catch (_) {
      navBarSort = [0, 1, 3];
    }

    // 自动添加新页面到导航栏
    for (var item in defaultNavigationBars) {
      if (!navBarSort.contains(item['id'])) {
        navBarSort.add(item['id']);
      }
    }

    // 移除不存在的页面ID
    navBarSort.removeWhere(
        (id) => !defaultNavigationBars.any((item) => item['id'] == id));

    // 对 tabData 进行排序
    defaultNavTabs.sort((a, b) {
      int indexA = navBarSort.indexOf(a['id']);
      int indexB = navBarSort.indexOf(b['id']);

      // 如果类型在 sortOrder 中不存在，则放在末尾
      if (indexA == -1) indexA = navBarSort.length;
      if (indexB == -1) indexB = navBarSort.length;

      return indexA.compareTo(indexB);
    });
  }

  void saveEdit() {
    List<int> sortedTabbar = defaultNavTabs
        .where((i) => navBarSort.contains(i['id']))
        .map<int>((i) => i['id'])
        .toList();
    try {
      GStrorage.setting.put(SettingBoxKey.navBarSort, sortedTabbar);
    } catch (_) {}
    SmartDialog.showToast('保存成功，下次启动时生效');
  }

  void onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final tabsItem = defaultNavTabs.removeAt(oldIndex);
      defaultNavTabs.insert(newIndex, tabsItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    final listTiles = [
      for (int i = 0; i < defaultNavTabs.length; i++) ...[
        CheckboxListTile(
          key: Key(defaultNavTabs[i]['label']),
          value: navBarSort.contains(defaultNavTabs[i]['id']),
          onChanged: (bool? newValue) {
            int tabTypeId = defaultNavTabs[i]['id'];
            if (!newValue!) {
              navBarSort.remove(tabTypeId);
            } else {
              navBarSort.add(tabTypeId);
            }
            setState(() {});
          },
          title: Text(defaultNavTabs[i]['label']),
          secondary: const Icon(Icons.drag_indicator_rounded),
        )
      ]
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navbar编辑'),
        actions: [
          TextButton(onPressed: () => saveEdit(), child: const Text('保存')),
          const SizedBox(width: 12)
        ],
      ),
      body: ReorderableListView(
        onReorder: onReorder,
        physics: const NeverScrollableScrollPhysics(),
        footer: SizedBox(
          height: MediaQuery.of(context).padding.bottom + 30,
        ),
        children: listTiles,
      ),
    );
  }
}
