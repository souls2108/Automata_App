import 'dart:math';

import 'package:automata_app/provider/automata_provider/automata_provider.dart';
import 'package:automata_app/services/automata/automata.dart';
import 'package:automata_app/views/automata_operations/operations_constants.dart';
import 'package:automata_app/views/view_automata/automata_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:developer' as devtools show log;

class AutomataOperations extends StatefulWidget {
  const AutomataOperations({super.key});

  @override
  State<AutomataOperations> createState() => _AutomataOperationsState();
}

class _AutomataOperationsState extends State<AutomataOperations> {
  final _expression = [];

  final _operations = OperationButtons.values;
  final _operationColor = Map.fromIterables(
    OperationButtons.values,
    OperationButtons.values.map(
      (e) => Colors.primaries[e.index % Colors.primaries.length].shade800,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final providerAutomata = Provider.of<AutomataProvider>(context);
    final automataNames = providerAutomata.names;
    final automatas = providerAutomata.automatas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Automata Operations'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (_expression.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 5,
                    children: _buildExpression(),
                  ),
                ),
              ElevatedButton(onPressed: () {}, child: const Text('Evaluate')),
            ],
          )),
          SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Stack(children: [
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 25,
                  mainAxisSpacing: 25,
                  padding: const EdgeInsets.all(10),
                  children: List.generate(_operations.length, (index) {
                    final operation = _operations.elementAt(index);
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _operationColor[operation]),
                      onPressed: () {
                        _onOperationButtonPressed(operation);
                      },
                      child: Center(
                        child: Text(
                          operation.toString().split('.').last,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }),
                ),
                DraggableScrollableSheet(
                    initialChildSize: 0.1,
                    minChildSize: 0.1,
                    builder: (context, scrollController) {
                      return Container(
                        color: Colors.white,
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: automatas.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(automataNames.elementAt(index)),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => AutomataView(
                                    automata: automatas.elementAt(index),
                                  ),
                                ));
                              },
                            );
                          },
                        ),
                      );
                    }),
              ])),
        ],
      ),
    );
  }

  void _onOperationButtonPressed(OperationButtons operation) {
    switch (operation) {
      case OperationButtons.union:
        _expression.add(operation);
        break;
      case OperationButtons.intersection:
        _expression.add(operation);
        break;
      case OperationButtons.complement:
        _expression.add(operation);
        break;
      case OperationButtons.reverse:
        _expression.add(operation);
        break;
      case OperationButtons.concat:
        _expression.add(operation);
        break;
      case OperationButtons.regex:
        _expression.add(operation);
        break;
    }
    devtools.log("Operation: $operation");
    setState(() {});
  }

  List<Widget> _buildExpression() {
    final res = _expression.map((e) {
      if (e is OperationButtons) {
        return ExpressionItemTile(
          color: _operationColor[e]!,
          onTap: () {
            devtools.log("Pressed: ${e.toString()}");
          },
          itemName: e.toString().split('.').last,
        );
      }
      return Placeholder();
    }).toList();
    devtools.log(res.toString());
    return res;
  }

  Automata evaluateExpression() {
    return Automata.fromRegex("a");
  }
}

class ExpressionItemTile extends StatelessWidget {
  final String itemName;
  final Color color;
  final GestureTapCallback onTap;
  const ExpressionItemTile(
      {super.key,
      required this.itemName,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              itemName,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ));
  }
}
