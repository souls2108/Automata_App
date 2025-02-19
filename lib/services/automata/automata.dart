import 'package:automata_app/services/automata/automata_service.dart';

class Automata {
  late final String regex;
  late final Map<String, dynamic> automataData;
  late final Map<String, dynamic> dotText;

  Automata.fromRegex(this.regex) {
    AutomataService().createFromRegex(regex);
  }

  Automata.fromDFAtable(
    Set<String> symbols,
    List<Map<String, int?>> tableData,
    List<int> finalStates,
  ) {
    AutomataService().createFromDFAtable(symbols, tableData, finalStates);
  }

  generateDotText() {
    final dfa = dotText['dfa'];
    final nfa = dotText['nfa'];
    final mdfa = dotText['mdfa'];
    dotText = AutomataService().generateDotText(dfa, nfa, mdfa);
  }

  void dispose() {
    final dfa = automataData['dfa'];
    final nfa = automataData['nfa'];
    final mdfa = automataData['mdfa'];
    AutomataService().freeInstance(dfa, nfa, mdfa);
  }
}
