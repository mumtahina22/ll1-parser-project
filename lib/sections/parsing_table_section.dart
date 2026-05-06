import 'package:flutter/material.dart';
import '../../logic/grammar_result.dart';
import '../../logic/parsing_table_generator.dart'; // Import Member 2's file

class ParsingTableSection extends StatelessWidget {
  final GrammarResult result;
  final VoidCallback onSimulate;

  const ParsingTableSection({
    super.key,
    required this.result,
    required this.onSimulate,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Run Member 2's logic
    final generator = ParsingTableGenerator();
    final table = generator.generate(result);

    // 2. Build Columns dynamically based on terminals
    final List<DataColumn> columns = [
      DataColumn(
        label: Text(
          'NT',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary, // Teal accent
          ),
        ),
      ),
    ];

    for (final t in result.terminals) {
      columns.add(
        DataColumn(
          label: Text(
            t,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // 3. Build Rows dynamically based on non-terminals
    final List<DataRow> rows = [];
    for (final nt in result.nonTerminals) {
      final List<DataCell> cells = [
        DataCell(
          Text(
            nt,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ];

      for (final t in result.terminals) {
        final production = table[nt]?[t];
        if (production != null && production.isNotEmpty) {
          cells.add(DataCell(Text('$nt → $production')));
        } else {
          cells.add(const DataCell(Text(''))); // Empty cell
        }
      }

      rows.add(DataRow(cells: cells));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Wrap the table in a container to give it a clean, modern card look
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface, // Lighter midnight blue
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
          // Scroll horizontally if the grammar has many terminals
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.white.withOpacity(0.05)),
              border: TableBorder(
                horizontalInside: BorderSide(color: Colors.white.withOpacity(0.05)),
                verticalInside: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
              columns: columns,
              rows: rows,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: onSimulate,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Proceed to Simulation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }
}