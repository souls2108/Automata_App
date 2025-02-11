import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'dart:developer' as devtools show log;

class GraphvizWebView extends StatefulWidget {
  final String dotText;

  @immutable
  const GraphvizWebView({super.key, required this.dotText});

  @override
  State<GraphvizWebView> createState() => _GraphvizWebViewState();
}

class _GraphvizWebViewState extends State<GraphvizWebView> {
  late InAppWebViewController _webViewController;
  late String _htmlContent;
  late String _jsContent;

  @override
  void initState() {
    super.initState();
    loadHtmlAndJs();
  }

  Future<void> loadHtmlAndJs() async {
    _htmlContent = await rootBundle.loadString("assets/viz.html");
    _jsContent = await rootBundle.loadString("assets/viz.js");
    devtools.log("JS Loaded -> ${_jsContent[10]}");

    String injectedHtml = _htmlContent.replaceFirst(
      '<script id="graphviz-script"></script>',
      '<script>${_jsContent}</script>',
    );

    _webViewController.loadData(
        data: injectedHtml, mimeType: "text/html", encoding: "utf-8");
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialSettings: InAppWebViewSettings(
        mediaPlaybackRequiresUserGesture: false,
        useHybridComposition: true,
        allowsInlineMediaPlayback: true,
      ),
      onWebViewCreated: (controller) {
        _webViewController = controller;
        _webViewController.addJavaScriptHandler(
          handlerName: "getGraphData",
          callback: (args) {
            return widget.dotText;
          },
        );
        loadHtmlAndJs();
      },
    );
  }
}
