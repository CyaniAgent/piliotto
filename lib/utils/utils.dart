// 工具函数
// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/github/latest.dart';

class Utils {
  static final Random random = Random();

  static Future<String> getCookiePath() async {
    final Directory tempDir = await getApplicationSupportDirectory();
    final String tempPath = "${tempDir.path}/.plpl/";
    final Directory dir = Directory(tempPath);
    final bool b = await dir.exists();
    if (!b) {
      dir.createSync(recursive: true);
    }
    return tempPath;
  }

  static String numFormat(dynamic number) {
    if (number == null) {
      return '0';
    }
    if (number is String) {
      return number;
    }
    final String res = (number / 10000).toString();
    if (int.parse(res.split('.')[0]) >= 1) {
      return '${(number / 10000).toStringAsFixed(1)}万';
    } else {
      return number.toString();
    }
  }

  static String timeFormat(dynamic time) {
    // 1小时内
    if (time is String && time.contains(':')) {
      return time;
    }
    if (time < 3600) {
      if (time == 0) {
        return '00:00';
      }
      final int minute = time ~/ 60;
      final double res = time / 60;
      if (minute != res) {
        return '${minute < 10 ? '0$minute' : minute}:${(time - minute * 60) < 10 ? '0${(time - minute * 60)}' : (time - minute * 60)}';
      } else {
        return '$minute:00';
      }
    } else {
      final int hour = time ~/ 3600;
      final String hourStr = hour < 10 ? '0$hour' : hour.toString();
      var a = timeFormat(time - hour * 3600);
      return '$hourStr:$a';
    }
  }

  // 完全相对时间显示
  static String formatTimestampToRelativeTime(dynamic timeStamp) {
    int timestamp = _convertToTimestamp(timeStamp);
    var difference = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000));

    if (difference.inDays > 365) {
      return '${difference.inDays ~/ 365}年前';
    } else if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30}个月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  // 时间显示，刚刚，x分钟前
  static String dateFormat(dynamic timeStamp, {formatType = 'list'}) {
    if (timeStamp == 0 || timeStamp == null || timeStamp == '') {
      return '';
    }
    // 当前时间
    int time = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    // 对比
    int timestamp = _convertToTimestamp(timeStamp);
    int distance = (time - timestamp).toInt();
    // 当前年日期
    String currentYearStr = 'MM月DD日 hh:mm';
    String lastYearStr = 'YY年MM月DD日 hh:mm';
    if (formatType == 'detail') {
      currentYearStr = 'MM-DD hh:mm';
      lastYearStr = 'YY-MM-DD hh:mm';
      return CustomStamp_str(
          timestamp: timestamp,
          date: lastYearStr,
          toInt: false,
          formatType: formatType);
    }
    if (distance <= 60) {
      return '刚刚';
    } else if (distance <= 3600) {
      return '${(distance / 60).floor()}分钟前';
    } else if (distance <= 43200) {
      return '${(distance / 60 / 60).floor()}小时前';
    } else if (DateTime.fromMillisecondsSinceEpoch(time * 1000).year ==
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).year) {
      return CustomStamp_str(
          timestamp: timestamp,
          date: currentYearStr,
          toInt: false,
          formatType: formatType);
    } else {
      return CustomStamp_str(
          timestamp: timestamp,
          date: lastYearStr,
          toInt: false,
          formatType: formatType);
    }
  }

  // 时间戳转时间
  static String CustomStamp_str(
      {dynamic timestamp, // 为空则显示当前时间
      String? date, // 显示格式，比如：'YY年MM月DD日 hh:mm:ss'
      bool toInt = true, // 去除0开头
      String? formatType}) {
    int ts = _convertToTimestamp(timestamp);
    if (ts == 0) {
      ts = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    }
    String timeStr =
        (DateTime.fromMillisecondsSinceEpoch(ts * 1000)).toString();

    dynamic dateArr = timeStr.split(' ')[0];
    dynamic timeArr = timeStr.split(' ')[1];

    String YY = dateArr.split('-')[0];
    String MM = dateArr.split('-')[1];
    String DD = dateArr.split('-')[2];

    String hh = timeArr.split(':')[0];
    String mm = timeArr.split(':')[1];
    String ss = timeArr.split(':')[2];

    ss = ss.split('.')[0];

    // 去除0开头
    if (toInt) {
      MM = (int.parse(MM)).toString();
      DD = (int.parse(DD)).toString();
      hh = (int.parse(hh)).toString();
      mm = (int.parse(mm)).toString();
    }

    if (date == null) {
      return timeStr;
    }

    // if (formatType == 'list' && int.parse(DD) > DateTime.now().day - 2) {
    //   return '昨天';
    // }

    date = date
        .replaceAll('YY', YY)
        .replaceAll('MM', MM)
        .replaceAll('DD', DD)
        .replaceAll('hh', hh)
        .replaceAll('mm', mm)
        .replaceAll('ss', ss);
    if (int.parse(YY) == DateTime.now().year &&
        int.parse(MM) == DateTime.now().month) {
      // 当天
      if (int.parse(DD) == DateTime.now().day) {
        return '今天';
      }
    }
    return date;
  }

  // 转换为时间戳
  static int _convertToTimestamp(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        // 尝试解析日期字符串
        try {
          DateTime date = DateTime.parse(value);
          return (date.millisecondsSinceEpoch / 1000).round();
        } catch (e) {
          return 0;
        }
      }
    }
    if (value is DateTime) {
      return (value.millisecondsSinceEpoch / 1000).round();
    }
    return 0;
  }

  static String makeHeroTag(dynamic v) {
    return v.toString() + random.nextInt(9999).toString();
  }

  static int duration(String duration) {
    List timeList = duration.split(':');
    int len = timeList.length;
    if (len == 2) {
      return int.parse(timeList[0]) * 60 + int.parse(timeList[1]);
    }
    if (len == 3) {
      return int.parse(timeList[0]) * 3600 +
          int.parse(timeList[1]) * 60 +
          int.parse(timeList[2]);
    }
    return 0;
  }

  static int findClosestNumber(int target, List<int> numbers) {
    int minDiff = 127;
    int closestNumber = 0; // 初始化为0，表示没有找到比目标值小的整数

    if (numbers.contains(target)) {
      return target;
    }
    // 向下查找
    try {
      for (int number in numbers) {
        if (number < target) {
          int diff = target - number; // 计算目标值与当前整数的差值
          if (diff < minDiff) {
            minDiff = diff;
            closestNumber = number;
            return closestNumber;
          }
        }
      }
    } catch (_) {}

    // 向上查找
    if (closestNumber == 0) {
      try {
        for (int number in numbers) {
          int diff = (number - target).abs();

          if (diff < minDiff) {
            minDiff = diff;
            closestNumber = number;
          }
        }
      } catch (_) {}
    }
    return closestNumber;
  }

  // 版本对比
  static bool needUpdate(String localVersion, String remoteVersion) {
    List<String> localVersionList = localVersion.split('.');
    List<String> remoteVersionList = remoteVersion.split('v')[1].split('.');
    for (int i = 0; i < localVersionList.length; i++) {
      int localVersion = int.parse(localVersionList[i]);
      int remoteVersion = int.parse(remoteVersionList[i]);
      if (remoteVersion > localVersion) {
        return true;
      } else if (remoteVersion < localVersion) {
        return false;
      }
    }
    return false;
  }

  // 检查更新
  static Future<bool> checkUpdata() async {
    SmartDialog.dismiss();
    var currentInfo = await PackageInfo.fromPlatform();
    var dio = Dio();
    var result = await dio.get('https://api.github.com/repos/CyaniAgent/piliotto/releases/latest');
    if (result.data == null || result.data.isEmpty) {
      SmartDialog.showToast('获取远程版本失败，请检查网络');
      return false;
    }
    LatestDataModel data = LatestDataModel.fromJson(result.data);
    bool isUpdate = Utils.needUpdate(currentInfo.version, data.tagName!);
    if (isUpdate) {
      SmartDialog.show(
        animationType: SmartAnimationType.centerFade_otherSlide,
        builder: (context) {
          return AlertDialog(
            title: const Text('🎉 发现新版本 '),
            content: SizedBox(
              height: 280,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.tagName!,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(data.body!),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => SmartDialog.dismiss(),
                child: Text(
                  '稍后',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.outline),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await SmartDialog.dismiss();
                  launchUrl(
                    Uri.parse('https://www.123pan.com/s/9sVqVv-flu0A.html'),
                    mode: LaunchMode.externalApplication,
                  );
                },
                child: const Text('网盘'),
              ),
              TextButton(
                onPressed: () => matchVersion(data),
                child: const Text('Github'),
              ),
            ],
          );
        },
      );
    }
    return true;
  }

  // 下载适用于当前系统的安装包
  static Future<void> matchVersion(dynamic data) async {
    await SmartDialog.dismiss();
    // 获取设备信息
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      // [arm64-v8a]
      String abi = androidInfo.supportedAbis.first;
      late String downloadUrl;
      if (data.assets.isNotEmpty) {
        for (var i in data.assets) {
          if (i.downloadUrl.contains(abi)) {
            downloadUrl = i.downloadUrl;
          }
        }
        // 应用外下载
        launchUrl(
          Uri.parse(downloadUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    }
  }

  // 时间戳转时间
  static String tampToSeektime(int number) {
    int hours = number ~/ 60;
    int minutes = number % 60;

    String formattedHours = hours.toString().padLeft(2, '0');
    String formattedMinutes = minutes.toString().padLeft(2, '0');

    return '$formattedHours:$formattedMinutes';
  }

  static String appSign(
      Map<String, dynamic> params, String appkey, String appsec) {
    params['appkey'] = appkey;
    var searchParams = Uri(queryParameters: params).query;
    var sortedParams = searchParams.split('&')..sort();
    var sortedQueryString = sortedParams.join('&');

    var appsecString = sortedQueryString + appsec;
    var md5Digest = md5.convert(utf8.encode(appsecString));
    var md5String = md5Digest.toString(); // 获取MD5哈希值

    return md5String;
  }

  static List<int> generateRandomBytes(int minLength, int maxLength) {
    return List<int>.generate(random.nextInt(maxLength - minLength + 1),
        (_) => random.nextInt(0x60) + 0x20);
  }

  static String base64EncodeRandomString(int minLength, int maxLength) {
    List<int> randomBytes = generateRandomBytes(minLength, maxLength);
    return base64.encode(randomBytes);
  }

  static List<int> matchNum(String str) {
    final RegExp regExp = RegExp(r'\d+');
    final Iterable<Match> matches = regExp.allMatches(str);

    return matches.map((Match match) => int.parse(match.group(0)!)).toList();
  }
}
