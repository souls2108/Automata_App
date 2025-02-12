import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'dart:developer' as devtools show log;

class GraphvizWebView extends StatefulWidget {
  String dotString;

  @immutable
  GraphvizWebView({super.key, required this.dotString});

  @override
  State<GraphvizWebView> createState() => _GraphvizWebViewState();
}

class _GraphvizWebViewState extends State<GraphvizWebView> {
  InAppWebViewController? _webViewController;
  bool _isWebViewLoaded = false;
  String svgData = '';

  String htmlContent = '''
  <!DOCTYPE html>
  <html>
  <head>
    <script src="assets/graphviz.umd.js"></script>
    <script>
      function renderGraph(dotText) {
        if (typeof Graphviz === "undefined") {
          console.error("Graphviz not loaded");
          return;
        }
        const graphviz = new Graphviz();
        document.getElementById("graph").innerHTML = graphviz.layout(dotText, "svg", "dot");
      }

      window.addEventListener("message", (event) => {
        console.log("Received message");
        console.log(event.data);
        renderGraph(event.data);
      });
    </script>
  </head>
  <body>
    <div id="graph"></div>
  </body>
  </html>
  ''';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialData: InAppWebViewInitialData(data: htmlContent),
      onWebViewCreated: (controller) {
        _webViewController = controller;
      },
      onLoadStop: (controller, url) async {
        String dotText = 'digraph G { A -> B; B -> C; C -> A; }';
        while (true) {
          await _webViewController?.evaluateJavascript(
              source: 'window.postMessage(`$dotText`)');
        }
      },
    );
  }
}
