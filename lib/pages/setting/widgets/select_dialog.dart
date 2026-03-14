import 'package:flutter/material.dart';

class SelectDialog<T> extends StatefulWidget {
  final T value;
  final String title;
  final List<dynamic> values;
  const SelectDialog(
      {super.key,
      required this.value,
      required this.values,
      required this.title});

  @override
  SelectDialogState<T> createState() => SelectDialogState<T>();
}

class SelectDialogState<T> extends State<SelectDialog<T>> {
  late T _tempValue;

  @override
  void initState() {
    super.initState();
    _tempValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = Theme.of(context).textTheme.titleMedium!;

    return AlertDialog(
      title: Text(widget.title),
      contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
      content: StatefulBuilder(builder: (context, StateSetter setState) {
        return SingleChildScrollView(
          child: RadioGroup<T>(
            groupValue: _tempValue,
            onChanged: (T? value) {
              if (value != null) {
                setState(() {
                  _tempValue = value;
                });
                Navigator.pop(context, _tempValue);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i in widget.values) ...[
                  RadioListTile<T>(
                    value: i['value'],
                    title: Text(i['title'], style: titleStyle),
                  ),
                ]
              ],
            ),
          ),
        );
      }),
    );
  }
}
