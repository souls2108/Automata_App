import 'package:automata_app/services/automata/automata_service.dart';

import 'dart:developer' as devtool show log;

class Automata {
  late final String regex;
  late final Map<String, dynamic> automataData;
  late Map<String, dynamic> dotText;

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

  Automata._fromDFA(dfaInstance) {
    automataData = AutomataService().createFromDFA(dfaInstance);
  }

  Automata._fromNFA(nfaInstance) {
    automataData = AutomataService().createFromNFA(nfaInstance);
  }

  generateDotText() {
    final dfa = automataData['dfa'];
    final nfa = automataData['nfa'];
    final mdfa = automataData['mdfa'];
    dotText = AutomataService().generateDotText(dfa, nfa, mdfa, true);
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

  Automata union(Automata other) {
    devtool.log('Union 1');
    final nfaInstance = AutomataService()
        .unionNFA(automataData['nfa'], other.automataData['nfa']);
    devtool.log('Union 2');
    final resAutomata = Automata._fromNFA(nfaInstance);
    return resAutomata;
  }

  Automata intersection(Automata other) {
    final dfaInstance = AutomataService()
        .intersectionDFA(automataData['mdfa'], other.automataData['mdfa']);
    final resAutomata = Automata._fromDFA(dfaInstance);
    return resAutomata;
  }

  Automata complement() {
    final dfaInstance = AutomataService().complementDFA(automataData['mdfa']);
    final resAutomata = Automata._fromDFA(dfaInstance);
    return resAutomata;
  }

  Automata reverse() {
    final nfaInstance = AutomataService().reverseNFA(automataData['nfa']);
    final resAutomata = Automata._fromNFA(nfaInstance);
    return resAutomata;
  }

  Automata concat(Automata other) {
    final nfaInstance = AutomataService()
        .concatNFA(automataData['nfa'], other.automataData['nfa']);
    final resAutomata = Automata._fromNFA(nfaInstance);
    return resAutomata;
  }

  Automata difference(Automata other) {
    //TODO refactor for direct operation
    Automata otherComplement = other.complement();
    Automata resAutomata = intersection(otherComplement);
    otherComplement.dispose();
    return resAutomata;
  }
}
