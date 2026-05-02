import 'package:hive/hive.dart';

class UserInfoData {
  UserInfoData({
    this.isLogin,
    this.emailVerified,
    this.face,
    this.cover,
    this.levelInfo,
    this.mid,
    this.mobileVerified,
    this.money,
    this.moral,
    this.official,
    this.officialVerify,
    this.pendant,
    this.scores,
    this.uname,
    this.vipDueDate,
    this.vipStatus,
    this.vipType,
    this.vipPayType,
    this.vipThemeType,
    this.vipLabel,
    this.vipAvatarSub,
    this.vipNicknameColor,
    this.wallet,
    this.hasShop,
    this.shopUrl,
  });
  bool? isLogin;
  int? emailVerified;
  String? face;
  String? cover;
  LevelInfo? levelInfo;
  int? mid;
  int? mobileVerified;
  double? money;
  int? moral;
  Map? official;
  Map? officialVerify;
  Map? pendant;
  int? scores;
  String? uname;
  int? vipDueDate;
  int? vipStatus;
  int? vipType;
  int? vipPayType;
  int? vipThemeType;
  Map? vipLabel;
  int? vipAvatarSub;
  String? vipNicknameColor;
  Map? wallet;
  bool? hasShop;
  String? shopUrl;

  UserInfoData copyWith({
    bool? isLogin,
    int? emailVerified,
    String? face,
    String? cover,
    LevelInfo? levelInfo,
    int? mid,
    int? mobileVerified,
    double? money,
    int? moral,
    Map? official,
    Map? officialVerify,
    Map? pendant,
    int? scores,
    String? uname,
    int? vipDueDate,
    int? vipStatus,
    int? vipType,
    int? vipPayType,
    int? vipThemeType,
    Map? vipLabel,
    int? vipAvatarSub,
    String? vipNicknameColor,
    Map? wallet,
    bool? hasShop,
    String? shopUrl,
  }) {
    return UserInfoData(
      isLogin: isLogin ?? this.isLogin,
      emailVerified: emailVerified ?? this.emailVerified,
      face: face ?? this.face,
      cover: cover ?? this.cover,
      levelInfo: levelInfo ?? this.levelInfo,
      mid: mid ?? this.mid,
      mobileVerified: mobileVerified ?? this.mobileVerified,
      money: money ?? this.money,
      moral: moral ?? this.moral,
      official: official ?? this.official,
      officialVerify: officialVerify ?? this.officialVerify,
      pendant: pendant ?? this.pendant,
      scores: scores ?? this.scores,
      uname: uname ?? this.uname,
      vipDueDate: vipDueDate ?? this.vipDueDate,
      vipStatus: vipStatus ?? this.vipStatus,
      vipType: vipType ?? this.vipType,
      vipPayType: vipPayType ?? this.vipPayType,
      vipThemeType: vipThemeType ?? this.vipThemeType,
      vipLabel: vipLabel ?? this.vipLabel,
      vipAvatarSub: vipAvatarSub ?? this.vipAvatarSub,
      vipNicknameColor: vipNicknameColor ?? this.vipNicknameColor,
      wallet: wallet ?? this.wallet,
      hasShop: hasShop ?? this.hasShop,
      shopUrl: shopUrl ?? this.shopUrl,
    );
  }

  UserInfoData.fromJson(Map<String, dynamic> json) {
    isLogin = json['isLogin'] ?? false;
    emailVerified = json['email_verified'];
    face = json['face'];
    cover = json['cover'];
    levelInfo = json['level_info'] != null
        ? LevelInfo.fromJson(json['level_info'])
        : LevelInfo();
    mid = json['mid'];
    mobileVerified = json['mobile_verified'];
    money = json['money'] is int ? json['money'].toDouble() : json['money'];
    moral = json['moral'];
    official = json['official'];
    officialVerify = json['officialVerify'];
    pendant = json['pendant'];
    scores = json['scores'];
    uname = json['uname'];
    vipDueDate = json['vipDueDate'];
    vipStatus = json['vipStatus'];
    vipType = json['vipType'];
    vipPayType = json['vip_pay_type'];
    vipThemeType = json['vip_theme_type'];
    vipLabel = json['vip_label'];
    vipAvatarSub = json['vip_avatar_subscript'];
    vipNicknameColor = json['vip_nickname_color'];
    wallet = json['wallet'];
    hasShop = json['has_shop'];
    shopUrl = json['shop_url'];
  }
}

class LevelInfo {
  LevelInfo({
    this.currentLevel,
    this.currentMin,
    this.currentExp,
    this.nextExp,
  });
  int? currentLevel;
  int? currentMin;
  int? currentExp;
  int? nextExp;

  LevelInfo.fromJson(Map<String, dynamic> json) {
    currentLevel = json['current_level'];
    currentMin = json['current_min'];
    currentExp = json['current_exp'];
    nextExp =
        json['current_level'] == 6 ? json['current_exp'] : json['next_exp'];
  }
}

class UserInfoDataAdapter extends TypeAdapter<UserInfoData> {
  @override
  final int typeId = 4;

  @override
  UserInfoData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserInfoData(
      isLogin: fields[0] as bool?,
      emailVerified: fields[1] as int?,
      face: fields[2] as String?,
      cover: fields[24] as String?,
      levelInfo: fields[3] as LevelInfo?,
      mid: fields[4] as int?,
      mobileVerified: fields[5] as int?,
      money: fields[6] as double?,
      moral: fields[7] as int?,
      official: (fields[8] as Map?)?.cast<dynamic, dynamic>(),
      officialVerify: (fields[9] as Map?)?.cast<dynamic, dynamic>(),
      pendant: (fields[10] as Map?)?.cast<dynamic, dynamic>(),
      scores: fields[11] as int?,
      uname: fields[12] as String?,
      vipDueDate: fields[13] as int?,
      vipStatus: fields[14] as int?,
      vipType: fields[15] as int?,
      vipPayType: fields[16] as int?,
      vipThemeType: fields[17] as int?,
      vipLabel: (fields[18] as Map?)?.cast<dynamic, dynamic>(),
      vipAvatarSub: fields[19] as int?,
      vipNicknameColor: fields[20] as String?,
      wallet: (fields[21] as Map?)?.cast<dynamic, dynamic>(),
      hasShop: fields[22] as bool?,
      shopUrl: fields[23] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserInfoData obj) {
    writer
      ..writeByte(25)
      ..writeByte(0)
      ..write(obj.isLogin)
      ..writeByte(1)
      ..write(obj.emailVerified)
      ..writeByte(2)
      ..write(obj.face)
      ..writeByte(24)
      ..write(obj.cover)
      ..writeByte(3)
      ..write(obj.levelInfo)
      ..writeByte(4)
      ..write(obj.mid)
      ..writeByte(5)
      ..write(obj.mobileVerified)
      ..writeByte(6)
      ..write(obj.money)
      ..writeByte(7)
      ..write(obj.moral)
      ..writeByte(8)
      ..write(obj.official)
      ..writeByte(9)
      ..write(obj.officialVerify)
      ..writeByte(10)
      ..write(obj.pendant)
      ..writeByte(11)
      ..write(obj.scores)
      ..writeByte(12)
      ..write(obj.uname)
      ..writeByte(13)
      ..write(obj.vipDueDate)
      ..writeByte(14)
      ..write(obj.vipStatus)
      ..writeByte(15)
      ..write(obj.vipType)
      ..writeByte(16)
      ..write(obj.vipPayType)
      ..writeByte(17)
      ..write(obj.vipThemeType)
      ..writeByte(18)
      ..write(obj.vipLabel)
      ..writeByte(19)
      ..write(obj.vipAvatarSub)
      ..writeByte(20)
      ..write(obj.vipNicknameColor)
      ..writeByte(21)
      ..write(obj.wallet)
      ..writeByte(22)
      ..write(obj.hasShop)
      ..writeByte(23)
      ..write(obj.shopUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserInfoDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LevelInfoAdapter extends TypeAdapter<LevelInfo> {
  @override
  final int typeId = 5;

  @override
  LevelInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LevelInfo(
      currentLevel: fields[0] as int?,
      currentMin: fields[1] as int?,
      currentExp: fields[2] as int?,
      nextExp: fields[3] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, LevelInfo obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.currentLevel)
      ..writeByte(1)
      ..write(obj.currentMin)
      ..writeByte(2)
      ..write(obj.currentExp)
      ..writeByte(3)
      ..write(obj.nextExp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LevelInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
