import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/utils/storage.dart';

class FontSizeSelectPage extends StatefulWidget {
  const FontSizeSelectPage({super.key});

  @override
  State<FontSizeSelectPage> createState() => _FontSizeSelectPageState();
}

class _FontSizeSelectPageState extends State<FontSizeSelectPage> {
  List<double> list = [0.9, 0.95, 1.0, 1.05, 1.1, 1.15, 1.2, 1.25, 1.3];
  late double minsize;
  late double maxSize;
  late double currentSize;

  @override
  void initState() {
    super.initState();
    minsize = list.first;
    maxSize = list.last;
    try {
      currentSize =
          GStrorage.setting.get(SettingBoxKey.defaultTextScale, defaultValue: 1.0);
    } catch (_) {
      currentSize = 1.0;
    }
  }

  void setFontSize() {
    try {
      GStrorage.setting.put(SettingBoxKey.defaultTextScale, currentSize);
    } catch (_) {}
    Get.forceAppUpdate();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(onPressed: () => setFontSize(), child: const Text('确定')),
          const SizedBox(width: 12)
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                '当前字体大小:${currentSize == 1.0 ? '默认' : currentSize}',
                style: TextStyle(fontSize: 14 * currentSize),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).padding.bottom + 20,
            ),
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.3))),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Row(
              children: [
                const Text('小'),
                Expanded(
                  child: Slider(
                    min: minsize,
                    value: currentSize,
                    max: maxSize,
                    divisions: list.length - 1,
                    secondaryTrackValue: 1,
                    onChanged: (double val) {
                      currentSize = double.parse(val.toStringAsFixed(2));
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  '大',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
