import 'dart:async';
import 'package:automata_app/services/graph_svg/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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

  Future<void> _initializeWebView() async {
    if (_isInitialized) return;
    _isInitialized = true;
    final htmlContent =
        await PlatformAssetBundle().loadString('assets/viz.html');

    final headlessWebView = HeadlessInAppWebView(
      initialData: InAppWebViewInitialData(data: htmlContent),
      onWebViewCreated: (controller) {
        _webViewController = controller;
        _controllerCompleter.complete();
        _isInitialized = true;
      },
      onLoadStop: (controller, url) {
        controller.addJavaScriptHandler(
          handlerName: 'svgDataHandler',
          callback: (args) {
            _svgData = args[0];
          },
        );
      },
      onReceivedError: (controller, request, error) {},
    );

    WidgetsFlutterBinding.ensureInitialized();
    headlessWebView.run();
  }

  Future<String> generateGraphSVG(String dotString) async {
    await _controllerCompleter.future;
    try {
      String escapedDot =
          dotString.replaceAll('\n', '\\n').replaceAll('"', '\\"');
      String jsCode = '''
        (function() {
          if (typeof Viz !== 'undefined') {
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
      return _svgData;
    } catch (e) {
      throw WebViewException('JS Error: $e');
    }
  }
}
