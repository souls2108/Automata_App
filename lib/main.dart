import 'package:automata_app/services/graph_svg/graph_svg_provider.dart';
import 'package:automata_app/views/create_automata/create_automata_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
  GraphSvgProvider.instance;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        dataTableTheme: DataTableThemeData(
          dataRowMaxHeight: 50.0,
          dataRowMinHeight: 50.0,
          headingRowAlignment: MainAxisAlignment.center,
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Automata'),
      ),
      body: Center(
        child: SizedBox(
          height: 500,
          width: 350,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateAutomataView(),
                      ),
                    );
                  },
                  child: const Text(
                    'Create Automata',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              // SizedBox(height: 20),
              SizedBox(
                height: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Operations',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              // SizedBox(height: 20),
              SizedBox(
                height: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'AI assistant',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              // SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
