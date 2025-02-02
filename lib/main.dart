import 'dart:ffi';

import 'package:automata_app/plugin/ffi_plugin/automata_lib.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';

import 'dart:developer' as devtools show log;

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.deepPurple,
    ),
    home: const HomePage(),
  ));
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
              devtools.log(_regex.text);
              final regexPointer = _regex.text.toNativeUtf8().cast<Char>();
              final dfa =
                  AutomataLib().nativeLibrary.DFA_create_instance(regexPointer);
              malloc.free(regexPointer);

              setState(() {
                final outputPointer =
                    AutomataLib().nativeLibrary.DFA_generateDotText(dfa);
                _output = outputPointer.cast<Utf8>().toDartString();
                malloc.free(outputPointer);
              });
            },
            child: const Text('Match'),
          ),
          Text("OUTPUT: $_output"),
        ],
      ),
    );
  }
}
