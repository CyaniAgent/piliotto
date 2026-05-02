import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouterHelper {
  static void toNamed(BuildContext context, String path,
      {Map<String, dynamic>? arguments, Map<String, String>? parameters}) {
    if (parameters != null && parameters.isNotEmpty) {
      final queryString = parameters.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      path = '$path?$queryString';
    }

    context.push(path, extra: arguments);
  }

  /// 返回上一页
  static void back(BuildContext context) {
    context.pop();
  }

  /// 替换当前路由
  static void offNamed(BuildContext context, String path,
      {Map<String, dynamic>? arguments}) {
    context.push(path, extra: arguments);
  }

  /// 清空路由栈并跳转
  static void offAllNamed(BuildContext context, String path,
      {Map<String, dynamic>? arguments}) {
    context.go(path, extra: arguments);
  }
}
