import 'dart:math';

import 'package:automata_app/views/create_automata/create_from_regex.dart';
import 'package:automata_app/views/create_automata/create_from_table.dart';
import 'package:flutter/material.dart';

class CreateAutomataView extends StatefulWidget {
  const CreateAutomataView({super.key});

  @override
  State<CreateAutomataView> createState() => _CreateAutomataViewState();
}

class _CreateAutomataViewState extends State<CreateAutomataView> {
  bool isRegexInput = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Automata'),
      ),
      body: Column(
        spacing: 5,
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: 40,
            width: min(MediaQuery.of(context).size.width * 0.9, 500),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextButton(
                  style: resolveButtonStyle(context, isRegexInput),
                  onPressed: () {
                    setState(() {
                      isRegexInput = true;
                    });
                  },
                  child: const Text('Create from regex'),
                ),
                TextButton(
                  style: resolveButtonStyle(context, !isRegexInput),
                  onPressed: () {
                    setState(() {
                      isRegexInput = false;
                    });
                  },
                  child: const Text('Create from table'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          AnimatedSlide(
            offset: Offset(0, 0),
            duration: Duration(milliseconds: 500),
            child: Container(
              // height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  border: Border.symmetric(
                vertical: BorderSide(
                  color: Colors.transparent,
                  width: 25,
                ),
              )),
              child: SingleChildScrollView(
                child: isRegexInput ? CreateFromRegex() : CreateFromTable(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color resolveForgroundColor(BuildContext context, bool isActive) {
    return isActive
        ? Theme.of(context).scaffoldBackgroundColor
        : Theme.of(context).primaryColorDark;
  }

  Color resolveBackgroundColor(BuildContext context, bool isActive) {
    return isActive
        ? Theme.of(context).primaryColorDark
        : Theme.of(context).primaryColorLight;
  }

  ButtonStyle resolveButtonStyle(BuildContext context, bool isActive) {
    return ButtonStyle(
        backgroundColor: WidgetStateColor.resolveWith(
          (widgetState) => resolveBackgroundColor(context, isActive),
        ),
        foregroundColor: WidgetStateColor.resolveWith(
          (widgetState) => resolveForgroundColor(context, isActive),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ));
  }
}
