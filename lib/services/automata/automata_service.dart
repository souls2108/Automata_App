import 'dart:ffi';

import 'package:automata_app/plugin/ffi_plugin/automata_lib.dart';
import 'package:automata_app/services/automata/automata_exceptions.dart';
import 'package:ffi/ffi.dart';

class AutomataService {
  static final AutomataService _instance = AutomataService._internal();
  static final _lib = AutomataLib().nativeLibrary;
  static Future<String> Function(String)? dotToSvgConverter;
  bool get isInitializedConverter => dotToSvgConverter != null;

  factory AutomataService() {
    return _instance;
  }

  AutomataService._internal();

  Map<String, dynamic> createFromRegex(String regex) {
    final regexPointer = regex.toNativeUtf8().cast<Char>();
    final dfa = _lib.DFA_create_instance(regexPointer);
    final nfa = _lib.NFA_create_instance(regexPointer);
    final mdfa = _lib.DFA_minimalDFA(dfa);
    malloc.free(regexPointer);
    return {
      'regex': regex,
      'dfa': dfa,
      'nfa': nfa,
      'mdfa': mdfa,
    };
  }

  Map<String, dynamic> createFromDFAtable(
    Set<String> symbols,
    List<Map<String, int?>> tableData,
    List<int> finalStates,
  ) {
    for (var sym in symbols) {
      if (sym.length != 1) {
        throw InvalidDFASymbolException(
          symbol: sym,
        );
      }
      if (sym == 'E') {
        throw InvalidDFASymbolException(
          symbol: sym,
        );
      }
    }

    final errorCells = <String>{};
    for (var row = 0; row < tableData.length; row++) {
      for (var symbol in symbols) {
        if (tableData[row][symbol] == null ||
            tableData[row][symbol]! < 0 ||
            tableData[row][symbol]! >= tableData.length) {
          errorCells.add('($row,$symbol)');
        }
      }
    }
    if (errorCells.isNotEmpty) {
      throw InvalidDFATableException(
        errorCells: errorCells,
      );
    }

    final symbolsSize = symbols.length;
    final symbolsPointer = symbols.join('').toNativeUtf8().cast<Char>();
    final tableSize = tableData.length;
    final tablePointer = calloc<Int>(tableSize * symbolsSize);
    final finalStatesSize = finalStates.length;
    final finalStatesPointer = calloc<Int>(finalStatesSize);

    for (var i = 0; i < finalStatesSize; i++) {
      finalStatesPointer[i] = finalStates[i];
    }
    for (var i = 0; i < tableSize; i++) {
      for (var j = 0; j < symbolsSize; j++) {
        tablePointer[i * symbolsSize + j] = tableData[i][symbols.elementAt(j)]!;
      }
    }

    final dfa = _lib.DFA_create_instance_from_data(
      symbolsPointer,
      symbolsSize,
      tablePointer,
      tableSize,
      finalStatesPointer,
      finalStatesSize,
    );
    final mdfa = _lib.DFA_minimalDFA(dfa);
    final nfa = _lib.NFA_create_instance_from_DFA(dfa, 1);
    final regexPtr = _lib.DFA_regex(mdfa);
    final regex = regexPtr.cast<Utf8>().toDartString();
    malloc.free(symbolsPointer);
    malloc.free(tablePointer);
    malloc.free(finalStatesPointer);
    malloc.free(regexPtr);

    return {
      'regex': regex,
      'nfa': nfa,
      'dfa': dfa,
      'mdfa': mdfa,
    };
  }

  Map<String, dynamic> createFromDFA(dfaInstance) {
    final dfa = _lib.DFA_create_instance_from_DFA(dfaInstance);
    final mdfa = _lib.DFA_minimalDFA(dfaInstance);
    final nfa = _lib.NFA_create_instance_from_DFA(dfaInstance, 1);
    final regexPtr = _lib.DFA_regex(mdfa);
    final regex = regexPtr.cast<Utf8>().toDartString();
    malloc.free(regexPtr);
    return {
      'regex': regex,
      'nfa': nfa,
      'dfa': dfa,
      'mdfa': mdfa,
    };
  }

  Map<String, dynamic> createFromNFA(nfaInstance) {
    final nfa = _lib.NFA_create_instance_from_NFA(nfaInstance);
    final dfa = _lib.DFA_create_instance_from_NFA(nfaInstance);
    final mdfa = _lib.DFA_minimalDFA(dfa);
    final regexPtr = _lib.DFA_regex(mdfa);
    final regex = regexPtr.cast<Utf8>().toDartString();
    malloc.free(regexPtr);
    return {
      'regex': regex,
      'nfa': nfa,
      'dfa': dfa,
      'mdfa': mdfa,
    };
  }

  freeInstance({dfaInstance, nfaInstance, mdfaInstance}) {
    if (dfaInstance != nullptr) _lib.DFA_destroy_instance(dfaInstance);
    if (nfaInstance != nullptr) _lib.NFA_destroy_instance(nfaInstance);
    if (mdfaInstance != nullptr) _lib.DFA_destroy_instance(mdfaInstance);
  }

  generateDotText_(
      {dfaInstance, nfaInstance, mdfaInstance, bool showDeadStates = false}) {
    final dotText = {
      'dfa': '',
      'nfa': '',
      'mdfa': '',
    };

    if (dfaInstance != null) {
      final dfaDotPointer =
          _lib.DFA_generateDotText(dfaInstance, showDeadStates ? 1 : 0);
      dotText['dfa'] = dfaDotPointer.cast<Utf8>().toDartString();
      malloc.free(dfaDotPointer);
    }

    if (nfaInstance != null) {
      final nfaDotPointer = _lib.NFA_generateDotText(nfaInstance);
      dotText['nfa'] = nfaDotPointer.cast<Utf8>().toDartString();
      malloc.free(nfaDotPointer);
    }

    if (mdfaInstance != null) {
      final mdfaDotPointer =
          _lib.DFA_generateDotText(mdfaInstance, showDeadStates ? 1 : 0);
      dotText['mdfa'] = mdfaDotPointer.cast<Utf8>().toDartString();
      malloc.free(mdfaDotPointer);
    }

    return dotText;
  }

  String? generateDotText(
      {required instance, required String type, bool showDeadStates = true}) {
    switch (type) {
      case 'dfa':
        if (instance == null) return null;
        final dotTextPtr =
            _lib.DFA_generateDotText(instance, showDeadStates ? 1 : 0);
        String dotText = dotTextPtr.cast<Utf8>().toDartString();
        malloc.free(dotTextPtr);
        return dotText;
      case 'nfa':
        if (instance == null) return null;
        final dotTextPtr = _lib.NFA_generateDotText(instance);
        String dotText = dotTextPtr.cast<Utf8>().toDartString();
        malloc.free(dotTextPtr);
        return dotText;
      case 'mdfa':
        if (instance == null) return null;
        final dotTextPtr =
            _lib.DFA_generateDotText(instance, showDeadStates ? 1 : 0);
        String dotText = dotTextPtr.cast<Utf8>().toDartString();
        malloc.free(dotTextPtr);
        return dotText;
      default:
        throw Exception('Invalid type');
    }
  }

  void attachDotTextToSvgConverter(
      Future<String> Function(String) dotToSvgConverter) {
    AutomataService.dotToSvgConverter = dotToSvgConverter;
  }

  Future<String> convertDotToSvg(String dotText) {
    if (dotToSvgConverter == null) {
      throw AutomataServiceConverterUninitialized();
    }
    try {
      final svgString = dotToSvgConverter!(dotText);
      return svgString;
    } catch (e) {
      throw SvgException();
    }
  }

  bool testString(dfaInstance, String input) {
    final inputPointer = input.toNativeUtf8().cast<Char>();
    final result = _lib.DFA_test(dfaInstance, inputPointer) == 1;
    malloc.free(inputPointer);
    return result;
  }

  unionNFA(nfaInstance, otherNfa) {
    final resNfa = _lib.NFA_unionNFA(nfaInstance, otherNfa);
    return resNfa;
  }

  intersectionDFA(dfaInstance, otherDfa) {
    final resDfa = _lib.DFA_intersection(dfaInstance, otherDfa);
    return resDfa;
  }

  complementDFA(dfaInstance) {
    final resDfa = _lib.DFA_complement(dfaInstance);
    return resDfa;
  }

  reverseNFA(nfaInstance) {
    final resNfa = _lib.NFA_reverseNFA(nfaInstance);
    return resNfa;
  }

  concatNFA(nfaInstance, otherNfa) {
    final resNfa = _lib.NFA_concat(nfaInstance, otherNfa);
    return resNfa;
  }

  String getDiffString(mdfaInstance, other) {
    if (_lib.DFA_isMinimal(mdfaInstance) != 1 ||
        _lib.DFA_isMinimal(other) != 1) {
      return "";
    }

    if (isEquivalent(mdfaInstance, other)) return "";
    final diffPointer = _lib.DFA_getDiffString(mdfaInstance, other, -1);
    final diffString = diffPointer.cast<Utf8>().toDartString();
    malloc.free(diffPointer);
    return diffString;
  }

  bool isEquivalent(mdfaInstance, other) {
    return _lib.DFA_equalsDFA(mdfaInstance, other) == 1;
  }

  bool isSubset(instance, other) {
    return _lib.DFA_isSubset(instance, other) == 1;
  }

  bool isSuperset(instance, other) {
    return _lib.DFA_isSuperset(instance, other) == 1;
  }
}
