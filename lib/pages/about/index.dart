import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:piliotto/models/github/latest.dart';
import 'package:piliotto/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final AboutController _aboutController = Get.put(AboutController());

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
              'assets/images/logo/logo.png',
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
              onTap: () => _aboutController.logs(),
              title: const Text('错误日志'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: outline),
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
    getCurrentApp();
    getRemoteApp();
  }

  Future getCurrentApp() async {
    var result = await PackageInfo.fromPlatform();
    currentVersion.value = result.version;
  }

  Future getRemoteApp() async {
    try {
      var dio = Dio();
      var result = await dio.get(
          'https://api.github.com/repos/CyaniAgent/piliotto/releases/latest');
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
    } catch (e) {
      isLoading.value = false;
      SmartDialog.showToast('获取远程版本失败: $e');
    }
  }

  Future onUpdate() async {
    Utils.matchVersion(data);
  }

  void githubUrl() {
    launchUrl(
      Uri.parse('https://github.com/CyaniAgent/piliotto'),
      mode: LaunchMode.externalApplication,
    );
  }

  void githubRelease() {
    launchUrl(
      Uri.parse('https://github.com/CyaniAgent/piliotto/releases'),
      mode: LaunchMode.externalApplication,
    );
  }

  void feedback() {
    launchUrl(
      Uri.parse('https://github.com/CyaniAgent/piliotto/issues'),
      mode: LaunchMode.externalApplication,
    );
  }

  void logs() {
    Get.toNamed('/logs');
  }
}
