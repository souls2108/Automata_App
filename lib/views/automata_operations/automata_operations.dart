import 'package:automata_app/provider/automata_provider/automata_provider.dart';
import 'package:automata_app/views/automata_operations/operations_constants.dart';
import 'package:automata_app/views/view_automata/automata_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:developer' as devtools show log;

class AutomataOperations extends StatelessWidget {
  const AutomataOperations({super.key});

  @override
  Widget build(BuildContext context) {
    final providerAutomata = Provider.of<AutomataProvider>(context);
    final automataNames = providerAutomata.names;
    final operations = OperationButtons.values;
    final operationColor = Map.fromIterables(
      operations,
      operations.map(
        (e) => Colors.primaries[e.index % Colors.primaries.length].shade800,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Automata Operations'),
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: Placeholder()),
          SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Stack(children: [
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 25,
                  mainAxisSpacing: 25,
                  padding: const EdgeInsets.all(10),
                  children: List.generate(operations.length, (index) {
                    final operation = operations.elementAt(index);
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: operationColor[operation]),
                      onPressed: () {
                        devtools.log("Operation: $operation");
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
                      return ListView(
                        controller: scrollController,
                        children: [
                          Placeholder(),
                          Placeholder(),
                          Container(height: 10),
                          Placeholder(),
                        ],
                      );
                      // return ListView.builder(
                      //   itemCount: automataNames.length,
                      //   itemBuilder: (context, index) {
                      //     return ListTile(
                      //       title: Text(automataNames.elementAt(index)),
                      //       onTap: () {
                      //         Navigator.of(context).push(MaterialPageRoute(
                      //           builder: (context) => AutomataView(
                      //             automata:
                      //                 providerAutomata.automatas.elementAt(index),
                      //           ),
                      //         ));
                      //       },
                      //     );
                      //   },
                      // );
                    }),
              ])),
        ],
      ),
    );
  }
}
