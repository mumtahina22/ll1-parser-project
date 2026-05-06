import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ll1_parser/logic/parse_step.dart';
import 'package:ll1_parser/logic/parser_simulator.dart';
import '../logic/grammar_result.dart';
import '../logic/grammar_processor.dart';
import '../logic/parsing_table_generator.dart';

class SimulationSection extends StatefulWidget {
  final GrammarResult result;

  const SimulationSection({super.key, required this.result});

  @override
  State<SimulationSection> createState() => _SimulationSectionState();
}

class _SimulationSectionState extends State<SimulationSection> {
  final TextEditingController _inputController = TextEditingController();
  ParseResult? _parseResult;

  void _runSimulation() {
    final inputStr = _inputController.text.trim();
    if (inputStr.isEmpty) return;

    final processor = GrammarProcessor();
    List<String> tokens = processor.tokenizePublic(inputStr);

    if (tokens.isEmpty || tokens.last != '\$') {
      tokens.add('\$');
    }

    final generator = ParsingTableGenerator();
    final table = generator.generate(widget.result);

    final simResult = simulate(
      table,
      widget.result.nonTerminals.toSet(),
      widget.result.startSymbol,
      tokens,
    );

    setState(() {
      _parseResult = simResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGlassCard(
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Enter string (e.g., id+id)',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.keyboard_rounded, color: Theme.of(context).colorScheme.secondary),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Theme.of(context).colorScheme.secondary, const Color(0xFF00B4D8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Theme.of(context).colorScheme.secondary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _runSimulation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Simulate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
        
        AnimatedSize(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutExpo,
          child: _parseResult != null ? Column(
            children: [
              const SizedBox(height: 24),
              _buildGlassCard(
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.white.withOpacity(0.05)),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.white.withOpacity(0.05)),
                      columnSpacing: 40,
                      headingRowHeight: 56,
                      columns: [
                        DataColumn(label: Text('Step', style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.secondary))),
                        const DataColumn(label: Text('Stack', style: TextStyle(fontWeight: FontWeight.w900))),
                        const DataColumn(label: Text('Input', style: TextStyle(fontWeight: FontWeight.w900))),
                        DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor))),
                      ],
                      rows: _parseResult!.steps.map((step) {
                        return DataRow(
                          color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                            return step.stepNumber % 2 == 0 ? Colors.white.withOpacity(0.02) : Colors.transparent;
                          }),
                          cells: [
                            DataCell(Text(step.stepNumber.toString(), style: const TextStyle(fontWeight: FontWeight.w600))),
                            DataCell(Text(step.stack, style: const TextStyle(fontWeight: FontWeight.w500, letterSpacing: 1.1))),
                            DataCell(Text(step.input, style: const TextStyle(fontWeight: FontWeight.w500, letterSpacing: 1.1))),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: step.action.contains('❌')
                                      ? Colors.redAccent.withOpacity(0.15)
                                      : step.action.contains('✅')
                                          ? const Color(0xFF00FF41).withOpacity(0.15)
                                          : Theme.of(context).primaryColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  step.action,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: step.action.contains('❌') 
                                        ? Colors.redAccent 
                                        : step.action.contains('✅') 
                                            ? const Color(0xFF00FF41) 
                                            : Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // FINAL RESULT BANNER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _parseResult!.accepted 
                        ? [const Color(0xFF00FF41).withOpacity(0.15), const Color(0xFF00FF41).withOpacity(0.05)]
                        : [Colors.redAccent.withOpacity(0.15), Colors.redAccent.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _parseResult!.accepted ? const Color(0xFF00FF41).withOpacity(0.5) : Colors.redAccent.withOpacity(0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _parseResult!.accepted ? const Color(0xFF00FF41).withOpacity(0.1) : Colors.redAccent.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _parseResult!.accepted ? const Color(0xFF00FF41).withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
                      ),
                      child: Icon(
                        _parseResult!.accepted ? Icons.check_rounded : Icons.close_rounded,
                        color: _parseResult!.accepted ? const Color(0xFF00FF41) : Colors.redAccent,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _parseResult!.finalMessage,
                      style: TextStyle(
                        color: _parseResult!.accepted ? const Color(0xFF00FF41) : Colors.redAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ) : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}