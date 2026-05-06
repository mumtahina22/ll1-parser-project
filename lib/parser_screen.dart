import 'package:flutter/material.dart';
import 'package:ll1_parser/sections/first_follow_section.dart';
import 'package:ll1_parser/sections/grammar_input_section.dart';
import 'package:ll1_parser/sections/parsing_table_section.dart';
import 'package:ll1_parser/sections/recursion_check_section.dart';
import 'package:ll1_parser/sections/simulation_section.dart';
import '../logic/grammar_result.dart';

class ParserScreen extends StatefulWidget {
  const ParserScreen({super.key});

  @override
  State<ParserScreen> createState() => _ParserScreenState();
}

class _ParserScreenState extends State<ParserScreen> {
  final GlobalKey _grammarKey = GlobalKey();
  final GlobalKey _recursionKey = GlobalKey();
  final GlobalKey _firstFollowKey = GlobalKey();
  final GlobalKey _tableKey = GlobalKey();
  final GlobalKey _simKey = GlobalKey();

  bool _showRecursion = false;
  bool _showFirstFollow = false;
  bool _showTable = false;
  bool _showSim = false;

  // State variable to hold the processed grammar data
  GrammarResult? _grammarResult;

  void _scrollTo(GlobalKey key) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Parser Visualizer')),
        backgroundColor: const Color(0xFF1E293B), // Matches the Midnight Blue surface theme
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // STEP 1: GRAMMAR INPUT
            _buildSectionHeader(key: _grammarKey, title: '1. Input Grammar'),
            GrammarInputSection(
              onCheckComplete: (result) {
                setState(() {
                  _grammarResult = result;
                  _showRecursion = true;
                });
                _scrollTo(_recursionKey);
              },
            ),

            // STEP 2: RECURSION CHECK
            if (_showRecursion) ...[
              const Divider(height: 60, color: Colors.white24),
              _buildSectionHeader(key: _recursionKey, title: '2. Left Recursion Check'),
              RecursionCheckSection(
                onCheckComplete: () {
                  setState(() => _showFirstFollow = true);
                  _scrollTo(_firstFollowKey);
                },
              ),
            ],

            // STEP 3: FIRST & FOLLOW
            if (_showFirstFollow && _grammarResult != null) ...[
              const Divider(height: 60, color: Colors.white24),
              _buildSectionHeader(key: _firstFollowKey, title: '3. FIRST & FOLLOW Sets'),
              FirstFollowSection(
                result: _grammarResult!,
                onGenerateTable: () {
                  setState(() => _showTable = true);
                  _scrollTo(_tableKey);
                },
              ),
            ],

            // STEP 4: PARSING TABLE
            if (_showTable && _grammarResult != null) ...[
              const Divider(height: 60, color: Colors.white24),
              _buildSectionHeader(key: _tableKey, title: '4. LL(1) Parsing Table'),
              ParsingTableSection(
                result: _grammarResult!,
                onSimulate: () {
                  setState(() => _showSim = true);
                  _scrollTo(_simKey);
                },
              ),
            ],

            // STEP 5: SIMULATION
            if (_showSim && _grammarResult != null) ...[
              const Divider(height: 60, color: Colors.white24),
              _buildSectionHeader(key: _simKey, title: '5. Step-by-Step Simulation'),
              // FIXED: Removed 'const' and passed the required result parameter
              SimulationSection(result: _grammarResult!), 
            ],

            const SizedBox(height: 400),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required GlobalKey key, required String title}) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}