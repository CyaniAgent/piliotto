import 'package:go_router/go_router.dart';
import 'package:piliotto/router/app_router.dart';
import 'package:piliotto/utils/event_bus.dart';
import 'package:piliotto/utils/route_arguments.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:webview_flutter/webview_flutter.dart';

part 'provider.g.dart';

class WebviewState {
  final String url;
  final String type;
  final String pageTitle;
  final int loadProgress;
  final bool loadShow;

  const WebviewState({
    this.url = '',
    this.type = '',
    this.pageTitle = '',
    this.loadProgress = 0,
    this.loadShow = true,
  });

  WebviewState copyWith({
    String? url,
    String? type,
    String? pageTitle,
    int? loadProgress,
    bool? loadShow,
  }) {
    return WebviewState(
      url: url ?? this.url,
      type: type ?? this.type,
      pageTitle: pageTitle ?? this.pageTitle,
      loadProgress: loadProgress ?? this.loadProgress,
      loadShow: loadShow ?? this.loadShow,
    );
  }
}

@riverpod
class WebviewNotifier extends _$WebviewNotifier {
  final WebViewController controller = WebViewController();
  EventBus eventBus = EventBus();

  @override
  WebviewState build() {
    final url = routeArguments.queryParameters['url'] ?? '';
    final type = routeArguments.queryParameters['type'] ?? '';
    final pageTitle = routeArguments.queryParameters['pageTitle'] ?? '';

    if (type == 'login') {
      controller.clearCache();
      controller.clearLocalStorage();
      WebViewCookieManager().clearCookies();
    }

    webviewInit(url);

    return WebviewState(
      url: url,
      type: type,
      pageTitle: pageTitle,
    );
  }

  void webviewInit(String url) {
    controller
      ..setUserAgent(
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            state = state.copyWith(loadProgress: progress);
          },
          onPageStarted: (String url) {},
          onUrlChange: (UrlChange urlChange) async {
            state = state.copyWith(loadShow: false);
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('ottohub://')) {
              if (request.url.startsWith('ottohub://video/')) {
                final uri = Uri.parse(request.url);
                if (uri.pathSegments.isNotEmpty) {
                  final vid = int.tryParse(uri.pathSegments[0]);
                  if (vid != null) {
                    final ctx = rootNavigatorKey.currentContext;
                    if (ctx != null) {
                      ctx.go('/video?vid=$vid');
                    }
                  }
                }
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url.startsWith('http') ? url : 'https://$url'));
  }

  void setLoadShow(bool value) {
    state = state.copyWith(loadShow: value);
  }
}
