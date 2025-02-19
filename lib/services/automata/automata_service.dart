import 'dart:ffi';

import 'package:automata_app/plugin/ffi_plugin/automata_lib.dart';
import 'package:automata_app/services/automata/automata_exceptions.dart';
import 'package:ffi/ffi.dart';

class AutomataService {
  static final AutomataService _instance = AutomataService._internal();
  static final _lib = AutomataLib().nativeLibrary;

  factory AutomataService() {
    return _instance;
  }

  AutomataService._internal();

  Map<String, Pointer<Opaque>> createFromRegex(String regex) {
    final regexPointer = regex.toNativeUtf8().cast<Char>();
    final dfa = _lib.DFA_create_instance(regexPointer);
    final nfa = _lib.NFA_create_instance(regexPointer);
    final mdfa = _lib.DFA_minimalDFA(dfa);
    malloc.free(regexPointer);
    return {
      'dfa': dfa,
      'nfa': nfa,
      'mdfa': mdfa,
    };
  }

  createFromDFAtable(
    Set<String> symbols,
    List<Map<String, int?>> tableData,
    List<int> finalStates,
  ) {
    for (var sym in symbols) {
      if (sym.length != 1) {
        throw InvalidAutomataInputException(
          message: 'Invalid symbol $sym',
        );
      }
      if (sym == 'E') {
        throw InvalidAutomataInputException(
          message: 'Invalid symbol Epsilon: $sym',
        );
      }
    }
    for (var i = 0; i < tableData.length; i++) {
      for (var j = 0; j < symbols.length; j++) {
        if (tableData[i][symbols.elementAt(j)] == null ||
            tableData[i][symbols.elementAt(j)]! < 0 ||
            tableData[i][symbols.elementAt(j)]! >= tableData.length) {
          throw InvalidAutomataInputException(
            message: 'Invalid table data at row $i and column $j',
          );
        }
      }
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
    malloc.free(symbolsPointer);
    malloc.free(tablePointer);
    malloc.free(finalStatesPointer);

    return {
      'dfa': dfa,
      'mdfa': mdfa,
    };
  }

  freeInstance(dfaInstance, nfaInstance, mdfaInstance) {
    if (dfaInstance != nullptr) _lib.DFA_destroy_instance(dfaInstance);
    if (nfaInstance != nullptr) _lib.NFA_destroy_instance(nfaInstance);
    if (mdfaInstance != nullptr) _lib.DFA_destroy_instance(mdfaInstance);
  }

  generateDotText(dfaInstance, nfaInstance, mdfaInstance) {
    final dotText = {
      'dfa': '',
      'nfa': '',
      'mdfa': '',
    };

    if (dfaInstance != nullptr) {
      final dfaDotPointer = _lib.DFA_generateDotText(dfaInstance);
      dotText['dfa'] = dfaDotPointer.cast<Utf8>().toDartString();
      malloc.free(dfaDotPointer);
    }

    if (nfaInstance != nullptr) {
      final nfaDotPointer = _lib.NFA_generateDotText(nfaInstance);
      dotText['nfa'] = nfaDotPointer.cast<Utf8>().toDartString();
      malloc.free(nfaDotPointer);
    }

    if (mdfaInstance != nullptr) {
      final mdfaDotPointer = _lib.DFA_generateDotText(mdfaInstance);
      dotText['mdfa'] = mdfaDotPointer.cast<Utf8>().toDartString();
      malloc.free(mdfaDotPointer);
    }

    return dotText;
  }

  compareAutomata(mdfaInstance, other) {
    return _lib.DFA_equalsDFA(mdfaInstance, other);
  }
}
