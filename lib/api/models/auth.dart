class LoginResponse {
  final int uid;
  final String? token;
  final String avatarUrl;
  final String coverUrl;
  final String ifTodayFirstLogin;
  final String email;
  final int isAudit;
  final int isAdmin;

  LoginResponse({
    required this.uid,
    this.token,
    required this.avatarUrl,
    required this.coverUrl,
    required this.ifTodayFirstLogin,
    required this.email,
    required this.isAudit,
    required this.isAdmin,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      uid: json['uid'] ?? 0,
      token: json['token'],
      avatarUrl: json['avatar_url'] ?? '',
      coverUrl: json['cover_url'] ?? '',
      ifTodayFirstLogin: json['if_today_first_login'] ?? 'no',
      email: json['email'] ?? '',
      isAudit: json['is_audit'] ?? 0,
      isAdmin: json['is_admin'] ?? 0,
    );
  }
}

class SignInResponse {
  final String ifTodayFirstLogin;

  SignInResponse({
    required this.ifTodayFirstLogin,
  });

  factory SignInResponse.fromJson(Map<String, dynamic> json) {
    return SignInResponse(
      ifTodayFirstLogin: json['if_today_first_login'] ?? 'no',
    );
  }
}
