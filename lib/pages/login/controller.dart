import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/api/services/auth_service.dart';
import 'package:piliotto/models/user/info.dart';
import 'package:piliotto/pages/dynamics/index.dart';
import 'package:piliotto/pages/home/index.dart';
import 'package:piliotto/pages/media/index.dart';
import 'package:piliotto/pages/mine/index.dart';
import 'package:piliotto/utils/storage.dart';

class LoginPageController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final TextEditingController verificationCodeController =
      TextEditingController();

  final FocusNode emailTextFieldNode = FocusNode();
  final FocusNode passwordTextFieldNode = FocusNode();
  final FocusNode verificationCodeTextFieldNode = FocusNode();

  RxBool passwordVisible = true.obs;
  RxBool isRegisterMode = false.obs;
  RxBool agreedToOttohub = false.obs;
  RxBool agreedToPiliotto = false.obs;
  RxBool isLoading = false.obs;

  RxInt seconds = 60.obs;
  Timer? timer;
  RxBool smsCodeSendStatus = false.obs;

  void toggleMode() {
    isRegisterMode.value = !isRegisterMode.value;
  }

  void sendVerificationCode() async {
    if (!GetUtils.isEmail(emailTextController.text.trim())) {
      SmartDialog.showToast('请输入有效的邮箱地址');
      return;
    }

    if (!emailTextController.text.trim().endsWith('@qq.com')) {
      SmartDialog.showToast('请使用QQ邮箱注册');
      return;
    }

    smsCodeSendStatus.value = true;
    try {
      await AuthService.sendRegisterVerificationCode(
          email: emailTextController.text.trim());
      SmartDialog.showToast('验证码已发送到您的邮箱');
      startTimer();
    } catch (e) {
      smsCodeSendStatus.value = false;
      SmartDialog.showToast('发送验证码失败：${e.toString()}');
    }
  }

  void submit() async {
    if (!formKey.currentState!.validate()) return;

    if (!agreedToOttohub.value) {
      SmartDialog.showToast('请先同意 OttoHub 用户协议和隐私政策');
      return;
    }

    if (!agreedToPiliotto.value) {
      SmartDialog.showToast('请先同意 PiliOtto 用户协议和隐私政策');
      return;
    }

    if (isRegisterMode.value) {
      await _register();
    } else {
      await _login();
    }
  }

  Future _login() async {
    isLoading.value = true;
    try {
      final response = await AuthService.login(
        email: emailTextController.text.trim(),
        password: passwordTextController.text.trim(),
      );

      final userInfo = UserInfoData(
        isLogin: true,
        mid: int.tryParse(response.uid) ?? 0,
        face: response.avatarUrl,
        cover: response.coverUrl,
        uname: 'user_${response.uid}',
      );

      Box userInfoCache = GStrorage.userInfo;
      await userInfoCache.put('userInfoCache', userInfo);

      await _refreshLoginStatus(true, response.avatarUrl);

      SmartDialog.showToast('登录成功');
      Get.back();
    } catch (e) {
      SmartDialog.showToast('登录失败：${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future _register() async {
    isLoading.value = true;
    try {
      final response = await AuthService.register(
        email: emailTextController.text.trim(),
        password: passwordTextController.text.trim(),
        verificationCode: verificationCodeController.text.trim(),
      );

      final userInfo = UserInfoData(
        isLogin: true,
        mid: int.tryParse(response.uid) ?? 0,
        face: response.avatarUrl,
        cover: response.coverUrl,
        uname: 'user_${response.uid}',
      );

      Box userInfoCache = GStrorage.userInfo;
      await userInfoCache.put('userInfoCache', userInfo);

      await _refreshLoginStatus(true, response.avatarUrl);

      SmartDialog.showToast('注册成功');
      Get.back();
    } catch (e) {
      SmartDialog.showToast('注册失败：${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future _refreshLoginStatus(bool status, String? avatarUrl) async {
    try {
      final mineCtr = Get.find<MineController>();
      mineCtr.userLogin.value = status;
      if (status) {
        mineCtr.userInfo.value = await GStrorage.userInfo.get('userInfoCache');
      }

      HomeController homeCtr = Get.find<HomeController>();
      homeCtr.updateLoginStatus(status);
      if (avatarUrl != null) {
        homeCtr.userFace.value = avatarUrl;
      }

      DynamicsController dynamicsCtr = Get.find<DynamicsController>();
      dynamicsCtr.userLogin.value = status;

      MediaController mediaCtr = Get.find<MediaController>();
      mediaCtr.userLogin.value = status;
    } catch (err) {
      SmartDialog.showToast('刷新状态失败: ${err.toString()}');
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds.value > 0) {
        seconds.value--;
      } else {
        seconds.value = 60;
        smsCodeSendStatus.value = false;
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    emailTextController.dispose();
    passwordTextController.dispose();
    verificationCodeController.dispose();
    emailTextFieldNode.dispose();
    passwordTextFieldNode.dispose();
    verificationCodeTextFieldNode.dispose();
    super.dispose();
  }
}
