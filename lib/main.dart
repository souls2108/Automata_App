import 'dart:ffi';

import 'package:automata_app/services/graph_svg/graph_svg_provider.dart';
import 'package:automata_app/views/create_automata/create_automata_view.dart';
import 'package:flutter/material.dart';
import 'package:automata_app/plugin/ffi_plugin/automata_lib.dart';
import 'package:ffi/ffi.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      primarySwatch: Colors.deepPurple,
      dataTableTheme: DataTableThemeData(
        dataRowMaxHeight: 50.0,
        dataRowMinHeight: 50.0,
        headingRowAlignment: MainAxisAlignment.center,
      ),
    ),
    home: CreateAutomataView(),
  ));
  GraphSvgProvider.instance;
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
                            // const Text('NFA:'),
                            // SizedBox(
                            //   height: 300,
                            //   child: GraphSvgProvider().generate(_dotNFA),
                            // ),
                            // const Text('DFA:'),
                            // SizedBox(
                            //     height: 300,
                            //     child: Center(
                            //       child: GraphSvgProvider().generate(_dotDFA),
                            //     )),
                            const Text('Minimal DFA:'),
                            SizedBox(
                              height: 300,
                              child:
                                  GraphSvgProvider.instance.generate(_dotMDFA),
                            ),
                          ],
                        ),
                      )),
                ));
          },
          child: const Text('Generate'),
        ),
      ]),
    );
  }
}
