import 'package:piliotto/models/video/play/url.dart';

class VideoUtils {
  static String getCdnUrl(dynamic item) {
    var backupUrl = "";
    var videoUrl = "";

    if (item is VideoItem) {
      backupUrl = item.backupUrl ?? "";
      videoUrl = backupUrl.contains("http") ? backupUrl : (item.baseUrl ?? "");
    } else if (item is AudioItem) {
      backupUrl = item.backupUrl ?? "";
      videoUrl = backupUrl.contains("http") ? backupUrl : (item.baseUrl ?? "");
    } else {
      return "";
    }

    if (videoUrl.contains(".mcdn.bilivideo")) {
      videoUrl =
          'https://proxy-tf-all-ws.bilivideo.com/?url=${Uri.encodeComponent(videoUrl)}';
    } else if (videoUrl.contains("/upgcxcode/")) {
      var cdnList = {
        'ali': 'upos-sz-mirrorali.bilivideo.com',
        'cos': 'upos-sz-mirrorcos.bilivideo.com',
        'hw': 'upos-sz-mirrorhw.bilivideo.com',
      };
      var cdn = cdnList['ali'] ?? "";
      var reg = RegExp(r'(http|https)://(.*?)/upgcxcode/');
      videoUrl = videoUrl.replaceAll(reg, "https://$cdn/upgcxcode/");
    }

    return videoUrl;
  }
}
