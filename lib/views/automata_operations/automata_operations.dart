import 'dart:math';

import 'package:automata_app/provider/automata_provider/automata_provider.dart';
import 'package:automata_app/services/automata/automata.dart';
import 'package:automata_app/views/automata_operations/evaluation.dart';
import 'package:automata_app/views/automata_operations/evaluation_exceptions.dart';
import 'package:automata_app/views/automata_operations/operations_constants.dart';
import 'package:automata_app/views/view_automata/automata_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:developer' as devtools show log;

import 'package:uuid/uuid.dart';

class AutomataOperations extends StatefulWidget {
  const AutomataOperations({super.key});

  @override
  State<AutomataOperations> createState() => _AutomataOperationsState();
}

class _AutomataOperationsState extends State<AutomataOperations> {
  late AutomataProvider providerAutomata;
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
    providerAutomata = Provider.of<AutomataProvider>(context);
    final automataNames = providerAutomata.names;
    final automatas = providerAutomata.automatas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Automata Operations'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  height: 90,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    color: Colors.grey.shade200,
                  ),
                  width: double.infinity,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 5,
                      children: _buildExpression(),
                    ),
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      try {
                        final expression =
                            _expression.map((e) => e["item"]).toList();
                        final automata = evaluateExpression(expression);
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AutomataView(
                            automata: automata,
                          ),
                        ));
                      } on InvalidExpression catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Unknown error during evaluation"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text('Evaluate')),
              ],
            ),
          ),
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
                                onLongPress: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => AutomataView(
                                      automata: automatas.elementAt(index),
                                    ),
                                  ));
                                },
                                onTap: () {
                                  String id = Uuid().v4();
                                  _expression.add({
                                    "id": id,
                                    "item": automatas.elementAt(index),
                                  });
                                  setState(() {
                                    devtools.log(
                                        "Automata: ${automataNames.elementAt(index)} added expression");
                                  });
                                });
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
    String id = Uuid().v4();
    _expression.add({
      "id": id,
      "item": operation,
    });
    setState(() {});
  }

  List<Widget> _buildExpression() {
    final res = _expression.map((e) {
      final item = e["item"];
      final id = e["id"];
      if (item is OperationButtons) {
        return ExpressionItemTile(
          color: _operationColor[item]!,
          onDoubleTap: () {
            _expression.removeWhere((element) => element["id"] == id);
            setState(() {});
          },
          itemName: item.toString().split('.').last,
        );
      }
      if (item is Automata) {
        return ExpressionItemTile(
          color: Colors.grey.shade800,
          onDoubleTap: () {
            _expression.removeWhere((element) => element["id"] == id);
            setState(() {});
          },
          itemName: providerAutomata.getMetadata(item)!.name,
        );
      }
      return Placeholder();
    }).toList();
    devtools.log(res.toString());
    return res;
  }
}

class ExpressionItemTile extends StatelessWidget {
  final String itemName;
  final Color color;
  final GestureDoubleTapCallback onDoubleTap;
  const ExpressionItemTile(
      {super.key,
      required this.itemName,
      required this.color,
      required this.onDoubleTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onDoubleTap: onDoubleTap,
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
