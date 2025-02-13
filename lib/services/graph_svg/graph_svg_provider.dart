import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:developer' as devtools show log;

import 'package:flutter_svg/flutter_svg.dart';

class GraphSvgProvider {
  static final GraphSvgProvider _instance = GraphSvgProvider._internal();

  bool _isInitialized = false;

  GraphSvgProvider._internal() {
    _initializeWebView();
  }

  static GraphSvgProvider get instance => _instance;

  final Completer<void> _controllerCompleter = Completer<void>();
  late InAppWebViewController _webViewController;
  String _svgData = '';

  void _initializeWebView() {
    if (_isInitialized) return;
    _isInitialized = true;
    devtools.log("Initializing Web View");

    final headlessWebView = HeadlessInAppWebView(
      initialData: InAppWebViewInitialData(data: htmlContent),
      onWebViewCreated: (controller) {
        _webViewController = controller;
        _controllerCompleter.complete();
        _isInitialized = true;
        devtools.log("Web View created");
      },
      onLoadStop: (controller, url) {
        controller.addJavaScriptHandler(
          handlerName: 'svgDataHandler',
          callback: (args) {
            devtools.log("SVG Data received");
            _svgData = args[0];
          },
        );
      },
      onReceivedError: (controller, request, error) {
        devtools.log("Error loading web view: $error");
      },
    );

    WidgetsFlutterBinding.ensureInitialized();
    headlessWebView.run();
  }

  Widget generate(String dotString) {
    return FutureBuilder<Widget>(
      future: generateGraphSVG(dotString),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return snapshot.data ?? SizedBox.shrink();
        }
      },
    );
  }

  Future<Widget> generateGraphSVG(String dotString) async {
    devtools.log("Generating graph...");
    await _controllerCompleter.future;
    try {
      String escapedDot =
          dotString.replaceAll('\n', '\\n').replaceAll('"', '\\"');
      String jsCode = '''
        (function() {
          if (typeof Viz !== 'undefined') {
            console.log("Executing Viz...");
            let viz = new Viz();
            viz.renderSVGElement("$escapedDot")
                .then(function(element) {
                    let svgData = new XMLSerializer().serializeToString(element);
                    window.flutter_inappwebview.callHandler('svgDataHandler', svgData);
                })
                .catch(error => {
                    console.error(error);
                });
          } else {
            console.log("Error: Viz.js not loaded");
          }
        })();
      ''';
      await _webViewController.evaluateJavascript(source: jsCode);
      final svgWidget = SvgPicture.string(_svgData);
      return svgWidget;
    } catch (e) {
      devtools.log("Error evaluating JavaScript: $e");
      return Text("Error: $e");
    }
  }
}

const htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/viz.js/2.1.2/viz.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/viz.js/2.1.2/full.render.js"></script>
</head>
<body>
</body>
</html>
''';
