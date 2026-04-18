class MemberArchiveDataModel {
  MemberArchiveDataModel({
    this.list,
    this.page,
  });

  ArchiveListModel? list;
  Map? page;

  MemberArchiveDataModel.fromJson(Map<String, dynamic> json) {
    list = ArchiveListModel.fromJson(json['list']);
    page = json['page'];
  }
}

class ArchiveListModel {
  ArchiveListModel({
    this.tlist,
    this.vlist,
  });

  Map<String, TListItemModel>? tlist;
  List<VListItemModel>? vlist;

  ArchiveListModel.fromJson(Map<String, dynamic> json) {
    tlist = json['tlist'] != null
        ? Map.from(json['tlist']).map((k, v) =>
            MapEntry<String, TListItemModel>(k, TListItemModel.fromJson(v)))
        : {};
    vlist = json['vlist']
        .map<VListItemModel>((e) => VListItemModel.fromJson(e))
        .toList();
  }
}

class TListItemModel {
  TListItemModel({
    this.tid,
    this.count,
    this.name,
  });

  int? tid;
  int? count;
  String? name;

  TListItemModel.fromJson(Map<String, dynamic> json) {
    tid = _parseInt(json['tid']);
    count = _parseInt(json['count']);
    name = json['name'];
  }
}

class VListItemModel {
  VListItemModel({
    this.comment,
    this.typeid,
    this.play,
    this.pic,
    this.subtitle,
    this.description,
    this.copyright,
    this.title,
    this.review,
    this.author,
    this.mid,
    this.created,
    this.pubdate,
    this.length,
    this.duration,
    this.videoReview,
    this.vid,
    this.aid,
    this.bvid,
    this.cid,
    this.hideClick,
    this.isChargingSrc,
    this.rcmdReason,
    this.owner,
  });

  int? comment;
  int? typeid;
  int? play;
  String? pic;
  String? subtitle;
  String? description;
  String? copyright;
  String? title;
  int? review;
  String? author;
  int? mid;
  int? created;
  int? pubdate;
  String? length;
  String? duration;
  int? videoReview;
  int? vid;
  int? aid;
  String? bvid;
  int? cid;
  bool? hideClick;
  bool? isChargingSrc;
  Stat? stat;
  String? rcmdReason;
  Owner? owner;

  VListItemModel.fromJson(Map<String, dynamic> json) {
    comment = _parseInt(json['comment_count'] ?? json['comment']);
    typeid = _parseInt(json['type'] ?? json['typeid']);
    play = _parseInt(json['view_count'] ?? json['play']);
    pic = json['cover_url'] ?? json['pic'];
    subtitle = json['subtitle'];
    description = json['intro'] ?? json['description'];
    copyright = json['copyright'];
    title = json['title'];
    review = _parseInt(json['like_count'] ?? json['review']);
    author = json['username'] ?? json['author'];
    mid = _parseInt(json['uid'] ?? json['mid']);
    created = json['time'] != null
        ? DateTime.parse(json['time']).millisecondsSinceEpoch ~/ 1000
        : _parseInt(json['created']);
    pubdate = created;
    length = json['duration']?.toString() ?? json['length'];
    duration = length;
    videoReview = _parseInt(json['danmaku_count'] ?? json['video_review']);
    vid = _parseInt(json['vid']);
    aid = _parseInt(json['aid']);
    bvid = json['bvid'];
    cid = null;
    hideClick = json['hide_click'];
    isChargingSrc = json['is_charging_arc'];
    stat = Stat.fromJson(json);
    rcmdReason = null;
    owner = Owner.fromJson(json);
  }
}

class Stat {
  Stat({
    this.view,
    this.danmaku,
  });

  int? view;
  int? danmaku;

  Stat.fromJson(Map<String, dynamic> json) {
    view = _parseInt(json['view_count'] ?? json["play"]);
    danmaku = _parseInt(json['danmaku_count'] ?? json['video_review']);
  }
}

class Owner {
  Owner({
    this.mid,
    this.name,
    this.face,
  });
  int? mid;
  String? name;
  String? face;

  Owner.fromJson(Map<String, dynamic> json) {
    mid = _parseInt(json['uid'] ?? json["mid"]);
    name = json['username'] ?? json["author"];
    face = json['avatar_url'] ?? '';
  }
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}
