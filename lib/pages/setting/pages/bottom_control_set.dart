import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/plugin/pl_player/models/bottom_control_type.dart';
import 'package:piliotto/utils/storage.dart';

class BottomControlSetPage extends StatefulWidget {
  const BottomControlSetPage({super.key});

  @override
  State<BottomControlSetPage> createState() => _BottomControlSetPageState();
}

class _BottomControlSetPageState extends State<BottomControlSetPage>
    with SingleTickerProviderStateMixin {
  final Box _videoStorage = GStrorage.video;
  late TabController _tabController;
  
  late List<BottomControlType> _halfScreenList;
  late List<BottomControlType> _fullScreenList;
  
  static const List<BottomControlType> _defaultHalfScreenList = [
    BottomControlType.playOrPause,
    BottomControlType.time,
    BottomControlType.space,
    BottomControlType.fit,
    BottomControlType.fullscreen,
  ];
  
  static const List<BottomControlType> _defaultFullScreenList = [
    BottomControlType.playOrPause,
    BottomControlType.time,
    BottomControlType.space,
    BottomControlType.episode,
    BottomControlType.fit,
    BottomControlType.speed,
    BottomControlType.fullscreen,
  ];
  
  static const List<BottomControlType> _availableButtons = [
    BottomControlType.playOrPause,
    BottomControlType.time,
    BottomControlType.space,
    BottomControlType.episode,
    BottomControlType.fit,
    BottomControlType.speed,
    BottomControlType.fullscreen,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLists();
  }

  void _loadLists() {
    final halfScreenCodes = _videoStorage
        .get(VideoBoxKey.halfScreenBottomList)?.cast<String>();
    final fullScreenCodes = _videoStorage
        .get(VideoBoxKey.fullScreenBottomList)?.cast<String>();
    
    _halfScreenList = BottomControlTypeExtension.fromCodeList(halfScreenCodes);
    if (_halfScreenList.isEmpty) {
      _halfScreenList = List.from(_defaultHalfScreenList);
    }
    
    _fullScreenList = BottomControlTypeExtension.fromCodeList(fullScreenCodes);
    if (_fullScreenList.isEmpty) {
      _fullScreenList = List.from(_defaultFullScreenList);
    }
  }

  void _saveLists() {
    _videoStorage.put(
      VideoBoxKey.halfScreenBottomList,
      BottomControlTypeExtension.toCodeList(_halfScreenList),
    );
    _videoStorage.put(
      VideoBoxKey.fullScreenBottomList,
      BottomControlTypeExtension.toCodeList(_fullScreenList),
    );
  }

  void _resetToDefault(int tabIndex) {
    setState(() {
      if (tabIndex == 0) {
        _halfScreenList = List.from(_defaultHalfScreenList);
      } else {
        _fullScreenList = List.from(_defaultFullScreenList);
      }
    });
    _saveLists();
  }

  void _addButton(int tabIndex, BottomControlType button) {
    setState(() {
      _getList(tabIndex).add(button);
    });
    _saveLists();
  }

  void _removeButton(int tabIndex, int index) {
    final list = _getList(tabIndex);
    if (index >= 0 && index < list.length) {
      setState(() {
        list.removeAt(index);
      });
      _saveLists();
    }
  }

  void _reorderButton(int tabIndex, int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final list = _getList(tabIndex);
      if (oldIndex >= 0 && oldIndex < list.length) {
        final item = list.removeAt(oldIndex);
        list.insert(newIndex, item);
      }
    });
    _saveLists();
  }

  List<BottomControlType> _getList(int tabIndex) =>
      tabIndex == 0 ? _halfScreenList : _fullScreenList;

  void _showAddButtonDialog(int tabIndex) {
    final currentList = _getList(tabIndex);
    final availableToAdd = _availableButtons
        .where((btn) => !currentList.contains(btn))
        .toList();
    
    if (availableToAdd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已添加所有可用按钮')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '添加按钮',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableToAdd.map((btn) {
                  return ActionChip(
                    label: Text(btn.description),
                    onPressed: () {
                      _addButton(tabIndex, btn);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        centerTitle: false,
        title: Text(
          '底部按钮设置',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '半屏'),
            Tab(text: '全屏'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _resetToDefault(_tabController.index),
            child: const Text('重置'),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildButtonList(0),
          _buildButtonList(1),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddButtonDialog(_tabController.index),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildButtonList(int tabIndex) {
    final list = _getList(tabIndex);
    
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '暂无按钮',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
            const SizedBox(height: 8),
            Text(
              '点击右下角按钮添加',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: list.length,
      onReorder: (oldIndex, newIndex) =>
          _reorderButton(tabIndex, oldIndex, newIndex),
      itemBuilder: (context, index) {
        final button = list[index];
        return ListTile(
          key: ValueKey('${tabIndex}_$index'),
          title: Text(button.description),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _removeButton(tabIndex, index),
              ),
              const Icon(Icons.drag_handle),
            ],
          ),
        );
      },
    );
  }
}
