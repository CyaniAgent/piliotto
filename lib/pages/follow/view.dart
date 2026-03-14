import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller.dart';
import 'widgets/follow_list.dart';

class FollowPage extends StatefulWidget {
  const FollowPage({super.key});

  @override
  State<FollowPage> createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage> {
  late String mid;
  late FollowController _followController;

  @override
  void initState() {
    super.initState();
    mid = Get.parameters['mid'] ?? '0';
    _followController = Get.put(FollowController(), tag: mid);
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
          '${_followController.name}的关注',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: const [
          SizedBox(width: 6),
        ],
      ),
      body: FollowList(ctr: _followController),
    );
  }
}
