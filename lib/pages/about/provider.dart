import 'package:dio/dio.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:piliotto/models/github/latest.dart';
import 'package:piliotto/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

class AboutState {
  final String currentVersion;
  final String remoteVersion;
  final LatestDataModel? remoteAppInfo;
  final bool isUpdate;
  final bool isLoading;

  AboutState({
    this.currentVersion = '',
    this.remoteVersion = '',
    this.remoteAppInfo,
    this.isUpdate = false,
    this.isLoading = true,
  });

  AboutState copyWith({
    String? currentVersion,
    String? remoteVersion,
    LatestDataModel? remoteAppInfo,
    bool? isUpdate,
    bool? isLoading,
  }) {
    return AboutState(
      currentVersion: currentVersion ?? this.currentVersion,
      remoteVersion: remoteVersion ?? this.remoteVersion,
      remoteAppInfo: remoteAppInfo ?? this.remoteAppInfo,
      isUpdate: isUpdate ?? this.isUpdate,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@riverpod
class AboutNotifier extends _$AboutNotifier {
  @override
  AboutState build() {
    _init();
    return AboutState();
  }

  Future<void> _init() async {
    await getCurrentApp();
    await getRemoteApp();
  }

  Future<void> getCurrentApp() async {
    var result = await PackageInfo.fromPlatform();
    state = state.copyWith(currentVersion: result.version);
  }

  Future<void> getRemoteApp() async {
    try {
      var dio = Dio();
      var result = await dio.get(
          'https://api.github.com/repos/CyaniAgent/piliotto/releases/latest');
      if (result.data == null || result.data.isEmpty) {
        SmartDialog.showToast('获取远程版本失败，请检查网络');
        state = state.copyWith(isLoading: false);
        return;
      }
      final data = LatestDataModel.fromJson(result.data);
      final remoteVersion = data.tagName ?? '';
      final needUpdate = remoteVersion.isNotEmpty
          ? Utils.needUpdate(state.currentVersion, remoteVersion)
          : false;
      state = state.copyWith(
        isLoading: false,
        remoteAppInfo: data,
        remoteVersion: remoteVersion,
        isUpdate: needUpdate,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      SmartDialog.showToast('获取远程版本失败: $e');
    }
  }

  Future<void> onUpdate() async {
    if (state.remoteAppInfo != null) {
      Utils.matchVersion(state.remoteAppInfo!);
    }
  }
}
