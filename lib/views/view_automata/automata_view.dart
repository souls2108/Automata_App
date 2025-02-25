import 'package:automata_app/provider/automata_provider/automata_provider.dart';
import 'package:automata_app/services/automata/automata.dart';
import 'package:automata_app/services/graph_svg/graph_svg_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AutomataView extends StatefulWidget {
  final Automata automata;

  const AutomataView({super.key, required this.automata});

  @override
  State<AutomataView> createState() => _AutomataViewState();
}

class _AutomataViewState extends State<AutomataView> {
  late final TextEditingController _name;

  @override
  void initState() {
    _name = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final automata = widget.automata;
    final providerAutomata = Provider.of<AutomataProvider>(context);

    saveButton() {
      return ElevatedButton.icon(
        onPressed: () {
          // if(!providerAutomata.exists(automata)){
          providerAutomata.add(automata, _name.text);
          // }
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        label: const Text('Save Automata'),
        icon: const Icon(Icons.save),
      );
    }

    deleteButton() {
      return ElevatedButton.icon(
        onPressed: () {
          providerAutomata.remove(automata);
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        label: const Text('Remove Automata'),
        icon: const Icon(Icons.delete),
      );
    }

    nameField() {
      _name.text = providerAutomata.exists(automata)
          ? providerAutomata.getMetadata(automata)!.name
          : providerAutomata.getDefaultName();
      return TextField(
        controller: _name,
        decoration: const InputDecoration(
          labelText: 'Automata name',
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Automata'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              nameField(),
              const Text('NFA:'),
              if (automata.dotText['nfa'] != null)
                GraphSvgProvider.instance.generate(automata.dotText['nfa']),
              const Text('DFA:'),
              GraphSvgProvider.instance.generate(automata.dotText['dfa']),
              const Text('Minimal DFA:'),
              GraphSvgProvider.instance.generate(automata.dotText['mdfa']),
              Row(
                children: [
                  saveButton(),
                  deleteButton(),
                ],
              )
            ],
          ),
        ));
  }
}
