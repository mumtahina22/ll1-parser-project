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

  GrammarResult? _grammarResult;

  void _scrollTo(GlobalKey key) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutExpo,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Parser Visualizer',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0B0F19).withOpacity(0.9),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.8, -0.6),
            radius: 2.0,
            colors: [
              Color(0xFF162544), // Subtle blue glow at top left
              Color(0xFF0B0F19), // Deep background
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // STEP 1: GRAMMAR INPUT
                _buildSectionHeader(
                  key: _grammarKey,
                  title: 'Input Grammar',
                  icon: Icons.input_rounded,
                ),
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
                _buildAnimatedSection(
                  show: _showRecursion,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Divider(color: Colors.white12),
                      ),
                      _buildSectionHeader(
                        key: _recursionKey,
                        title: 'Left Recursion Check',
                        icon: Icons.loop_rounded,
                      ),
                      RecursionCheckSection(
                        onCheckComplete: () {
                          setState(() => _showFirstFollow = true);
                          _scrollTo(_firstFollowKey);
                        },
                      ),
                    ],
                  ),
                ),

                // STEP 3: FIRST & FOLLOW
                _buildAnimatedSection(
                  show: _showFirstFollow && _grammarResult != null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Divider(color: Colors.white12),
                      ),
                      _buildSectionHeader(
                        key: _firstFollowKey,
                        title: 'FIRST & FOLLOW Sets',
                        icon: Icons.data_object_rounded,
                      ),
                      if (_grammarResult != null)
                        FirstFollowSection(
                          result: _grammarResult!,
                          onGenerateTable: () {
                            setState(() => _showTable = true);
                            _scrollTo(_tableKey);
                          },
                        ),
                    ],
                  ),
                ),

                // STEP 4: PARSING TABLE
                _buildAnimatedSection(
                  show: _showTable && _grammarResult != null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Divider(color: Colors.white12),
                      ),
                      _buildSectionHeader(
                        key: _tableKey,
                        title: 'LL(1) Parsing Table',
                        icon: Icons.table_chart_rounded,
                      ),
                      if (_grammarResult != null)
                        ParsingTableSection(
                          result: _grammarResult!,
                          onSimulate: () {
                            setState(() => _showSim = true);
                            _scrollTo(_simKey);
                          },
                        ),
                    ],
                  ),
                ),

                // STEP 5: SIMULATION
                _buildAnimatedSection(
                  show: _showSim && _grammarResult != null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Divider(color: Colors.white12),
                      ),
                      _buildSectionHeader(
                        key: _simKey,
                        title: 'Step-by-Step Simulation',
                        icon: Icons.play_circle_fill_rounded,
                      ),
                      if (_grammarResult != null)
                        SimulationSection(result: _grammarResult!),
                    ],
                  ),
                ),

                const SizedBox(height: 300),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSection({required bool show, required Widget child}) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutExpo,
      child: AnimatedOpacity(
        opacity: show ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 600),
        child: show ? child : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildSectionHeader({
    required GlobalKey key,
    required String title,
    required IconData icon,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.secondary,
            size: 28,
            shadows: [
              Shadow(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                blurRadius: 8,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
        ],
      ),
    );
  }
}
