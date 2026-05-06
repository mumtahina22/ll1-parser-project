import 'package:flutter/material.dart';
import 'package:ll1_parser/logic/parse_step.dart';
import 'package:ll1_parser/logic/parser_simulator.dart';
import '../logic/grammar_result.dart';
import '../logic/grammar_processor.dart'; // For the tokenizer
import '../logic/parsing_table_generator.dart'; // For the table

class SimulationSection extends StatefulWidget {
  final GrammarResult result; // We need this to get startSymbol and nonTerminals

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

    // 1. Tokenize the input using Member 1's tokenizer so "id+id" becomes ['id', '+', 'id']
    final processor = GrammarProcessor();
    List<String> tokens = processor.tokenizePublic(inputStr);

    // 2. Automatically append '$' if the user forgot it
    if (tokens.isEmpty || tokens.last != '\$') {
      tokens.add('\$');
    }

    // 3. Generate the parsing table (Reusing Member 2's logic)
    final generator = ParsingTableGenerator();
    final table = generator.generate(widget.result);

    // 4. Run Member 3's simulation logic!
    final simResult = simulate(
      table,
      widget.result.nonTerminals.toSet(),
      widget.result.startSymbol,
      tokens,
    );

    // 5. Trigger a UI rebuild with the new data
    setState(() {
      _parseResult = simResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. INPUT FIELD & BUTTON
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                decoration: InputDecoration(
                  hintText: 'Enter string (e.g., id+id)',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.keyboard, color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _runSimulation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.black, // Dark text on teal button
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Simulate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // 2. STEP-BY-STEP TABLE (Only shows if simulation has run)
        if (_parseResult != null) ...[
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.white.withOpacity(0.05)),
                columns: [
                  DataColumn(label: Text('Step', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary))),
                  const DataColumn(label: Text('Stack', style: TextStyle(fontWeight: FontWeight.bold))),
                  const DataColumn(label: Text('Input', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor))),
                ],
                rows: _parseResult!.steps.map((step) {
                  return DataRow(cells: [
                    DataCell(Text(step.stepNumber.toString())),
                    DataCell(Text(step.stack)),
                    DataCell(Text(step.input)),
                    DataCell(
                      Text(
                        step.action,
                        style: TextStyle(
                          // Make errors red, acceptances green, normal actions primary blue
                          color: step.action.contains('❌') 
                              ? Colors.redAccent 
                              : step.action.contains('✅') 
                                  ? Colors.greenAccent 
                                  : Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 3. FINAL RESULT BANNER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _parseResult!.accepted ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _parseResult!.accepted ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _parseResult!.accepted ? Icons.check_circle : Icons.error,
                  color: _parseResult!.accepted ? Colors.greenAccent : Colors.redAccent,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  _parseResult!.finalMessage,
                  style: TextStyle(
                    color: _parseResult!.accepted ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        ],
      ],
    );
  }
}