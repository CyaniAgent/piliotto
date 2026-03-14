class DynamicsDataModel {
  DynamicsDataModel({
    this.hasMore,
    this.items,
    this.offset,
  });
  bool? hasMore;
  List<DynamicItemModel>? items;
  String? offset;

  DynamicsDataModel.fromJson(Map<String, dynamic> json) {
    hasMore = json['has_more'];
    items = json['items']
        .map<DynamicItemModel>((e) => DynamicItemModel.fromJson(e))
        .toList();
    offset = json['offset'];
  }
}

class DynamicItemModel {
  DynamicItemModel({
    this.idStr,
    this.modules,
    this.type,
  });

  String? idStr;
  ItemModulesModel? modules;
  String? type;

  DynamicItemModel.fromJson(Map<String, dynamic> json) {
    idStr = json['bid'].toString();
    modules = ItemModulesModel.fromJson(json);
    final List? thumbnails = json['thumbnails'];
    if (thumbnails != null && thumbnails.isNotEmpty) {
      type = 'DYNAMIC_TYPE_DRAW';
    } else {
      type = 'DYNAMIC_TYPE_WORD';
    }
  }
}

class ItemModulesModel {
  ItemModulesModel({
    this.moduleAuthor,
    this.moduleDynamic,
    this.moduleStat,
  });

  ModuleAuthorModel? moduleAuthor;
  ModuleDynamicModel? moduleDynamic;
  ModuleStatModel? moduleStat;

  ItemModulesModel.fromJson(Map<String, dynamic> json) {
    moduleAuthor = ModuleAuthorModel.fromJson(json);
    moduleDynamic = ModuleDynamicModel.fromJson(json);
    moduleStat = ModuleStatModel.fromJson(json);
  }
}

class ModuleAuthorModel {
  ModuleAuthorModel({
    this.face,
    this.mid,
    this.name,
    this.pubTime,
  });

  String? face;
  int? mid;
  String? name;
  String? pubTime;

  ModuleAuthorModel.fromJson(Map<String, dynamic> json) {
    face = json['avatar_url'];
    mid = int.tryParse(json['uid']?.toString() ?? '0');
    name = json['username']?.toString();
    pubTime = json['time'];
  }
}

class ModuleDynamicModel {
  ModuleDynamicModel({
    this.desc,
    this.major,
  });

  DynamicDescModel? desc;
  DynamicMajorModel? major;

  ModuleDynamicModel.fromJson(Map<String, dynamic> json) {
    desc = DynamicDescModel.fromJson(json);
    if (json['thumbnails'] != null && json['thumbnails'] is List) {
      major = DynamicMajorModel.fromJson(json);
    }
  }
}

class DynamicDescModel {
  DynamicDescModel({
    this.title,
    this.text,
  });

  String? title;
  String? text;

  DynamicDescModel.fromJson(Map<String, dynamic> json) {
    title = json['title']?.toString() ?? '';
    text = json['content']?.toString() ?? '';
  }
}

class DynamicMajorModel {
  DynamicMajorModel({
    this.draw,
    this.type,
  });

  DynamicDrawModel? draw;
  String? type;

  DynamicMajorModel.fromJson(Map<String, dynamic> json) {
    if (json['thumbnails'] != null && json['thumbnails'] is List) {
      final List<dynamic> thumbnails = json['thumbnails'];
      draw = DynamicDrawModel(
        id: 0,
        items: thumbnails.map((url) {
          return DynamicDrawItemModel(
            src: url.toString(),
            width: 0,
            height: 0,
            size: 0,
          );
        }).toList(),
      );
      type = 'MAJOR_TYPE_DRAW';
    }
  }
}

class DynamicDrawModel {
  DynamicDrawModel({
    this.id,
    this.items,
  });

  int? id;
  List<DynamicDrawItemModel>? items;
}

class DynamicDrawItemModel {
  DynamicDrawItemModel({
    this.height,
    this.size,
    this.src,
    this.width,
  });

  int? height;
  int? size;
  String? src;
  int? width;
}

class ModuleStatModel {
  ModuleStatModel({
    this.comment,
    this.forward,
    this.like,
  });

  Comment? comment;
  ForWard? forward;
  Like? like;

  ModuleStatModel.fromJson(Map<String, dynamic> json) {
    comment = Comment.fromJson(json);
    forward = ForWard.fromJson(json);
    like = Like.fromJson(json);
  }
}

class Comment {
  Comment({
    this.count,
    this.forbidden,
  });

  String? count;
  bool? forbidden;

  Comment.fromJson(Map<String, dynamic> json) {
    count = json['comment_count']?.toString() ?? '0';
    forbidden = false;
  }
}

class ForWard {
  ForWard({this.count, this.forbidden});
  String? count;
  bool? forbidden;

  ForWard.fromJson(Map<String, dynamic> json) {
    count = '0';
    forbidden = false;
  }
}

class Like {
  Like({
    this.count,
    this.forbidden,
    this.status,
  });

  String? count;
  bool? forbidden;
  bool? status;

  Like.fromJson(Map<String, dynamic> json) {
    count = json['like_count']?.toString() ?? '0';
    forbidden = false;
    status = json['if_like'] == 1;
  }
}
