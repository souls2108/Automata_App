import 'package:automata_app/provider/automata_provider/automata_provider.dart';
import 'package:automata_app/services/automata/automata.dart';
import 'package:automata_app/services/graph_svg/graph_svg_provider.dart';
import 'package:automata_app/widgets/interactive_widget.dart';
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
  late final TextEditingController _testStringTextController;
  String _currentView = 'mdfa';
  final List<String> _viewItems = ['nfa', 'dfa', 'mdfa'];
  bool _testStringVisible = false;
  bool _isTestStringAccepted = false;

  @override
  void initState() {
    _name = TextEditingController();
    _testStringTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _testStringTextController.dispose();
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
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                nameField(),
                const SizedBox(height: 20),
                Text('View: ${_currentView.toUpperCase()}'),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                    color: Colors.grey.shade50,
                  ),
                  child: InteractiveWidget(
                    child: SizedBox(
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                      child: GraphSvgProvider.instance
                          .generate(automata.dotText[_currentView]),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _viewButtons(),
                ),
                const SizedBox(height: 20),
                if (_testStringVisible) _testStringWidget(),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _testStringVisible = !_testStringVisible;
                    });
                  },
                  child: Text(_testStringVisible ? 'Collapse' : 'Test String'),
                ),
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
          ),
        ));
  }

  List<ElevatedButton> _viewButtons() {
    return _viewItems
        .map(
          (view) => ElevatedButton(
            onPressed: () {
              setState(() {
                _currentView = view;
              });
            },
            child: Text(view.toUpperCase()),
          ),
        )
        .toList();
  }

  Widget _testStringWidget() {
    return Column(
      children: [
        TextField(
          controller: _testStringTextController,
          onChanged: (value) {
            setState(() {
              _isTestStringAccepted = widget.automata.testString(
                _testStringTextController.text,
              );
            });
          },
          decoration: const InputDecoration(
            labelText: 'Test string',
          ),
        ),
        const SizedBox(height: 10),
        _isTestStringAccepted
            ? ColoredBox(
                color: Colors.green,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'ACCEPTED',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            : ColoredBox(
                color: Colors.red,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'REJECTED',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
        const SizedBox(height: 10),
      ],
    );
  }
}
