import 'dart:ui';
import 'package:flutter/material.dart';
import '../../logic/grammar_result.dart';
import '../../logic/parsing_table_generator.dart';

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
    final generator = ParsingTableGenerator();
    final table = generator.generate(result);

    final List<DataColumn> columns = [
      DataColumn(
        label: Text(
          'NT',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    ];

    for (final t in result.terminals) {
      columns.add(
        DataColumn(
          label: Text(
            t,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
          ),
        ),
      );
    }

    final List<DataRow> rows = [];
    for (int i = 0; i < result.nonTerminals.length; i++) {
      final nt = result.nonTerminals[i];
      final List<DataCell> cells = [
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              nt,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ),
      ];

      for (final t in result.terminals) {
        final production = table[nt]?[t];
        if (production != null && production.isNotEmpty) {
          cells.add(DataCell(
            Text(
              '$nt → $production',
              style: const TextStyle(fontWeight: FontWeight.w500, letterSpacing: 1.1),
            )
          ));
        } else {
          cells.add(const DataCell(Text('')));
        }
      }

      rows.add(DataRow(
        color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          return i % 2 == 0 ? Colors.white.withOpacity(0.02) : Colors.transparent;
        }),
        cells: cells,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildGlassCard(
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.white.withOpacity(0.05),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.white.withOpacity(0.05)),
                columnSpacing: 40,
                horizontalMargin: 24,
                headingRowHeight: 56,
                dataRowMinHeight: 56,
                dataRowMaxHeight: 56,
                border: TableBorder(
                  horizontalInside: BorderSide(color: Colors.white.withOpacity(0.05)),
                  verticalInside: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
                columns: columns,
                rows: rows,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, const Color(0xFF2563EB)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4)),
            ],
          ),
          child: ElevatedButton(
            onPressed: onSimulate,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('PROCEED TO SIMULATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2, color: Colors.white)),
          ),
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