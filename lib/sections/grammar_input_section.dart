import 'package:flutter/material.dart';
import '../../logic/grammar_processor.dart';
import '../../logic/grammar_result.dart';

class GrammarInputSection extends StatefulWidget {
  // Callback now passes the GrammarResult up to the parent
  final Function(GrammarResult) onCheckComplete;

  const GrammarInputSection({super.key, required this.onCheckComplete});

  @override
  State<GrammarInputSection> createState() => _GrammarInputSectionState();
}

class _GrammarInputSectionState extends State<GrammarInputSection> {
  final TextEditingController _countController = TextEditingController();
  int _ruleCount = 0;
  bool _showRows = false;

  // NEW: Lists to hold the controllers for the dynamically generated rows
  final List<TextEditingController> _lhsControllers = [];
  final List<TextEditingController> _rhsControllers = [];

  void _generateRows() {
    setState(() {
      _ruleCount = int.tryParse(_countController.text) ?? 0;
      _showRows = _ruleCount > 0;
      
      // Clear old controllers and create new ones based on the count
      _lhsControllers.clear();
      _rhsControllers.clear();
      for (int i = 0; i < _ruleCount; i++) {
        _lhsControllers.add(TextEditingController());
        _rhsControllers.add(TextEditingController());
      }
    });
  }

  void _processGrammar() {
    // 1. Build the raw string from the text fields
    StringBuffer rawGrammarBuilder = StringBuffer();
    for (int i = 0; i < _ruleCount; i++) {
      final lhs = _lhsControllers[i].text.trim();
      final rhs = _rhsControllers[i].text.trim();
      if (lhs.isNotEmpty && rhs.isNotEmpty) {
        rawGrammarBuilder.writeln('$lhs=$rhs');
      }
    }

    final rawString = rawGrammarBuilder.toString();

    // 2. Run Member 1's logic
    final processor = GrammarProcessor();
    final result = processor.processAll(rawString);

    if (!result.isValid) {
      // Show error if invalid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${result.errorMessage}', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
      return;
    }

    // 3. Pass result back to parent to continue the flow
    widget.onCheckComplete(result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _countController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter number of grammar rules (e.g., 3)',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              ),
              onPressed: _generateRows,
              child: const Text('Generate'),
            ),
          ],
        ),
        
        if (_showRows) ...[
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _ruleCount,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: _lhsControllers[index],
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'E',
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('→', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF00FF41))),
                    ),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _rhsControllers[index],
                        decoration: InputDecoration(
                          hintText: 'E+T | T',
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _processGrammar,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
            ),
            child: const Text('Check Grammar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ]
      ],
    );
  }
}