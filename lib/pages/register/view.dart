import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../login/controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final LoginPageController _loginPageCtr = Get.put(LoginPageController());

  @override
  void dispose() {
    _loginPageCtr.timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            _loginPageCtr.emailTextFieldNode.unfocus();
            _loginPageCtr.passwordTextFieldNode.unfocus();
            _loginPageCtr.confirmPasswordTextFieldNode.unfocus();
            await Future.delayed(const Duration(milliseconds: 200));
            Get.back();
          },
          icon: const Icon(Icons.close_outlined),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 800;
          
          if (isWideScreen) {
            return Center(
              child: Row(
                children: [
                  // 左侧占位区域，占60%宽度
                  Expanded(
                    flex: 3,
                    child: Container(
                      color: Theme.of(context).colorScheme.primary.withAlpha(10),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Ottohub',
                              style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '创建新账号',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 右侧注册表单，占40%宽度
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 40,
                      ),
                      child: Form(
                        key: _loginPageCtr.registerFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '注册',
                              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                  letterSpacing: 1,
                                  height: 2.1,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '创建您的 Ottohub 账号。',
                              style: Theme.of(context).textTheme.titleSmall!,
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 38, bottom: 15),
                              child: TextFormField(
                                controller: _loginPageCtr.emailTextController,
                                focusNode: _loginPageCtr.emailTextFieldNode,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  isDense: true,
                                  labelText: '输入邮箱',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                ),
                                validator: (v) {
                                  if (v!.trim().isEmpty) {
                                    return "邮箱不能为空";
                                  }
                                  if (!GetUtils.isEmail(v.trim())) {
                                    return "请输入有效的邮箱地址";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              child: Obx(() => TextFormField(
                                    controller: _loginPageCtr.passwordTextController,
                                    focusNode: _loginPageCtr.passwordTextFieldNode,
                                    keyboardType: TextInputType.visiblePassword,
                                    obscureText: _loginPageCtr.passwordVisible.value,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelText: '输入密码',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6.0),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _loginPageCtr.passwordVisible.value
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                        onPressed: () {
                                          _loginPageCtr.passwordVisible.value = !_loginPageCtr.passwordVisible.value;
                                        },
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v!.trim().isEmpty) {
                                        return "密码不能为空";
                                      }
                                      if (v.trim().length < 6) {
                                        return "密码长度至少为6位";
                                      }
                                      return null;
                                    },
                                  )),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _loginPageCtr.confirmPasswordTextController,
                                      focusNode: _loginPageCtr.confirmPasswordTextFieldNode,
                                      maxLength: 6,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        labelText: '输入验证码',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(6.0),
                                        ),
                                      ),
                                      validator: (v) {
                                        return v!.trim().isNotEmpty ? null : "验证码不能为空";
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Obx(() => TextButton(
                                        onPressed: _loginPageCtr.smsCodeSendStatus.value
                                            ? null
                                            : () => _loginPageCtr.sendVerificationCode(),
                                        child: _loginPageCtr.smsCodeSendStatus.value
                                            ? Text('重新获取(${_loginPageCtr.seconds.value}s)')
                                            : const Text('获取验证码'),
                                      )),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                ),
                                onPressed: () => _loginPageCtr.register(),
                                child: const Text('注册'),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('已有账号？'),
                                TextButton(
                                  onPressed: () => _loginPageCtr.goToLogin(),
                                  child: const Text('立即登录'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // 窄屏设备保持原有布局
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10,
                bottom: MediaQuery.of(context).padding.bottom + 10,
              ),
              child: Form(
                key: _loginPageCtr.registerFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      '注册',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          letterSpacing: 1,
                          height: 2.1,
                          fontSize: 34,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '创建您的 Ottohub 账号。',
                      style: Theme.of(context).textTheme.titleSmall!,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 38, bottom: 15),
                      child: TextFormField(
                        controller: _loginPageCtr.emailTextController,
                        focusNode: _loginPageCtr.emailTextFieldNode,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: '输入邮箱',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                        ),
                        validator: (v) {
                          if (v!.trim().isEmpty) {
                            return "邮箱不能为空";
                          }
                          if (!GetUtils.isEmail(v.trim())) {
                            return "请输入有效的邮箱地址";
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      child: Obx(() => TextFormField(
                            controller: _loginPageCtr.passwordTextController,
                            focusNode: _loginPageCtr.passwordTextFieldNode,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: _loginPageCtr.passwordVisible.value,
                            decoration: InputDecoration(
                              isDense: true,
                              labelText: '输入密码',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _loginPageCtr.passwordVisible.value
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                onPressed: () {
                                  _loginPageCtr.passwordVisible.value = !_loginPageCtr.passwordVisible.value;
                                },
                              ),
                            ),
                            validator: (v) {
                              if (v!.trim().isEmpty) {
                                return "密码不能为空";
                              }
                              if (v.trim().length < 6) {
                                return "密码长度至少为6位";
                              }
                              return null;
                            },
                          )),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _loginPageCtr.confirmPasswordTextController,
                              focusNode: _loginPageCtr.confirmPasswordTextFieldNode,
                              maxLength: 6,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                isDense: true,
                                labelText: '输入验证码',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                              ),
                              validator: (v) {
                                return v!.trim().isNotEmpty ? null : "验证码不能为空";
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Obx(() => TextButton(
                                onPressed: _loginPageCtr.smsCodeSendStatus.value
                                    ? null
                                    : () => _loginPageCtr.sendVerificationCode(),
                                child: _loginPageCtr.smsCodeSendStatus.value
                                    ? Text('重新获取(${_loginPageCtr.seconds.value}s)')
                                    : const Text('获取验证码'),
                              )),
                        ],
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () => _loginPageCtr.register(),
                        child: const Text('注册'),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('已有账号？'),
                        TextButton(
                          onPressed: () => _loginPageCtr.goToLogin(),
                          child: const Text('立即登录'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}