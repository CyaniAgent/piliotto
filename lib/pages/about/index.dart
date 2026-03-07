import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:piliotto/http/index.dart';
import 'package:piliotto/models/github/latest.dart';
import 'package:piliotto/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/cache_manage.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final AboutController _aboutController = Get.put(AboutController());
  String cacheSize = '';

  @override
  void initState() {
    super.initState();
    // 读取缓存占用
    getCacheSize();
  }

  Future<void> getCacheSize() async {
    final res = await CacheManage().loadApplicationCache();
    setState(() => cacheSize = res);
  }

  @override
  Widget build(BuildContext context) {
    final Color outline = Theme.of(context).colorScheme.outline;
    TextStyle subTitleStyle =
        TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.outline);
    return Scaffold(
      appBar: AppBar(
        title: Text('关于', style: Theme.of(context).textTheme.titleMedium),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              'assets/images/logo/logo_android_2.png',
              width: 150,
            ),
            Text(
              'PiliOtto',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Obx(
              () => Badge(
                isLabelVisible: _aboutController.isLoading.value
                    ? false
                    : _aboutController.isUpdate.value,
                label: const Text('New'),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                  child: FilledButton.tonal(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                onTap: () => _aboutController.githubRelease(),
                                title: const Text('Github下载'),
                              ),
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).padding.bottom +
                                          20)
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      'V${_aboutController.currentVersion.value}',
                      style: subTitleStyle.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // ListTile(
            //   onTap: () {},
            //   title: const Text('更新日志'),
            //   trailing: const Icon(
            //     Icons.arrow_forward_ios,
            //     size: 16,
            //   ),
            // ),
            ListTile(
              onTap: () => _aboutController.githubUrl(),
              title: const Text('开源地址'),
              trailing: Text(
                'github.com/CyaniAgent/piliotto',
                style: subTitleStyle,
              ),
            ),
            ListTile(
              onTap: () => _aboutController.feedback(),
              title: const Text('问题反馈'),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: outline,
              ),
            ),
            ListTile(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).padding.bottom + 20)
                      ],
                    );
                  },
                );
              },
              title: const Text('交流社区'),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: outline,
              ),
            ),
            ListTile(
              onTap: () => _aboutController.logs(),
              title: const Text('错误日志'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: outline),
            ),
            ListTile(
              onTap: () async {
                var cleanStatus = await CacheManage().clearCacheAll();
                if (cleanStatus) {
                  getCacheSize();
                }
              },
              title: const Text('清除缓存'),
              subtitle: Text('图片及网络缓存 $cacheSize', style: subTitleStyle),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20)
          ],
        ),
      ),
    );
  }
}

class AboutController extends GetxController {
  RxString currentVersion = ''.obs;
  RxString remoteVersion = ''.obs;
  late LatestDataModel remoteAppInfo;
  RxBool isUpdate = false.obs;
  RxBool isLoading = true.obs;
  late LatestDataModel data;

  @override
  void onInit() {
    super.onInit();
    // init();
    // 获取当前版本
    getCurrentApp();
    // 获取最新的版本
    getRemoteApp();
  }

  // 获取设备信息
  // Future init() async {
  //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //   if (Platform.isAndroid) {
  //     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //     print(androidInfo.supportedAbis);
  //   } else if (Platform.isIOS) {
  //     IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  //     print(iosInfo);
  //   }
  // }

  // 获取当前版本
  Future getCurrentApp() async {
    var result = await PackageInfo.fromPlatform();
    currentVersion.value = result.version;
  }

  // 获取远程版本
  Future getRemoteApp() async {
    var result = await Request().get(Api.latestApp, extra: {'ua': 'pc'});
    isLoading.value = false;
    if (result.data == null || result.data.isEmpty) {
      SmartDialog.showToast('获取远程版本失败，请检查网络');
      return;
    }
    data = LatestDataModel.fromJson(result.data);
    remoteAppInfo = data;
    remoteVersion.value = data.tagName ?? '';
    if (remoteVersion.value.isNotEmpty) {
      isUpdate.value =
          Utils.needUpdate(currentVersion.value, remoteVersion.value);
    }
  }

  // 跳转下载/本地更新
  Future onUpdate() async {
    Utils.matchVersion(data);
  }

  // 跳转github
  githubUrl() {
    launchUrl(
      Uri.parse('https://github.com/CyaniAgent/piliotto'),
      mode: LaunchMode.externalApplication,
    );
  }

  githubRelease() {
    launchUrl(
      Uri.parse('https://github.com/CyaniAgent/piliotto/releases'),
      mode: LaunchMode.externalApplication,
    );
  }

  // 问题反馈
  feedback() {
    launchUrl(
      Uri.parse('https://github.com/CyaniAgent/piliotto/issues'),
      // 系统自带浏览器打开
      mode: LaunchMode.externalApplication,
    );
  }

  // 日志
  logs() {
    Get.toNamed('/logs');
  }
}
