import 'package:automata_app/services/automata/automata_exceptions.dart';
import 'package:automata_app/services/automata/automata_service.dart';

class Automata {
  late final Map<String, dynamic> automataData;
  late final Map<String, String> dotText;
  late final Map<List, String> svgDataCache;

  Automata.fromRegex(regex) {
    automataData = AutomataService().createFromRegex(regex);
    svgDataCache = {};
  }

  Automata.fromAutomata(Automata other) {
    automataData = Map<String, dynamic>.from(other.automataData);
    svgDataCache = Map<List, String>.from(other.svgDataCache);
  }

  Automata.fromDFAtable(
    Set<String> symbols,
    List<Map<String, int?>> tableData,
    List<int> finalStates,
  ) {
    automataData =
        AutomataService().createFromDFAtable(symbols, tableData, finalStates);
    svgDataCache = {};
  }

  Automata._fromDFA(dfaInstance) {
    automataData = AutomataService().createFromDFA(dfaInstance);
    svgDataCache = {};
  }

  Automata._fromNFA(nfaInstance) {
    automataData = AutomataService().createFromNFA(nfaInstance);
    svgDataCache = {};
  }

  Future<String> getSvg({
    required String type,
    bool showDeadStates = true,
  }) async {
    if (svgDataCache.containsKey([type, showDeadStates])) {
      return svgDataCache[[type, showDeadStates]]!;
    }

    String? dotText = AutomataService().generateDotText(
      instance: automataData[type],
      type: type,
      showDeadStates: showDeadStates,
    );
    if (dotText == null) {
      throw DotTextException();
    }

    final svgString = await AutomataService().convertDotToSvg(dotText);
    svgDataCache[[type, showDeadStates]] = svgString;
    return svgString;
  }

  bool equals(Automata other) {
    return AutomataService().isEquivalent(
      automataData['mdfa']!,
      other.automataData['mdfa']!,
    );
  }

  bool isSubset(Automata other) {
    return AutomataService().isSubset(
      automataData['mdfa']!,
      other.automataData['mdfa']!,
    );
  }

  bool isSuperset(Automata other) {
    return AutomataService().isSubset(
      other.automataData['mdfa']!,
      automataData['mdfa']!,
    );
  }

  bool testString(String str) {
    final mdfa = automataData['mdfa']!;
    return AutomataService().testString(mdfa, str);
  }

  void dispose() {
    final dfa = automataData['dfa'];
    final nfa = automataData['nfa'];
    final mdfa = automataData['mdfa'];
    AutomataService().freeInstance(
      dfaInstance: dfa,
      nfaInstance: nfa,
      mdfaInstance: mdfa,
    );
  }

  Automata union(Automata other) {
    final nfaInstance = AutomataService()
        .unionNFA(automataData['nfa'], other.automataData['nfa']);
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
