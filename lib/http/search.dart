import 'package:piliotto/http/video.dart';

class SearchHttp {
  static Future<int> ab2c({int? aid, String? bvid}) async {
    if (bvid == null) {
      return -1;
    }
    
    var result = await VideoHttp.videoIntro(bvid: bvid);
    if (result['status']) {
      return result['data'].cid!;
    }
    return -1;
  }
  
  static Future<Map<String, dynamic>> ab2cWithPic({String? bvid}) async {
    if (bvid == null) {
      return {'cid': -1, 'pic': null};
    }
    
    var result = await VideoHttp.videoIntro(bvid: bvid);
    if (result['status']) {
      return {
        'cid': result['data'].cid!,
        'pic': result['data'].pic!
      };
    }
    return {'cid': -1, 'pic': null};
  }
}
