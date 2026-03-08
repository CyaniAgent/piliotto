import '../services/api_service.dart';
import '../models/auth.dart';

class AuthService {
  static const String baseEndpoint = '/auth';

  // 用户登录
  static Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/login',
      method: 'POST',
      body: {
        'uid_email': email,
        'pw': password,
      },
      requireToken: false,
    );
    final loginResponse = LoginResponse.fromJson(response);
    // 保存token
    if (loginResponse.token != null) {
      ApiService.setToken(loginResponse.token!);
    }
    return loginResponse;
  }

  // 用户注册
  static Future<LoginResponse> register({
    required String email,
    required String password,
    required String verificationCode,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/register',
      method: 'POST',
      body: {
        'email': email,
        'register_verification_code': verificationCode,
        'pw': password,
        'confirm_pw': password,
      },
      requireToken: false,
    );
    final loginResponse = LoginResponse.fromJson(response);
    // 保存token
    if (loginResponse.token != null) {
      ApiService.setToken(loginResponse.token!);
    }
    return loginResponse;
  }

  // 发送注册验证码
  static Future<void> sendRegisterVerificationCode(
      {required String email}) async {
    await ApiService.request(
      '$baseEndpoint/register/verification-code',
      method: 'POST',
      body: {'email': email},
      requireToken: false,
    );
  }

  // 重置密码
  static Future<void> resetPassword({
    required String email,
    required String passwordresetVerificationCode,
    required String pw,
    required String confirmPw,
  }) async {
    await ApiService.request(
      '$baseEndpoint/password-reset',
      method: 'POST',
      body: {
        'email': email,
        'passwordreset_verification_code': passwordresetVerificationCode,
        'pw': pw,
        'confirm_pw': confirmPw,
      },
      requireToken: false,
    );
  }

  // 发送密码重置验证码
  static Future<void> sendPasswordResetVerificationCode(
      {required String email}) async {
    await ApiService.request(
      '$baseEndpoint/password-reset/verification-code',
      method: 'POST',
      body: {'email': email},
      requireToken: false,
    );
  }

  // 用户签到
  static Future<SignInResponse> signIn() async {
    final response = await ApiService.request(
      '$baseEndpoint/sign-in',
      method: 'POST',
    );
    return SignInResponse.fromJson(response['data']);
  }
}
