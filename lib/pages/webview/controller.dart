import 'package:get/get.dart';
import 'package:piliotto/utils/event_bus.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewController extends GetxController {
  String url = '';
  RxString type = ''.obs;
  String pageTitle = '';
  final WebViewController controller = WebViewController();
  RxInt loadProgress = 0.obs;
  RxBool loadShow = true.obs;
  EventBus eventBus = EventBus();

  @override
  void onInit() {
    super.onInit();
    url = Get.parameters['url']!;
    type.value = Get.parameters['type']!;
    pageTitle = Get.parameters['pageTitle']!;

    if (type.value == 'login') {
      controller.clearCache();
      controller.clearLocalStorage();
      WebViewCookieManager().clearCookies();
    }

    webviewInit();
  }

  void webviewInit() {
    controller
      ..setUserAgent(
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            loadProgress.value = progress;
          },
          onPageStarted: (String url) {},
          onUrlChange: (UrlChange urlChange) async {
            loadShow.value = false;
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('ottohub://')) {
              if (request.url.startsWith('ottohub://video/')) {
                final uri = Uri.parse(request.url);
                if (uri.pathSegments.isNotEmpty) {
                  final vid = int.tryParse(uri.pathSegments[0]);
                  if (vid != null) {
                    Get.offAndToNamed('/video?vid=$vid', arguments: {
                      'pic': '',
                      'heroTag': 'video_$vid',
                    });
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
}
