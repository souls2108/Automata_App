import 'package:automata_app/provider/automata_provider/automata_provider.dart';
import 'package:automata_app/services/automata/automata.dart';
import 'package:automata_app/services/automata/automata_service.dart';
import 'package:automata_app/services/graph_svg/graph_svg_provider.dart';
import 'package:automata_app/widgets/interactive_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class AutomataView extends StatefulWidget {
  final Automata automata;

  const AutomataView({super.key, required this.automata});

  @override
  State<AutomataView> createState() => _AutomataViewState();
}

class _AutomataViewState extends State<AutomataView> {
  late AutomataProvider providerAutomata;
  late final TextEditingController _nameController;
  late final Automata automata;
  late final TextEditingController _testStringTextController;
  String _currentView = 'mdfa';
  final List<String> _viewItems = ['nfa', 'dfa', 'mdfa'];
  bool showDeadStates = true;
  bool _testStringVisible = false;
  bool _isTestStringAccepted = false;
  bool _isZooming = false;

  @override
  void initState() {
    _nameController = TextEditingController();
    _testStringTextController = TextEditingController();
    automata = widget.automata;

    if (!AutomataService().isInitializedConverter) {
      AutomataService().attachDotTextToSvgConverter(
        GraphSvgProvider.instance.generateGraphSVG,
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    if (!providerAutomata.exists(automata)) automata.dispose();
    _testStringTextController.dispose();
    super.dispose();
  }

  void _onZoomChange(bool isZooming) {
    setState(() {
      _isZooming = isZooming;
    });
  }

  @override
  Widget build(BuildContext context) {
    final automata = widget.automata;
    providerAutomata = Provider.of<AutomataProvider>(context);

    saveButton() {
      return ElevatedButton.icon(
        onPressed: () {
          // if(!providerAutomata.exists(automata)){
          providerAutomata.add(automata, _nameController.text);
          // }
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        label: const Text('Save'),
        icon: const Icon(Icons.save),
      );
    }

    deleteButton() {
      return ElevatedButton.icon(
        onPressed: () {
          providerAutomata.remove(automata);
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        label: const Text('Remove'),
        icon: const Icon(Icons.delete),
      );
    }

    nameField() {
      _nameController.text = providerAutomata.exists(automata)
          ? providerAutomata.getMetadata(automata)!.name
          : providerAutomata.getDefaultName();
      return TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'Automata name',
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Automata'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GestureDetector(
            onScaleStart: (_) {},
            behavior: HitTestBehavior.opaque,
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                return _isZooming;
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    nameField(),
                    const SizedBox(height: 20),
                    Text('View: ${_currentView.toUpperCase()}'),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                        color: Colors.grey.shade50,
                      ),
                      child: InteractiveWidget(
                        onZoomChange: _onZoomChange,
                        child: SizedBox(
                          height: 300,
                          width: MediaQuery.of(context).size.width,
                          child: FutureBuilder(
                            future: automata.getSvg(
                              type: _currentView,
                              showDeadStates: showDeadStates,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: SizedBox(
                                    height: 100,
                                    width: 100,
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              if (snapshot.hasError) {
                                return Center(
                                  child: ColoredBox(
                                    color: Colors.red,
                                    child: Text(snapshot.error.toString()),
                                  ),
                                );
                              }
                              if (snapshot.hasData) {
                                return SvgPicture.string(
                                  snapshot.data.toString(),
                                );
                              }
                              return const Center(
                                child: Text('No data'),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _viewButtons(),
                    ),
                    const SizedBox(height: 20),
                    if (_currentView != 'nfa')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Show dead states'),
                          const SizedBox(width: 10),
                          Switch(
                            value: showDeadStates,
                            onChanged: (value) {
                              setState(() {
                                showDeadStates = value;
                              });
                            },
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    if (_testStringVisible) _testStringWidget(),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _testStringVisible = !_testStringVisible;
                        });
                      },
                      child:
                          Text(_testStringVisible ? 'Collapse' : 'Test String'),
                    ),
                    Row(
                      children: [
                        saveButton(),
                        deleteButton(),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  List<ElevatedButton> _viewButtons() {
    return _viewItems
        .map(
          (view) => ElevatedButton(
            onPressed: () {
              setState(() {
                _currentView = view;
              });
            },
            child: Text(view.toUpperCase()),
          ),
        )
        .toList();
  }

  Widget _testStringWidget() {
    return Column(
      children: [
        TextField(
          controller: _testStringTextController,
          onChanged: (value) {
            setState(() {
              _isTestStringAccepted = widget.automata.testString(
                _testStringTextController.text,
              );
            });
          },
          decoration: const InputDecoration(
            labelText: 'Test string',
          ),
        ),
        const SizedBox(height: 10),
        _isTestStringAccepted
            ? ColoredBox(
                color: Colors.green,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'ACCEPTED',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            : ColoredBox(
                color: Colors.red,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'REJECTED',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
        const SizedBox(height: 10),
      ],
    );
  }
}
