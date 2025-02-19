import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:flutter/services.dart';

class CreateFromTable extends StatefulWidget {
  const CreateFromTable({super.key});

  @override
  State<CreateFromTable> createState() => _CreateFromTableState();
}

class _CreateFromTableState extends State<CreateFromTable> {
  late final TextEditingController _symbolController;
  Set<String> _symbols = {};
  String value = '';
  final List<Map<String, int?>> _tableData = [];

  @override
  void initState() {
    _symbolController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _symbolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _symbolController,
          decoration: InputDecoration(
            labelText: 'Symbols',
            hintText: 'Enter symbols concatenated',
          ),
          onChanged: (value) {
            setState(() {
              _symbols = Set.from(value.split(''));
              for (var row in _tableData) {
                final keysMap = {
                  for (var element in ['final', ..._symbols])
                    element: row[element]
                };
                row
                  ..removeWhere((key, value) => !keysMap.containsKey(key))
                  ..addAll(keysMap.map((key, value) => MapEntry(key, value)));
              }
            });
          },
        ),
        const SizedBox(height: 25),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
          ),
          height: MediaQuery.of(context).size.height * 0.5,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: _tableColumns(),
                      rows: _tableRows(),
                      border: TableBorder.all(
                        color: Colors.black,
                        width: 0.25,
                      ),
                    )),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _addRow,
                      label: const Text('Add Row'),
                      icon: const Icon(Icons.add),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          if (_tableData.isNotEmpty) {
                            _tableData.removeLast();
                          }
                        });
                      },
                      label: const Text('Delete Row'),
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            devtools.log('Create DFA');
            devtools.log(_tableData.toString());
          },
          child: const Text('Create DFA'),
        ),
      ],
    );
  }

  List<DataRow> _tableRows() {
    var tableRows = <DataRow>[];
    for (var i = 0; i < _tableData.length; ++i) {
      var row = [
        DataCell(Text('$i')),
        DataCell(
          Checkbox(
            value: _tableData[i]['final'] == 1,
            onChanged: (value) {
              setState(() {
                _tableData[i]['final'] = value! ? 1 : 0;
              });
            },
          ),
        ),
        for (var symbol in _symbols)
          DataCell(TextField(
            autocorrect: false,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            onChanged: (value) {
              setState(() {
                _tableData[i][symbol] = int.tryParse(value);
              });
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ))
      ];
      tableRows.add(DataRow.byIndex(cells: row, index: i));
    }
    return tableRows;
  }

  List<DataColumn> _tableColumns() {
    return [
      DataColumn(
        label: const Text('State'),
      ),
      DataColumn(
        label: const Text('Final'),
      ),
      for (var symbol in _symbols)
        DataColumn(
          label: Text(symbol),
        ),
    ];
  }

  void _addRow() {
    // for (var symbol in _symbols)
    //   DataCell(
    //     TextFormField(
    //       keyboardType: TextInputType.number,
    //       textInputAction: TextInputAction.next,
    //       validator: (value) {
    //         if (value!.isEmpty) return 'Please enter a value';
    //         final number = int.tryParse(value);
    //         if (number == null) return 'Please enter a number';
    //         if (number < 0 || number >= _transitionTable.length) {
    //           return 'Please enter a valid state';
    //         }
    //         return null;
    //       },
    //       onFieldSubmitted: (value) {
    //         FocusScope.of(context).nextFocus();
    //       },
    //       onSaved: (newValue) {
    //         _transitionTable[stateNumber]?[symbol] = int.parse(newValue!);
    //       },
    //     ),
    //   ),
    setState(() {
      _tableData.add({'final': 0, for (var symbol in _symbols) symbol: null});
    });
  }
}
