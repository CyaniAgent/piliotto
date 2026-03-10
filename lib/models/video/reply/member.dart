class ReplyMember {
  ReplyMember({
    this.mid,
    this.uname,
    this.sign,
    this.avatar,
    this.level,
    this.pendant,
    this.officialVerify,
    this.vip,
    this.fansDetail,
  });

  String? mid;
  String? uname;
  String? sign;
  String? avatar;
  int? level;
  Pendant? pendant;
  Map? officialVerify;
  Map? vip;
  Map? fansDetail;
  UserSailing? userSailing;

  ReplyMember.fromJson(Map<String, dynamic> json) {
    mid = json['mid'];
    uname = json['uname'];
    sign = json['sign'];
    avatar = json['avatar'];
    level = json['level_info'] != null ? json['level_info']['current_level'] : 1;
    pendant = json['pendant'] != null ? Pendant.fromJson(json['pendant']) : Pendant(pid: 0, name: '', image: '');
    officialVerify = json['officia_verify'] ?? {};
    vip = json['vip'] ?? {'vipStatus': 0, 'vipType': 0};
    fansDetail = json['fans_detail'] ?? {};
    userSailing = json['user_sailing'] != null
        ? UserSailing.fromJson(json['user_sailing'])
        : UserSailing();
  }
}

class Pendant {
  Pendant({
    this.pid,
    this.name,
    this.image,
  });

  int? pid;
  String? name;
  String? image;

  Pendant.fromJson(Map<String, dynamic> json) {
    pid = json['pid'];
    name = json['name'];
    image = json['image'];
  }
}

class UserSailing {
  UserSailing({this.pendant, this.cardbg});

  Map? pendant;
  Map? cardbg;

  UserSailing.fromJson(Map<String, dynamic> json) {
    pendant = json['pendant'];
    cardbg = json['cardbg'];
  }
}
