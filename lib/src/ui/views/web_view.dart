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
}
