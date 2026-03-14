import 'content.dart';
import 'member.dart';

class ReplyItemModel {
  ReplyItemModel({
    this.rpid,
    this.oid,
    this.type,
    this.mid,
    this.root,
    this.parent,
    this.dialog,
    this.count,
    this.floor,
    this.state,
    this.fansgrade,
    this.attr,
    this.ctime,
    this.rpidStr,
    this.rootStr,
    this.parentStr,
    this.like,
    this.action,
    this.member,
    this.content,
    this.replies,
    this.assist,
    this.upAction,
    this.invisible,
    this.replyControl,
    this.isUp,
    this.isTop,
    this.cardLabel,
  });

  int? rpid;
  int? oid;
  int? type;
  int? mid;
  int? root;
  int? parent;
  int? dialog;
  int? count;
  int? floor;
  int? state;
  int? fansgrade;
  int? attr;
  int? ctime;
  String? rpidStr;
  String? rootStr;
  String? parentStr;
  int? like;
  int? action;
  ReplyMember? member;
  ReplyContent? content;
  List? replies;
  int? assist;
  UpAction? upAction;
  bool? invisible;
  ReplyControl? replyControl;
  bool? isUp;
  bool? isTop = false;
  List? cardLabel;

  ReplyItemModel.fromJson(Map<String, dynamic> json, upperMid,
      {isTopStatus = false}) {
    rpid = json['rpid'];
    oid = json['oid'];
    type = json['type'];
    mid = json['mid'];
    root = json['root'];
    parent = json['parent'];
    dialog = json['dialog'];
    count = json['count'];
    floor = json['floor'];
    state = json['state'];
    fansgrade = json['fansgrade'];
    attr = json['attr'];
    ctime = json['ctime'];
    rpidStr = json['rpid_str'];
    rootStr = json['root_str'];
    parentStr = json['parent_str'];
    like = json['like'];
    action = json['action'];
    member = json['member'] != null
        ? ReplyMember.fromJson(json['member'])
        : ReplyMember(mid: '', uname: '', sign: '', avatar: '', level: 1);
    content = json['content'] != null
        ? ReplyContent.fromJson(json['content'])
        : ReplyContent(message: '');
    replies = json['replies'] != null
        ? json['replies']
            .map((item) => ReplyItemModel.fromJson(item, upperMid))
            .toList()
        : [];
    assist = json['assist'];
    upAction = json['up_action'] != null
        ? UpAction.fromJson(json['up_action'])
        : UpAction(like: false, reply: false);
    invisible = json['invisible'];
    replyControl = json['reply_control'] == null
        ? null
        : ReplyControl.fromJson(json['reply_control']);
    isUp = json['member'] != null
        ? upperMid.toString() == json['member']['mid']
        : false;
    isTop = isTopStatus;
    cardLabel = json['card_label'] != null
        ? json['card_label'].map((e) => e['text_content']).toList()
        : [];
  }

  // 从Ottohub API返回的数据创建ReplyItemModel
  ReplyItemModel.fromOttohubJson(Map<String, dynamic> json) {
    rpid = int.tryParse(json['bcid']?.toString() ?? '0');
    rpidStr = json['bcid']?.toString();
    mid = int.tryParse(json['uid']?.toString() ?? '0');
    parent = int.tryParse(json['parent_bcid']?.toString() ?? '0');
    parentStr = json['parent_bcid']?.toString();
    root = parent;
    rootStr = parentStr;
    like = 0;
    count = json['child_comment_num'];
    ctime = 0;
    member = ReplyMember(
      mid: json['uid']?.toString() ?? '',
      uname: json['username']?.toString() ?? '未知用户',
      sign: '',
      avatar: json['avatar_url']?.toString() ?? '',
      level: 1,
      vip: {'vipStatus': 0, 'vipType': 0},
      officialVerify: {},
      userSailing: UserSailing(),
      ottohubData: {
        'honour': json['honour'],
      },
    );
    content = ReplyContent.fromJson({
      'message': json['content']?.toString() ?? '',
    });
    replies = [];
    upAction = UpAction(like: false, reply: false);
    invisible = false;
    isUp = false;
    isTop = false;
    cardLabel = [];
    replyControl = ReplyControl(
      time: json['time']?.toString(),
    );
  }
}

class UpAction {
  UpAction({this.like, this.reply});

  bool? like;
  bool? reply;

  UpAction.fromJson(Map<String, dynamic> json) {
    like = json['like'];
    reply = json['reply'];
  }
}

class ReplyControl {
  ReplyControl({
    this.upReply,
    this.isUpTop,
    this.upLike,
    this.isShow,
    this.entryText,
    this.titleText,
    this.time,
    this.location,
  });

  bool? upReply;
  bool? isUpTop;
  bool? upLike;
  bool? isShow;
  String? entryText;
  String? titleText;
  String? time;
  String? location;

  ReplyControl.fromJson(Map<String, dynamic> json) {
    upReply = json['up_reply'] ?? false;
    isUpTop = json['is_up_top'] ?? false;
    upLike = json['up_like'] ?? false;
    if (json['sub_reply_entry_text'] != null) {
      final RegExp regex = RegExp(r"\d+");
      final RegExpMatch match = regex.firstMatch(
          json['sub_reply_entry_text'] == null
              ? ''
              : json['sub_reply_entry_text']!)!;
      isShow = int.parse(match.group(0)!) >= 3;
    } else {
      isShow = false;
    }

    entryText = json['sub_reply_entry_text'];
    titleText = json['sub_reply_title_text'];
    time = json['time_desc'];
    location = json['location'] != null ? json['location'].split('：')[1] : '';
  }
}
