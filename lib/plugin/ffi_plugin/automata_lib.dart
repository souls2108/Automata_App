import 'dart:ffi';
import 'dart:io';
import 'package:automata_app/plugin/ffi_plugin/automata_lib_cpp_bindings.dart';

class AutomataLib {
  static final AutomataLib _instance = AutomataLib._sharedInstance();
  final AutomataLibCpp nativeLibrary;

  factory AutomataLib() {
    return _instance;
  }

  AutomataLib._sharedInstance() : nativeLibrary = _loadNativeLibrary();

  static AutomataLibCpp _loadNativeLibrary() {
    try {
      final nativeLibrary = Platform.isAndroid || Platform.isLinux
          ? DynamicLibrary.open("libautomata_lib.so")
          : throw Exception("Platform not supported yet for automata library");
      return AutomataLibCpp(nativeLibrary);
    } catch (e) {
      throw Exception("Failed to load native library: $e");
    }
  }
}
