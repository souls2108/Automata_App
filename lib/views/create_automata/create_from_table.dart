import 'package:automata_app/services/automata/automata.dart';
import 'package:automata_app/services/automata/automata_exceptions.dart';
import 'package:automata_app/views/view_automata/automata_view.dart';
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
  final List<Map<String, int?>> _tableData = [];
  Set<String> _errorCells = {};

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
            border: Border.all(color: Colors.transparent),
          ),
          height: MediaQuery.of(context).size.height * 0.5,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 0,
                      horizontalMargin: 0,
                      clipBehavior: Clip.hardEdge,
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
        const SizedBox(height: 35),
        ElevatedButton(
          onPressed: () {
            try {
              final transitionTable = _tableData.map((row) {
                final rowMap = {
                  for (var element in _symbols) element: row[element]
                };
                return rowMap;
              }).toList();
              final finalStates = _tableData
                  .where((row) => row['final'] == 1)
                  .map((row) => _tableData.indexOf(row))
                  .toList();
              final automata =
                  Automata.fromDFAtable(_symbols, transitionTable, finalStates);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AutomataView(automata: automata),
                ),
              );
            } on InvalidDFASymbolException catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${e.toString()} at ${e.symbol}")),
              );
            } on InvalidDFATableException catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.message)),
              );
              setState(() {
                _errorCells = e.errorCells;
              });
              devtools.log(e.errorCells.toString());
            } catch (e) {
              devtools.log(e.toString());
            }
          },
          child: const Text('Create Automata'),
        ),
      ],
    );
  }

  List<DataRow> _tableRows() {
    var tableRows = <DataRow>[];
    for (var i = 0; i < _tableData.length; ++i) {
      var row = [
        DataCell(_DataTableCustomCell(child: Text('$i'))),
        DataCell(
          _DataTableCustomCell(
            child: Checkbox(
              value: _tableData[i]['final'] == 1,
              onChanged: (value) {
                setState(() {
                  _tableData[i]['final'] = value! ? 1 : 0;
                });
              },
            ),
          ),
        ),
        for (var symbol in _symbols)
          DataCell(_DataTableCustomCell(
            child: ColoredBox(
              color: (_errorCells.contains('($i,$symbol)'))
                  ? const Color.fromARGB(95, 244, 67, 54)
                  : Colors.transparent,
              child: TextField(
                autocorrect: false,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
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
              ),
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
        label: _DataTableCustomCell(child: const Text('State')),
      ),
      DataColumn(
        label: _DataTableCustomCell(child: const Text('Final')),
      ),
      for (var symbol in _symbols)
        DataColumn(
          label: _DataTableCustomCell(child: Text(symbol)),
        ),
    ];
  }

  void _addRow() {
    setState(() {
      _tableData.add({'final': 0, for (var symbol in _symbols) symbol: null});
    });
  }
}

class _DataTableCustomCell extends StatelessWidget {
  const _DataTableCustomCell({required this.child});

  final double cellWidth = 70;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cellWidth,
      child: Center(
        child: child,
      ),
    );
  }
}
