import 'package:automata_app/services/automata/automata.dart';
import 'package:automata_app/views/view_automata/automata_view.dart';
import 'package:flutter/material.dart';

class CreateFromRegex extends StatefulWidget {
  const CreateFromRegex({super.key});

  @override
  State<CreateFromRegex> createState() => _CreateFromRegexState();
}

class _CreateFromRegexState extends State<CreateFromRegex> {
  TextEditingController _regex = TextEditingController();

  @override
  void initState() {
    _regex = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextField(
          controller: _regex,
          decoration: const InputDecoration(
            labelText: 'Enter a regex',
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            //TODO: validate regex
            final automata = Automata.fromRegex(_regex.text);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AutomataView(automata: automata),
              ),
            );
          },
          child: const Text('Create Automata'),
        ),
      ],
    );
  }
}
