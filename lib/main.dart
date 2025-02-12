import 'dart:ffi';

import 'package:automata_app/widgets/graphviz_webview_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:automata_app/plugin/ffi_plugin/automata_lib.dart';
import 'package:ffi/ffi.dart';

import 'dart:developer' as devtools show log;

import 'package:flutter_svg/flutter_svg.dart';

void main() {
  const String dotString = '''
digraph finite_state_machine {
          fontname="Helvetica,Arial,sans-serif"
          node [fontname="Helvetica,Arial,sans-serif"]
          edge [fontname="Helvetica,Arial,sans-serif"]
          rankdir=LR;
          node [shape = doublecircle];
          node [shape = doublecircle]; -1;
          node [shape = circle];
      	 0 -> -1 [label = "a"];
      
      }
''';
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.deepPurple,
    ),
    home: GraphViewer(dotString: dotString),
  ));
}

class GraphViewer extends StatefulWidget {
  String dotString;

  GraphViewer({super.key, required this.dotString});
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
  void initState() {
    super.initState();
    // Add JavaScript handler
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Center(
            child: SvgPicture.string(svgData),
          ),
          Text("Webview loaded: $_isWebViewLoaded"),
          Expanded(
            child: InAppWebView(
              initialData: InAppWebViewInitialData(data: htmlContent),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStop: (controller, url) {
                controller.addJavaScriptHandler(
                  handlerName: 'svgDataHandler',
                  callback: (args) {
                    devtools.log("SVG Data received");
                    setState(() {
                      svgData = args[0];
                      devtools.log(svgData.substring(0, 20));
                    });
                  },
                );
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
      final res = await webViewController!.evaluateJavascript(source: jsCode);
      devtools.log("JavaScript executed: $res");
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
  String _dotNFA = '';
  String _dotDFA = '';
  String _dotMDFA = '';
  bool _showGraph = false;

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

  void handleButtonPress(String regex) {
    final regexPointer = regex.toNativeUtf8().cast<Char>();
    var lib = AutomataLib().nativeLibrary;
    final nfa = lib.NFA_create_instance(regexPointer);
    final dfa = lib.DFA_create_instance(regexPointer);
    final mdfa = lib.DFA_minimalDFA(dfa);
    final nfaDotPointer = lib.NFA_generateDotText(nfa);
    final dfaDotPointer = lib.DFA_generateDotText(dfa);
    final mdfaDotPointer = lib.DFA_generateDotText(mdfa);

    setState(() {
      _dotNFA = nfaDotPointer.cast<Utf8>().toDartString();
      _dotDFA = dfaDotPointer.cast<Utf8>().toDartString();
      _dotMDFA = mdfaDotPointer.cast<Utf8>().toDartString();
      _showGraph = true;
    });

    malloc.free(nfaDotPointer);
    malloc.free(dfaDotPointer);
    malloc.free(mdfaDotPointer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo'),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        TextField(
          controller: _regex,
          decoration: const InputDecoration(
            labelText: 'Regex',
            hintText: 'Enter a regex',
          ),
        ),
        ElevatedButton(
          onPressed: () {
            handleButtonPress(_regex.text);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: const Text('Automata'),
                      ),
                      body: SingleChildScrollView(
                        child: Column(
                          children: [
                            const Text('NFA:'),
                            SizedBox(
                              height: 300,
                              child: GraphvizWebView(dotString: _dotNFA),
                            ),
                            const Text('DFA:'),
                            SizedBox(
                                height: 300,
                                child: Center(
                                  child: GraphvizWebView(dotString: _dotDFA),
                                )),
                            const Text('Minimal DFA:'),
                            SizedBox(
                              height: 300,
                              child: GraphvizWebView(dotString: _dotMDFA),
                            ),
                          ],
                        ),
                      )),
                ));
            devtools.log(_showGraph.toString());
            devtools.log(_dotNFA);
          },
          child: const Text('Generate'),
        ),
      ]),
    );
  }
}
