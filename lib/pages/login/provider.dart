import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:piliotto/models/user/info.dart';
import 'package:piliotto/ottohub/api/services/auth_service.dart';
import 'package:piliotto/router/app_router.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

class LoginState {
  final bool passwordVisible;
  final bool isRegisterMode;
  final bool agreedToOttohub;
  final bool agreedToPiliotto;
  final bool isLoading;
  final int seconds;
  final bool smsCodeSendStatus;

  const LoginState({
    this.passwordVisible = true,
    this.isRegisterMode = false,
    this.agreedToOttohub = false,
    this.agreedToPiliotto = false,
    this.isLoading = false,
    this.seconds = 60,
    this.smsCodeSendStatus = false,
  });

  LoginState copyWith({
    bool? passwordVisible,
    bool? isRegisterMode,
    bool? agreedToOttohub,
    bool? agreedToPiliotto,
    bool? isLoading,
    int? seconds,
    bool? smsCodeSendStatus,
  }) {
    return LoginState(
      passwordVisible: passwordVisible ?? this.passwordVisible,
      isRegisterMode: isRegisterMode ?? this.isRegisterMode,
      agreedToOttohub: agreedToOttohub ?? this.agreedToOttohub,
      agreedToPiliotto: agreedToPiliotto ?? this.agreedToPiliotto,
      isLoading: isLoading ?? this.isLoading,
      seconds: seconds ?? this.seconds,
      smsCodeSendStatus: smsCodeSendStatus ?? this.smsCodeSendStatus,
    );
  }
}

@riverpod
class LoginNotifier extends _$LoginNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final TextEditingController verificationCodeController = TextEditingController();
  final FocusNode emailTextFieldNode = FocusNode();
  final FocusNode passwordTextFieldNode = FocusNode();
  final FocusNode verificationCodeTextFieldNode = FocusNode();
  Timer? timer;

  @override
  LoginState build() {
    ref.onDispose(() {
      timer?.cancel();
      emailTextController.dispose();
      passwordTextController.dispose();
      verificationCodeController.dispose();
      emailTextFieldNode.dispose();
      passwordTextFieldNode.dispose();
      verificationCodeTextFieldNode.dispose();
    });
    return const LoginState();
  }

  void toggleMode() {
    state = state.copyWith(isRegisterMode: !state.isRegisterMode);
  }

  void togglePasswordVisible() {
    state = state.copyWith(passwordVisible: !state.passwordVisible);
  }

  void setAgreedToOttohub(bool value) {
    state = state.copyWith(agreedToOttohub: value);
  }

  void setAgreedToPiliotto(bool value) {
    state = state.copyWith(agreedToPiliotto: value);
  }

  void sendVerificationCode() async {
    if (!_isValidEmail(emailTextController.text.trim())) {
      SmartDialog.showToast('请输入有效的邮箱地址');
      return;
    }

    if (!emailTextController.text.trim().endsWith('@qq.com')) {
      SmartDialog.showToast('请使用QQ邮箱注册');
      return;
    }

    state = state.copyWith(smsCodeSendStatus: true);
    try {
      await AuthService.sendRegisterVerificationCode(
          email: emailTextController.text.trim());
      SmartDialog.showToast('验证码已发送到您的邮箱');
      startTimer();
    } catch (e) {
      state = state.copyWith(smsCodeSendStatus: false);
      SmartDialog.showToast('发送验证码失败：${e.toString()}');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void submit() async {
    if (!formKey.currentState!.validate()) return;

    if (!state.agreedToOttohub) {
      SmartDialog.showToast('请先同意 OttoHub 用户协议和隐私政策');
      return;
    }

    if (!state.agreedToPiliotto) {
      SmartDialog.showToast('请先同意 PiliOtto 用户协议和隐私政策');
      return;
    }

    if (state.isRegisterMode) {
      await _register();
    } else {
      await _login();
    }
  }

  Future _login() async {
    state = state.copyWith(isLoading: true);
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

      await GStrorage.userInfo.put('userInfoCache', userInfo);

      SmartDialog.showToast('登录成功');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = rootNavigatorKey.currentContext;
        if (ctx != null) {
          Navigator.of(ctx).pop();
        }
      });
    } catch (e) {
      SmartDialog.showToast('登录失败：${e.toString()}');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future _register() async {
    state = state.copyWith(isLoading: true);
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

      await GStrorage.userInfo.put('userInfoCache', userInfo);

      SmartDialog.showToast('注册成功');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = rootNavigatorKey.currentContext;
        if (ctx != null) {
          Navigator.of(ctx).pop();
        }
      });
    } catch (e) {
      SmartDialog.showToast('注册失败：${e.toString()}');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.seconds > 0) {
        state = state.copyWith(seconds: state.seconds - 1);
      } else {
        state = state.copyWith(seconds: 60, smsCodeSendStatus: false);
        timer.cancel();
      }
    });
  }
}
