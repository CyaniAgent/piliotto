import 'package:piliotto/api/services/auth_service.dart';

class LoginHttp {
  // 获取验证码
  static Future queryCaptcha() async {
    return {'status': false, 'msg': 'Ottohub 使用邮箱登录，不需要验证码'};
  }

  // 发送短信验证码
  static Future sendWebSmsCode({
    int? cid,
    required int tel,
    required String token,
    required String challenge,
    required String validate,
    required String seccode,
  }) async {
    return {'status': false, 'msg': 'Ottohub 使用邮箱登录，不支持短信验证码'};
  }

  // 短信验证码登录
  static Future loginInByWebSmsCode({
    int? cid,
    required int tel,
    required int code,
    required String captchaKey,
  }) async {
    return {'status': false, 'msg': 'Ottohub 使用邮箱登录，不支持短信登录'};
  }

  // 获取Web Key
  static Future getWebKey() async {
    return {'status': false, 'msg': 'Ottohub 使用 token 认证'};
  }

  // 发送App短信验证码
  static Future sendAppSmsCode({
    int? cid,
    required int tel,
    required String token,
    required String challenge,
    required String validate,
    required String seccode,
  }) async {
    return {'status': false, 'msg': 'Ottohub 使用邮箱登录，不支持短信验证码'};
  }

  // App密码登录
  static Future loginInByMobPwd({
    required String tel,
    required String password,
    required String key,
    required String rhash,
  }) async {
    return {'status': false, 'msg': 'Ottohub 使用邮箱登录'};
  }

  // Web密码登录
  static Future loginInByWebPwd({
    required int username,
    required String password,
    required String token,
    required String challenge,
    required String validate,
    required String seccode,
  }) async {
    return {'status': false, 'msg': 'Ottohub 使用邮箱登录'};
  }

  // 获取Web二维码
  static Future getWebQrcode() async {
    return {'status': false, 'msg': 'Ottohub 不支持二维码登录'};
  }

  // 查询二维码状态
  static Future queryWebQrcodeStatus(String qrcodeKey) async {
    return {'status': false, 'msg': 'Ottohub 不支持二维码登录'};
  }

  // Ottohub 登录
  static Future login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await AuthService.login(
        email: email,
        password: password,
      );
      return {'status': true, 'data': response};
    } catch (err) {
      return {'status': false, 'msg': err.toString()};
    }
  }

  // Ottohub 注册
  static Future register({
    required String email,
    required String password,
    required String verificationCode,
  }) async {
    try {
      final response = await AuthService.register(
        email: email,
        password: password,
        verificationCode: verificationCode,
      );
      return {'status': true, 'data': response};
    } catch (err) {
      return {'status': false, 'msg': err.toString()};
    }
  }

  // Ottohub 发送验证码
  static Future sendVerifyCode({required String email}) async {
    try {
      await AuthService.sendRegisterVerificationCode(email: email);
      return {'status': true};
    } catch (err) {
      return {'status': false, 'msg': err.toString()};
    }
  }
}
