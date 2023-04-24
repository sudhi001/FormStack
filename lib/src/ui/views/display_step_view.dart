import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/step/display_step.dart';
import 'package:formstack/src/ui/views/base_step_view.dart';
import 'package:webviewx/webviewx.dart';

// ignore: must_be_immutable
class DisplayStepView extends BaseStepView<DisplayStep> {
  DisplayStepView(super.formKitForm, super.formStep, super.text,
      {super.key, super.title, super.display = Display.normal, cancellable});

  @override
  Widget? buildWInputWidget(BuildContext context, DisplayStep formStep) {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      return WebViewX(
        key: const ValueKey('webviewx'),
        initialSourceType: SourceType.url,
        height: min(
            MediaQuery.of(context).size.height - kToolbarHeight * 0.8, 1024),
        width: min(MediaQuery.of(context).size.width * 0.8, 1024),
        onWebViewCreated: (controller) async {
          controller.loadContent(formStep.url, SourceType.url);
        },
        onPageStarted: (src) =>
            debugPrint('A new page has started loading: $src\n'),
        onPageFinished: (src) =>
            debugPrint('The page has finished loading: $src\n'),
        jsContent: const {},
        dartCallBacks: const {},
        webSpecificParams: const WebSpecificParams(
          printDebugInfo: true,
        ),
        mobileSpecificParams: const MobileSpecificParams(
          androidEnableHybridComposition: true,
        ),
        navigationDelegate: (navigation) {
          debugPrint(navigation.content.sourceType.toString());
          return NavigationDecision.navigate;
        },
      );
    } else {
      return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500.0),
          child: const Text("Unsupported platfom"));
    }
  }

  @override
  bool isValid() {
    return true;
  }

  @override
  String validationError() {
    return "";
  }

  @override
  resultValue() {
    return DateTime.now();
  }

  @override
  void clearFocus() {}
}
