import 'dart:ffi';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:automata_app/plugin/ffi_plugin/automata_lib.dart';
import 'package:ffi/ffi.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'dart:developer' as devtools show log;

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.deepPurple,
    ),
    home: HomePage(),
  ));
}

class GraphViewer extends StatefulWidget {
  String dotString;

  GraphViewer({required this.dotString});
  @override
  _GraphViewerState createState() => _GraphViewerState();
}

class _GraphViewerState extends State<GraphViewer> {
  InAppWebViewController? webViewController;
  bool _isWebViewLoaded = false;
  String svgData = '';

  String htmlContent = '''
  <!DOCTYPE html>
  <html>
  <head>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/viz.js/2.1.2/viz.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/viz.js/2.1.2/full.render.js"></script>
  </head>
  <body>
    <div id="graph"></div>
  </body>
  </html>
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Graph Renderer")),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: InAppWebView(
                initialData: InAppWebViewInitialData(data: htmlContent),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStop: (controller, url) {
                  setState(() {
                    _isWebViewLoaded = true;
                    devtools.log("WebView loaded!");
                    generateGraph(widget.dotString);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void generateGraph(String dot) async {
    if (webViewController == null || !_isWebViewLoaded) {
      devtools.log("WebView is not ready");
      return;
    }
    devtools.log("Generating graph...");
    try {
      String escapedDot = dot.replaceAll('\n', '\\n').replaceAll('"', '\\"');
      String jsCode = '''
        (function() {
          if (typeof Viz !== 'undefined') {
            console.log("Executing Viz...");
            let viz = new Viz();
            viz.renderSVGElement("$escapedDot")
                .then(function(element) {
                    document.getElementById('graph').appendChild(element);
                })
          } else {
            console.log("Error: Viz.js not loaded");
            return "Error: Viz.js not loaded";
          }
        })();
      ''';
      await webViewController!.evaluateJavascript(source: jsCode);
    } catch (e) {
      devtools.log("Error evaluating JavaScript: $e");
    }
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _regex;
  String _output = '';

  @override
  void initState() {
    _regex = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _regex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _regex,
            decoration: const InputDecoration(
              labelText: 'Regex',
              hintText: 'Enter a regex',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final regexPointer = _regex.text.toNativeUtf8().cast<Char>();
              final dfa =
                  AutomataLib().nativeLibrary.DFA_create_instance(regexPointer);
              final mdfa = AutomataLib().nativeLibrary.DFA_minimalDFA(dfa);
              malloc.free(regexPointer);

              setState(() {
                final outputPointer =
                    AutomataLib().nativeLibrary.DFA_generateDotText(mdfa);
                _output = outputPointer.cast<Utf8>().toDartString();
                malloc.free(outputPointer);
              });

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GraphViewer(dotString: _output),
                ),
              );
            },
            child: const Text('Match'),
          ),
        ],
      ),
    );
  }
}
