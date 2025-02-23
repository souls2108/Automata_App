import 'package:automata_app/services/automata/automata.dart';
import 'package:automata_app/services/graph_svg/graph_svg_provider.dart';
import 'package:flutter/material.dart';

class AutomataView extends StatelessWidget {
  final Automata automata;

  const AutomataView({super.key, required this.automata});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Automata'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const Text('NFA:'),
              if (automata.dotText['nfa'] != null)
                GraphSvgProvider.instance.generate(automata.dotText['nfa']),
              const Text('DFA:'),
              GraphSvgProvider.instance.generate(automata.dotText['dfa']),
              const Text('Minimal DFA:'),
              GraphSvgProvider.instance.generate(automata.dotText['mdfa']),
            ],
          ),
        ));
  }
}
