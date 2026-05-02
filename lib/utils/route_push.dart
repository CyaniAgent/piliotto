import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:piliotto/router/app_router.dart';

class RoutePush {
  static Future<void> loginPush() async {
    final BuildContext? context = rootNavigatorKey.currentContext;
    if (context != null) {
      context.push('/loginPage');
    }
  }

  static Future<void> loginRedirectPush() async {
    final BuildContext? context = rootNavigatorKey.currentContext;
    if (context != null) {
      context.push('/loginPage');
    }
  }
}
