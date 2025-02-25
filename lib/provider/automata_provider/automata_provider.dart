import 'package:automata_app/provider/automata_provider/automata_metadata.dart';
import 'package:automata_app/services/automata/automata.dart';
import 'package:flutter/foundation.dart';

class AutomataProvider with ChangeNotifier {
  //IDEA: Store object hashcode as key in memory map
  final Map<Automata, AutomataMetadata> _automataMemory = {};

  List<String> get names => _automataMemory.values.map((e) => e.name).toList();
  List<Automata> get automatas => _automataMemory.keys.toList();

  void add(Automata automata, String? name) {
    _automataMemory[automata] = AutomataMetadata(
      name: (name == null || name.trim().isEmpty) ? getDefaultName() : name,
    );
    notifyListeners();
  }

  void remove(Automata automata) {
    _automataMemory.remove(automata);
    notifyListeners();
  }

  bool exists(Automata automata) {
    return _automataMemory.containsKey(automata);
  }

  AutomataMetadata? getMetadata(Automata automata) {
    return _automataMemory[automata];
  }

  String getDefaultName() {
    return 'Automata ${_automataMemory.length + 1}';
  }
}
