import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String heroTag;
  late LoginPageController _loginPageCtr;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    heroTag = 'login_${DateTime.now().millisecondsSinceEpoch}';
    _loginPageCtr = Get.put(LoginPageController(), tag: heroTag);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            _loginPageCtr.emailTextFieldNode.unfocus();
            _loginPageCtr.passwordTextFieldNode.unfocus();
            _loginPageCtr.verificationCodeTextFieldNode.unfocus();
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
            return _buildWideScreenLayout(context, theme);
          } else {
            return _buildNarrowScreenLayout(context, theme);
          }
        },
      ),
    );
  }

  Widget _buildWideScreenLayout(BuildContext context, ThemeData theme) {
    return Center(
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: theme.colorScheme.primary.withAlpha(10),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ottohub',
                      style: theme.textTheme.displayLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '阐述你的梦',
                      style: theme.textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: Form(
                key: _loginPageCtr.formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTitle(context, theme),
                      _buildEmailField(context),
                      _buildPasswordField(context),
                      _buildVerificationCodeField(context),
                      const SizedBox(height: 20),
                      _buildAgreementSection(context, theme),
                      const SizedBox(height: 20),
                      _buildSubmitButton(context),
                      const SizedBox(height: 15),
                      _buildModeToggleButton(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrowScreenLayout(BuildContext context, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Form(
        key: _loginPageCtr.formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitle(context, theme),
              _buildEmailField(context),
              _buildPasswordField(context),
              _buildVerificationCodeField(context),
              const SizedBox(height: 20),
              _buildAgreementSection(context, theme),
              const SizedBox(height: 20),
              _buildSubmitButton(context),
              const SizedBox(height: 15),
              _buildModeToggleButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Text(
              _loginPageCtr.isRegisterMode.value ? '注册' : '登录',
              style: theme.textTheme.titleLarge!.copyWith(
                letterSpacing: 1,
                height: 2.1,
                fontSize: 34,
                fontWeight: FontWeight.w500,
              ),
            )),
        Obx(() => Text(
              '请使用您的 Ottohub 账号${_loginPageCtr.isRegisterMode.value ? '注册' : '登录'}。',
              style: theme.textTheme.titleSmall!,
            )),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return Container(
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
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return Container(
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
                  _loginPageCtr.passwordVisible.value =
                      !_loginPageCtr.passwordVisible.value;
                },
              ),
            ),
            validator: (v) {
              return v!.trim().isNotEmpty ? null : "密码不能为空";
            },
          )),
    );
  }

  Widget _buildVerificationCodeField(BuildContext context) {
    return Obx(() => AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _loginPageCtr.isRegisterMode.value
              ? Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _loginPageCtr.verificationCodeController,
                          focusNode:
                              _loginPageCtr.verificationCodeTextFieldNode,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: '验证码',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: _loginPageCtr.smsCodeSendStatus.value
                            ? null
                            : _loginPageCtr.sendVerificationCode,
                        child: Text(
                          _loginPageCtr.smsCodeSendStatus.value
                              ? '${_loginPageCtr.seconds.value}s'
                              : '发送验证码',
                          style: TextStyle(
                            color: _loginPageCtr.smsCodeSendStatus.value
                                ? Theme.of(context).colorScheme.outline
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(height: 0, width: double.infinity),
        ));
  }

  Widget _buildAgreementSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _loginPageCtr.agreedToOttohub.value,
                    onChanged: (value) {
                      _loginPageCtr.agreedToOttohub.value = value ?? false;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: '我已阅读并同意'),
                        TextSpan(
                          text: '《OttoHub用户协议》',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _showOttohubUserAgreement(context),
                        ),
                        const TextSpan(text: '和'),
                        TextSpan(
                          text: '《OttoHub隐私政策》',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _showOttohubPrivacyPolicy(context),
                        ),
                      ],
                    ),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            )),
        const SizedBox(height: 8),
        Obx(() => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _loginPageCtr.agreedToPiliotto.value,
                    onChanged: (value) {
                      _loginPageCtr.agreedToPiliotto.value = value ?? false;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: '我已阅读并同意'),
                        TextSpan(
                          text: '《PiliOtto用户协议》',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _showPiliottoUserAgreement(context),
                        ),
                        const TextSpan(text: '和'),
                        TextSpan(
                          text: '《PiliOtto隐私政策》',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _showPiliottoPrivacyPolicy(context),
                        ),
                      ],
                    ),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            )),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed:
                _loginPageCtr.isLoading.value ? null : _loginPageCtr.submit,
            child: _loginPageCtr.isLoading.value
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                : Text(_loginPageCtr.isRegisterMode.value ? '注册' : '登录'),
          )),
    );
  }

  Widget _buildModeToggleButton(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: _loginPageCtr.toggleMode,
        child: Obx(() => Text(
              _loginPageCtr.isRegisterMode.value ? '已有账号？去登录' : '没有账号？去注册',
            )),
      ),
    );
  }

  void _showOttohubUserAgreement(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _PolicyDialog(
        title: 'OttoHub 用户协议',
        content: '''
1. 协议的接受
欢迎使用 OTTOhub 服务！本协议是您与 OTTOhub 之间关于使用 OTTOhub 服务的法律协议。

2. 账户注册与管理
您需要注册一个账户才能使用 OTTOhub 的部分服务。

3. 用户行为规范
您在使用 OTTOhub 服务时必须遵守相关法律法规。

4. 知识产权
OTTOhub 及其相关服务中包含的所有内容的知识产权归 OTTOhub 所有。

5. 隐私政策
您的隐私对我们非常重要，请参阅我们的隐私政策。

6. 服务变更、中断或终止
我们可能会变更、中断或终止部分或全部服务。

7. 免责声明
OTTOhub 不对因使用服务而产生的任何损失负责。

8. 法律适用与争议解决
本协议的订立、执行、解释及争议的解决均适用中华人民共和国法律。

声明：因本应用可能更新不及时，一切以 ottohub.cn 为准。
''',
      ),
    );
  }

  void _showOttohubPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _PolicyDialog(
        title: 'OttoHub 隐私政策',
        content: '''
1. 引言
OTTOhub 致力于保护您的隐私和个人信息。

2. 我们收集的信息
我们可能收集以下信息：
• 您的注册信息（如邮箱、密码等）
• 您的使用行为数据
• 您上传的内容

3. 信息的使用
我们使用收集的信息：
• 提供和改进服务
• 与您沟通
• 确保服务安全

4. 信息的共享
我们不会向第三方共享您的个人信息，除非：
• 获得您的明确许可
• 法律法规要求

5. 信息的存储与保护
我们采取合理的安全措施保护您的信息。

6. 您的权利
您有权访问、修改和删除您的个人信息。

7. 政策变更
我们可能会不时更新本隐私政策。

声明：因本应用可能更新不及时，一切以 ottohub.cn 为准。
''',
      ),
    );
  }

  void _showPiliottoUserAgreement(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _PolicyDialog(
        title: 'PiliOtto 用户协议',
        content: '''
1. 协议的接受
欢迎使用 PiliOtto！本协议是您与 PiliOtto 开发者之间关于使用本应用的协议。

2. 服务说明
PiliOtto 是一款第三方 Ottohub 客户端，用于访问 Ottohub 平台内容。

3. 用户责任
• 您应遵守 Ottohub 平台的相关规定
• 不得利用本应用从事违法活动
• 不得破坏或干扰应用的正常运行

4. 知识产权
PiliOtto 应用本身的知识产权归开发者所有。

5. 免责声明
• 本应用为开源项目，按"原样"提供，不提供任何明示或暗示的保证
• 开发者不对因使用本应用而产生的任何损失负责
• 本应用使用 GitHub API 检查更新，相关服务由 GitHub 提供

6. 开源许可
本应用基于开源协议发布，具体请查看项目仓库。

7. 法律适用
本协议适用中华人民共和国法律。
''',
      ),
    );
  }

  void _showPiliottoPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _PolicyDialog(
        title: 'PiliOtto 隐私政策',
        content: '''
1. 引言
PiliOtto 尊重并保护用户隐私。

2. 信息收集
本应用：
• 不收集个人身份信息
• 使用 GitHub API 检查应用更新
• 登录信息直接与 Ottohub 服务器交互

3. 数据存储
• 登录凭证仅存储在您的本地设备上
• 我们不会将您的数据上传到第三方服务器

4. 第三方服务
本应用使用以下第三方服务：
• Ottohub API：用于核心功能
• GitHub API：用于检查应用更新

5. 权限说明
应用请求的权限仅用于提供必要功能。

6. 您的权利
您可以随时清除本地数据或卸载应用。

7. 政策更新
如有变更，我们将在此更新。
''',
      ),
    );
  }
}

class _PolicyDialog extends StatelessWidget {
  final String title;
  final String content;

  const _PolicyDialog({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Text(
          content,
          style: theme.textTheme.bodyMedium,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}
