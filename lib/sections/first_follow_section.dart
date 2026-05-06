import 'package:flutter/material.dart';
import '../../logic/grammar_result.dart';

class FirstFollowSection extends StatelessWidget {
  final GrammarResult result;
  final VoidCallback onGenerateTable;

  const FirstFollowSection({
    super.key, 
    required this.result, 
    required this.onGenerateTable
  });

  @override
  Widget build(BuildContext context) {
    // Dynamically build the display string based on Member 1's calculated sets
    StringBuffer sb = StringBuffer();
    
    for (var nt in result.nonTerminals) {
      final firstStr = result.firstSets[nt]?.join(', ') ?? '';
      sb.writeln('FIRST($nt)  = { $firstStr }');
    }
    sb.writeln(); // Blank line between First and Follow
    
    for (var nt in result.nonTerminals) {
      final followStr = result.followSets[nt]?.join(', ') ?? '';
      sb.writeln('FOLLOW($nt) = { $followStr }');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            sb.toString().trim(),
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onGenerateTable,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.black,
          ),
          child: const Text('Generate Parsing Table', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}