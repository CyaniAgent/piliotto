import 'package:flutter/material.dart';
import 'package:piliotto/models/common/reply_sort_type.dart';
import 'package:piliotto/pages/setting/widgets/select_dialog.dart';
import 'package:piliotto/utils/storage.dart';

import 'widgets/switch_item.dart';

class ExtraSetting extends StatefulWidget {
  const ExtraSetting({super.key});

  @override
  State<ExtraSetting> createState() => _ExtraSettingState();
}

class _ExtraSettingState extends State<ExtraSetting> {
  late dynamic defaultReplySort;

  @override
  void initState() {
    super.initState();
    try {
      defaultReplySort =
          GStrorage.setting.get(SettingBoxKey.replySortType, defaultValue: 0);
    } catch (_) {
      defaultReplySort = 0;
    }
    if (defaultReplySort == 2) {
      try {
        GStrorage.setting.put(SettingBoxKey.replySortType, 0);
      } catch (_) {}
      defaultReplySort = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = Theme.of(context).textTheme.titleMedium!;
    TextStyle subTitleStyle = Theme.of(context)
        .textTheme
        .labelMedium!
        .copyWith(color: Theme.of(context).colorScheme.outline);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          '其他设置',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: ListView(
        children: [
          const SetSwitchItem(
            title: '相关视频推荐',
            subTitle: '视频详情页推荐相关视频',
            setKey: SettingBoxKey.enableRelatedVideo,
            defaultVal: true,
          ),
          ListTile(
            dense: false,
            title: Text('评论展示', style: titleStyle),
            subtitle: Text(
              '当前优先展示「${ReplySortType.values[defaultReplySort].titles}」',
              style: subTitleStyle,
            ),
            onTap: () async {
              int? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<int>(
                      title: '评论展示',
                      value: defaultReplySort,
                      values: ReplySortType.values.map((e) {
                        return {'title': e.titles, 'value': e.index};
                      }).toList());
                },
              );
              if (result != null) {
                defaultReplySort = result;
                try {
                  GStrorage.setting.put(SettingBoxKey.replySortType, result);
                } catch (_) {}
                setState(() {});
              }
            },
          ),
          const SetSwitchItem(
            title: '检查更新',
            subTitle: '每次启动时检查是否需要更新',
            setKey: SettingBoxKey.autoUpdate,
            defaultVal: false,
          ),
        ],
      ),
    );
  }
}
