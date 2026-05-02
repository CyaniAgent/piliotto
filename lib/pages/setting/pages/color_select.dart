import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:piliotto/pages/setting/provider.dart';

class ColorSelectPage extends ConsumerStatefulWidget {
  const ColorSelectPage({super.key});

  @override
  ConsumerState<ColorSelectPage> createState() => _ColorSelectPageState();
}

class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}

List<Item> generateItems(int count) {
  return List<Item>.generate(count, (int index) {
    return Item(
      headerValue: 'Panel $index',
      expandedValue: 'This is item number $index',
    );
  });
}

class _ColorSelectPageState extends ConsumerState<ColorSelectPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(colorSelectProvider);
    final notifier = ref.read(colorSelectProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('选择应用主题'),
      ),
      body: ListView(
        children: [
          Column(
            children: [
              RadioGroup<int>(
                onChanged: (int? value) {
                  if (value != null) {
                    notifier.setType(value);
                  }
                },
                groupValue: state.type,
                child: const Column(
                  children: [
                    RadioListTile<int>(
                      value: 0,
                      title: Text('动态取色'),
                    ),
                    RadioListTile<int>(
                      value: 1,
                      title: Text('指定颜色'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AnimatedOpacity(
            opacity: state.type == 1 ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 22,
                runSpacing: 18,
                children: [
                  ...state.colorThemes.map(
                    (e) {
                      final index = state.colorThemes.indexOf(e);
                      return GestureDetector(
                        onTap: () {
                          notifier.setCurrentColor(index);
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color:
                                    e['color'].withValues(alpha: 0.8 * 255),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  width: 2,
                                  color: state.currentColor == index
                                      ? Colors.black
                                      : e['color']
                                          .withValues(alpha: 0.8 * 255),
                                ),
                              ),
                              child: AnimatedOpacity(
                                opacity:
                                    state.currentColor == index ? 1 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: const Icon(
                                  Icons.done,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              e['label'],
                              style: TextStyle(
                                fontSize: 12,
                                color: state.currentColor != index
                                    ? Theme.of(context).colorScheme.outline
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
