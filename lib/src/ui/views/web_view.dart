import 'package:flutter/material.dart';
import 'package:formstack/src/step/display_step.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewBuild {
  static Widget buildView(BuildContext context, DisplayStep formStep) {
    final WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(formStep.url));

    return WebViewWidget(controller: controller);
  }

  // if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
  //   return WebViewX(
  //     key: const ValueKey('webviewx'),
  //     initialSourceType: SourceType.url,
  //     height: min(
  //         MediaQuery.of(context).size.height - kToolbarHeight * 0.8, 1024),
  //     width: min(MediaQuery.of(context).size.width * 0.8, 1024),
  //     onWebViewCreated: (controller) async {
  //       controller.loadContent(formStep.url, SourceType.url);
  //     },
  //     onPageStarted: (src) =>
  //         debugPrint('A new page has started loading: $src\n'),
  //     onPageFinished: (src) =>
  //         debugPrint('The page has finished loading: $src\n'),
  //     jsContent: const {},
  //     dartCallBacks: const {},
  //     webSpecificParams: const WebSpecificParams(
  //       printDebugInfo: true,
  //     ),
  //     mobileSpecificParams: const MobileSpecificParams(
  //       androidEnableHybridComposition: true,
  //     ),
  //     navigationDelegate: (navigation) {
  //       debugPrint(navigation.content.sourceType.toString());
  //       return NavigationDecision.navigate;
  //     },
  //   );
  // } else {
  //   return ConstrainedBox(
  //       constraints: const BoxConstraints(maxWidth: 500.0),
  //       child: const Text("Unsupported platfom"));
  // }
}
