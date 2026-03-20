import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/api/models/block.dart';
import 'package:piliotto/api/services/block_service.dart';
import 'package:piliotto/common/widgets/http_error.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:piliotto/utils/utils.dart';

class BlackListPage extends StatefulWidget {
  const BlackListPage({super.key});

  @override
  State<BlackListPage> createState() => _BlackListPageState();
}

class _BlackListPageState extends State<BlackListPage> {
  final BlackListController _blackListController =
      Get.put(BlackListController());
  final ScrollController scrollController = ScrollController();
  Future? _futureBuilderFuture;
  bool _isLoadingMore = false;
  Box setting = GStrorage.setting;

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = _blackListController.queryBlacklist();
    scrollController.addListener(
      () async {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          if (!_isLoadingMore) {
            _isLoadingMore = true;
            await _blackListController.queryBlacklist(type: 'onLoad');
            _isLoadingMore = false;
          }
        }
      },
    );
  }

  @override
  void dispose() {
    List<int> blackMidsList =
        _blackListController.blackList.map<int>((e) => e.blockedId).toList();
    setting.put(SettingBoxKey.blackMidsList, blackMidsList);
    scrollController.removeListener(() {});
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
        title: Obx(
          () => Text(
            '黑名单管理 ${_blackListController.total.value == 0 ? '' : '- ${_blackListController.total.value}'}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => await _blackListController.queryBlacklist(),
        child: FutureBuilder(
          future: _futureBuilderFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              var data = snapshot.data;
              if (data['status']) {
                List<Block> list = _blackListController.blackList;
                return Obx(
                  () => list.isEmpty
                      ? CustomScrollView(
                          slivers: [
                            HttpError(errMsg: '你没有拉黑任何人哦～_～', fn: () => {})
                          ],
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: list.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              onTap: () {},
                              leading: NetworkImgLayer(
                                width: 45,
                                height: 45,
                                type: 'avatar',
                                src: list[index].avatar,
                              ),
                              title: Text(
                                list[index].username,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: Text(
                                Utils.dateFormat(list[index].createdAt),
                                maxLines: 1,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.outline),
                                overflow: TextOverflow.ellipsis,
                              ),
                              dense: true,
                              trailing: TextButton(
                                onPressed: () => _blackListController
                                    .removeBlack(list[index].blockedId),
                                child: const Text('移除'),
                              ),
                            );
                          },
                        ),
                );
              } else {
                return CustomScrollView(
                  slivers: [
                    HttpError(
                      errMsg: data['msg'],
                      fn: () => _blackListController.queryBlacklist(),
                    )
                  ],
                );
              }
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}

class BlackListController extends GetxController {
  int currentPage = 1;
  int pageSize = 20;
  RxInt total = 0.obs;
  RxList<Block> blackList = <Block>[].obs;

  Future queryBlacklist({type = 'init'}) async {
    try {
      if (type == 'init') {
        currentPage = 1;
      }
      final result = await BlockService.getBlockList(
        page: currentPage,
        pageSize: pageSize,
      );
      if (type == 'init') {
        blackList.value = result.list;
        total.value = result.total;
      } else {
        blackList.addAll(result.list);
      }
      if (result.list.isNotEmpty) {
        currentPage += 1;
      }
      return {'status': true, 'data': result};
    } catch (e) {
      return {'status': false, 'msg': e.toString()};
    }
  }

  Future removeBlack(int blockedId) async {
    try {
      await BlockService.unblockUser(blockedId: blockedId);
      blackList.removeWhere((e) => e.blockedId == blockedId);
      total.value = total.value - 1;
      SmartDialog.showToast('移除成功');
    } catch (e) {
      SmartDialog.showToast('移除失败：${e.toString()}');
    }
  }
}
