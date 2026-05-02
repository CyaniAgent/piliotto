import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:piliotto/pages/webview/provider.dart';
import 'package:piliotto/utils/login.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewPage extends ConsumerWidget {
  const WebviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(webviewProvider);
    final notifier = ref.read(webviewProvider.notifier);

    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          titleSpacing: 0,
          title: Text(
            state.pageTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          actions: [
            const SizedBox(width: 4),
            IconButton(
              onPressed: () {
                notifier.controller.reload();
              },
              icon: Icon(Icons.refresh_outlined,
                  color: Theme.of(context).colorScheme.primary),
            ),
            IconButton(
              onPressed: () {
                launchUrl(Uri.parse(state.url));
              },
              icon: Icon(Icons.open_in_browser_outlined,
                  color: Theme.of(context).colorScheme.primary),
            ),
            if (state.type == 'login')
              TextButton(
                onPressed: () => LoginUtils.confirmLogin(
                    null, notifier.controller),
                child: const Text('刷新登录状态'),
              ),
            const SizedBox(width: 12)
          ],
        ),
        body: Column(
          children: [
            AnimatedContainer(
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 350),
              height: state.loadShow ? 4 : 0,
              child: LinearProgressIndicator(
                key: ValueKey(state.loadProgress),
                value: state.loadProgress / 100,
              ),
            ),
            if (state.type == 'login')
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.onInverseSurface,
                padding: const EdgeInsets.only(
                    left: 12, right: 12, top: 6, bottom: 6),
                child: const Text('登录成功未自动跳转?  请点击右上角「刷新登录状态」'),
              ),
            Expanded(
              child: WebViewWidget(controller: notifier.controller),
            ),
          ],
        ));
  }
}
