import 'package:automata_app/services/automata/automata_service.dart';

class Automata {
  late final String regex;
  late final Map<String, dynamic> automataData;
  late final Map<String, dynamic> dotText;

  Automata.fromRegex(this.regex) {
    automataData = AutomataService().createFromRegex(regex);
  }

  Automata.fromAutomata(Automata other) {
    regex = other.regex;
    automataData = Map<String, dynamic>.from(other.automataData);
    dotText = Map<String, dynamic>.from(other.dotText);
  }

  Automata.fromDFAtable(
    Set<String> symbols,
    List<Map<String, int?>> tableData,
    List<int> finalStates,
  ) {
    automataData =
        AutomataService().createFromDFAtable(symbols, tableData, finalStates);
  }

  generateDotText() {
    final dfa = automataData['dfa'];
    final nfa = automataData['nfa'];
    final mdfa = automataData['mdfa'];
    dotText = AutomataService().generateDotText(dfa, nfa, mdfa);
  }

  bool equals(Automata other) {
    return AutomataService()
        .compareAutomata(automataData['mdfa'], other.automataData['mdfa']);
  }

  bool testString(String str) {
    final mdfa = automataData['mdfa'];
    return AutomataService().testString(mdfa, str);
  }

  void dispose() {
    final dfa = automataData['dfa'];
    final nfa = automataData['nfa'];
    final mdfa = automataData['mdfa'];
    AutomataService().freeInstance(dfa, nfa, mdfa);
  }
}
