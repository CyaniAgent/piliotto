import 'package:get/get.dart';

class RoutePush {
  static Future<void> loginPush() async {
    await Get.toNamed('/loginPage');
  }

  static Future<void> loginRedirectPush() async {
    await Get.offAndToNamed('/loginPage');
  }
}
