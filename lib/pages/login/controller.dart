import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:piliotto/api/services/auth_service.dart';

class LoginPageController extends GetxController {
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();

  final FocusNode emailTextFieldNode = FocusNode();
  final FocusNode passwordTextFieldNode = FocusNode();

  RxBool passwordVisible = true.obs;

  // 登录方法
  void login() async {
    if (loginFormKey.currentState!.validate()) {
      SmartDialog.showLoading(msg: '登录中...');
      try {
        await AuthService.login(
          email: emailTextController.text.trim(),
          password: passwordTextController.text.trim(),
        );

        SmartDialog.showToast('登录成功');
        Get.back(); // 关闭登录页面
      } catch (e) {
        SmartDialog.showToast('登录失败：${e.toString()}');
      } finally {
        SmartDialog.dismiss();
      }
    }
  }

  // 跳转到注册页面
  void goToRegister() {
    Get.toNamed('/register');
  }

  @override
  void dispose() {
    emailTextController.dispose();
    passwordTextController.dispose();
    emailTextFieldNode.dispose();
    passwordTextFieldNode.dispose();
    super.dispose();
  }
}

class RegisterPageController extends GetxController {
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final TextEditingController verificationCodeController =
      TextEditingController();

  final FocusNode emailTextFieldNode = FocusNode();
  final FocusNode passwordTextFieldNode = FocusNode();
  final FocusNode verificationCodeTextFieldNode = FocusNode();

  RxBool passwordVisible = true.obs;

  // 倒计时60s
  RxInt seconds = 60.obs;
  Timer? timer;
  RxBool smsCodeSendStatus = false.obs;

  // 发送验证码
  void sendVerificationCode() async {
    if (!GetUtils.isEmail(emailTextController.text.trim())) {
      SmartDialog.showToast('请输入有效的邮箱地址');
      return;
    }

    SmartDialog.showLoading(msg: '发送验证码中...');
    try {
      await AuthService.sendRegisterVerificationCode(
          email: emailTextController.text.trim());
      SmartDialog.showToast('验证码已发送');
      smsCodeSendStatus.value = true;
      startTimer();
    } catch (e) {
      SmartDialog.showToast('发送验证码失败：${e.toString()}');
    } finally {
      SmartDialog.dismiss();
    }
  }

  // 注册方法
  void register() async {
    if (registerFormKey.currentState!.validate()) {
      SmartDialog.showLoading(msg: '注册中...');
      try {
        await AuthService.register(
          email: emailTextController.text.trim(),
          password: passwordTextController.text.trim(),
          verificationCode: verificationCodeController.text.trim(),
        );

        SmartDialog.showToast('注册成功');
        Get.back(); // 关闭注册页面
      } catch (e) {
        SmartDialog.showToast('注册失败：${e.toString()}');
      } finally {
        SmartDialog.dismiss();
      }
    }
  }

  // 跳转到登录页面
  void goToLogin() {
    Get.back();
  }

  // 验证码倒计时
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
