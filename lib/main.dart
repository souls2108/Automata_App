import 'package:automata_app/provider/automata_provider/automata_provider.dart';
import 'package:automata_app/views/automata_operations/automata_operations.dart';
import 'package:automata_app/views/create_automata/create_automata_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AutomataProvider(),
      child: MaterialApp(
        theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            fontFamily: GoogleFonts.ubuntu().fontFamily,
            dataTableTheme: DataTableThemeData(
              dataRowMaxHeight: 50.0,
              dataRowMinHeight: 50.0,
              headingRowAlignment: MainAxisAlignment.center,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                textStyle: TextStyle(fontSize: 20),
              ),
            )),
        home: HomePage(),
      ),
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
                  ),
                ),
              ),
              SizedBox(
                height: 150,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AutomataOperations(),
                      ),
                    );
                  },
                  child: const Text(
                    'Operations',
                  ),
                ),
              ),
              SizedBox(
                height: 150,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text(
                    'AI assistant',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
