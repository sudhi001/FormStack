import 'package:flutter/material.dart';
import 'package:formstack/src/step/display_step.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Renders the page a [DisplayStep] points at.
class WebViewBuild {
  const WebViewBuild._();

  /// Builds the web view for [formStep].
  static Widget buildView(BuildContext context, DisplayStep formStep) =>
      _DisplayStepWebView(url: formStep.url);
}

/// Holds one [WebViewController] for as long as the step is on screen.
///
/// The controller used to be constructed inside a static `buildView` called
/// straight from `build()`, so every rebuild created another native web view
/// and issued another `loadRequest` — repeated network loads, and a platform
/// view leaked per rebuild. Creating it in [State.initState] ties it to the
/// element instead, so it is created once and released with the widget.
class _DisplayStepWebView extends StatefulWidget {
  const _DisplayStepWebView({required this.url});

  final String url;

  @override
  State<_DisplayStepWebView> createState() => _DisplayStepWebViewState();
}

class _DisplayStepWebViewState extends State<_DisplayStepWebView> {
  late final WebViewController _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse(widget.url));

  @override
  void didUpdateWidget(_DisplayStepWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reuse the controller and just navigate when only the URL changes.
    if (oldWidget.url != widget.url) {
      _controller.loadRequest(Uri.parse(widget.url));
    }
  }

  @override
  Widget build(BuildContext context) => WebViewWidget(controller: _controller);
}
