import 'package:automata_app/provider/automata_provider/automata_provider.dart';
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
    return Scaffold(
      body: ListView.builder(
        itemCount: automataNames.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(automataNames.elementAt(index)),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AutomataView(
                  automata: providerAutomata.automatas.elementAt(index),
                ),
              ));
            },
          );
        },
      ),
    );
  }
}
