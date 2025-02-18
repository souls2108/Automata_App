import 'package:flutter/material.dart';

class EditableDataTable extends StatefulWidget {
  const EditableDataTable({super.key});

  @override
  State<EditableDataTable> createState() => _EditableDataTableState();
}

class _EditableDataTableState extends State<EditableDataTable> {
  List<String> data = ["Row 1", "Row 2", "Row 3"];
  int? editingIndex;
  TextEditingController? controller;

  void _startEditing(int index) {
    setState(() {
      editingIndex = index;
      controller = TextEditingController(text: data[index]);
    });
  }

  void _stopEditing(int index) {
    setState(() {
      if (controller != null) {
        data[index] = controller!.text;
        controller!.dispose();
        controller = null;
      }
      editingIndex = null;
    });
  }

  void _submitData() {
    // Process or send data
    print("Submitted Data: $data");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Data Submitted: $data")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Editable DataTable")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                columns: [DataColumn(label: Text("Editable Column"))],
                rows: List.generate(data.length, (index) {
                  return DataRow(
                    cells: [
                      DataCell(
                        editingIndex == index
                            ? Focus(
                                parentNode: FocusNode(),
                                onFocusChange: (hasFocus) {
                                  if (!hasFocus) {
                                    _stopEditing(index);
                                  }
                                },
                                child: TextField(
                                  controller: controller,
                                  autofocus: true,
                                  onSubmitted: (_) => _stopEditing(index),
                                ),
                              )
                            : GestureDetector(
                                onTap: () => _startEditing(index),
                                child: Text(data[index]),
                              ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _submitData,
              child: Text("Submit"),
            ),
          ),
        ],
      ),
    );
  }
}
