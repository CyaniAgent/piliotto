class UserAccount {
  final int uid;
  final String email;
  final String? username;
  final String? avatarUrl;
  final String token;
  final DateTime lastLoginTime;

  UserAccount({
    required this.uid,
    required this.email,
    this.username,
    this.avatarUrl,
    required this.token,
    DateTime? lastLoginTime,
  }) : lastLoginTime = lastLoginTime ?? DateTime.now();

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      uid: json['uid'] ?? 0,
      email: json['email'] ?? '',
      username: json['username'],
      avatarUrl: json['avatar_url'],
      token: json['token'] ?? '',
      lastLoginTime: json['last_login_time'] != null
          ? DateTime.parse(json['last_login_time'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'avatar_url': avatarUrl,
      'token': token,
      'last_login_time': lastLoginTime.toIso8601String(),
    };
  }
}

class MultiUserService {
  static const String baseEndpoint = '/auth';

  static Future<List<UserAccount>> getAccountList() async {
    throw UnimplementedError('多用户管理功能暂未实现');
  }

  static Future<void> addAccount({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError('多用户管理功能暂未实现');
  }

  static Future<void> removeAccount(int uid) async {
    throw UnimplementedError('多用户管理功能暂未实现');
  }

  static Future<void> switchAccount(int uid) async {
    throw UnimplementedError('多用户管理功能暂未实现');
  }

  static Future<UserAccount?> getCurrentAccount() async {
    throw UnimplementedError('多用户管理功能暂未实现');
  }

  static Future<void> refreshAccountToken(int uid) async {
    throw UnimplementedError('多用户管理功能暂未实现');
  }
}
