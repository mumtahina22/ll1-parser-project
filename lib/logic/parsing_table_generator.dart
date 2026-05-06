// ============================================================
// parsing_table_generator.dart
// Member 2 — LL(1) Parsing Table Generator
//
// INPUT  : GrammarResult (from Member 1's GrammarProcessor)
// OUTPUT : Map<String, Map<String, String>>
//            outer key = non-terminal  e.g. "E"
//            inner key = terminal      e.g. "id"
//            value     = production    e.g. "T E'"
// ============================================================

import 'grammar_result.dart'; 

class ParsingTableGenerator {
  // ──────────────────────────────────────────────
  // PUBLIC ENTRY POINT
  // Call this from UI with a valid GrammarResult.
  // Returns an empty map if grammar has errors.
  // ──────────────────────────────────────────────
  Map<String, Map<String, String>> generate(GrammarResult result) {
    // Safety check — don't proceed if Member 1 flagged an error
    if (!result.isValid) {
      print('[ParsingTableGenerator] GrammarResult has error: ${result.errorMessage}');
      return {};
    }

    // Initialize empty table: table[nonTerminal][terminal] = ""
    final Map<String, Map<String, String>> table = {};
    for (final nt in result.nonTerminals) {
      table[nt] = {};
    }

    // ── CORE LL(1) ALGORITHM ──────────────────────
    // For each production A → α:
    //   1. For each terminal a in FIRST(α)  (excluding ε):
    //        table[A][a] = "A → α"
    //   2. If ε ∈ FIRST(α):
    //        For each terminal b in FOLLOW(A):
    //          table[A][b] = "A → α"
    // ─────────────────────────────────────────────
    for (final nt in result.nonTerminals) {
      final productions = result.grammar[nt]!;

      for (final production in productions) {
        // Tokenize this production using Member 1's tokenizer
        // e.g. "T E'" → ['T', "E'"]
        // e.g. "+ T E'" → ['+', 'T', "E'"]
        // e.g. "ε" → ['ε']
        final tokens = _tokenizeProduction(result, production);

        // Compute FIRST of this production's token list
        final firstOfProd = _firstOfTokenList(tokens, result);

        // Rule 1: for each real terminal in FIRST(production)
        for (final terminal in firstOfProd) {
          if (terminal != 'ε') {
            _addToTable(table, nt, terminal, production);
          }
        }

        // Rule 2: if ε ∈ FIRST(production), use FOLLOW(A)
        if (firstOfProd.contains('ε')) {
          final followA = result.followSets[nt] ?? {};
          for (final terminal in followA) {
            _addToTable(table, nt, terminal, production);
          }
        }
      }
    }

    return table;
  }

  // ──────────────────────────────────────────────
  // COMPUTE FIRST OF A TOKEN LIST
  // e.g. tokens = ['T', "E'"] with FIRST(T)={id,(}
  //   → returns {id, (}
  // ──────────────────────────────────────────────
  Set<String> _firstOfTokenList(List<String> tokens, GrammarResult result) {
    final first = <String>{};

    if (tokens.isEmpty) {
      first.add('ε');
      return first;
    }

    for (int i = 0; i < tokens.length; i++) {
      final sym = tokens[i];
      final firstSym = _firstOfSymbol(sym, result);

      // Add everything except ε
      first.addAll(firstSym.where((s) => s != 'ε'));

      if (!firstSym.contains('ε')) {
        // This symbol can't derive ε — stop here
        return first;
      }

      // Symbol can derive ε — continue to next symbol
      if (i == tokens.length - 1) {
        // Last symbol also derives ε → whole sequence derives ε
        first.add('ε');
      }
    }

    return first;
  }

  // ──────────────────────────────────────────────
  // FIRST OF A SINGLE SYMBOL
  // Terminal  → {terminal}
  // ε         → {ε}
  // NonTerminal → FIRST(nonTerminal) from result
  // ──────────────────────────────────────────────
  Set<String> _firstOfSymbol(String symbol, GrammarResult result) {
    if (_isEpsilon(symbol)) return {'ε'};
    if (result.nonTerminals.contains(symbol)) {
      return Set.of(result.firstSets[symbol] ?? {});
    }
    // It's a terminal
    return {symbol};
  }

  // ──────────────────────────────────────────────
  // ADD TO TABLE (with conflict warning)
  // If a cell is already filled, it's a conflict
  // (grammar is not LL(1)) — we warn but don't crash
  // ──────────────────────────────────────────────
  void _addToTable(
    Map<String, Map<String, String>> table,
    String nonTerminal,
    String terminal,
    String production,
  ) {
    final existing = table[nonTerminal]?[terminal];
    final entry = '$nonTerminal → $production';

    if (existing != null && existing.isNotEmpty) {
      // Conflict detected — not LL(1)
      print(
        '[CONFLICT] table[$nonTerminal][$terminal] already has "$existing", '
        'cannot add "$entry". Grammar may not be LL(1).',
      );
      return;
    }

    table[nonTerminal]![terminal] = production;
  }

  // ──────────────────────────────────────────────
  // TOKENIZE using Member 1's public tokenizer
  // ──────────────────────────────────────────────
  List<String> _tokenizeProduction(GrammarResult result, String production) {
    // GrammarProcessor exposes tokenizePublic() — we reuse it via a
    // temporary processor instance to avoid duplicating tokenizer logic.
    // In the integrated Flutter app, pass the GrammarProcessor instance
    // directly if preferred.
    return _GrammarTokenizerHelper.tokenize(production);
  }

  bool _isEpsilon(String s) => s == 'ε' || s == 'e';
}

// ──────────────────────────────────────────────────────────────
// INTERNAL TOKENIZER HELPER
// Mirrors Member 1's tokenize() logic so this file works
// standalone without importing GrammarProcessor directly.
// When integrating, you can replace this with:
//   grammarProcessor.tokenizePublic(production)
// ──────────────────────────────────────────────────────────────
class _GrammarTokenizerHelper {
  static List<String> tokenize(String production) {
    final tokens = <String>[];
    int i = 0;

    while (i < production.length) {
      final ch = production[i];

      if (ch == ' ') { i++; continue; }

      // Epsilon
      if (ch == 'ε') { tokens.add('ε'); i++; continue; }

      // Non-terminal: uppercase + optional primes
      if (RegExp(r'[A-Z]').hasMatch(ch)) {
        String token = ch;
        i++;
        while (i < production.length && production[i] == "'") {
          token += production[i];
          i++;
        }
        tokens.add(token);
        continue;
      }

      // Multi-char lowercase terminal (e.g. "id", "num")
      if (RegExp(r'[a-z]').hasMatch(ch)) {
        String token = '';
        while (i < production.length && RegExp(r'[a-z]').hasMatch(production[i])) {
          token += production[i];
          i++;
        }
        tokens.add(token == 'e' ? 'ε' : token);
        continue;
      }

      // Single-char terminal: +, *, (, ), $, etc.
      tokens.add(ch);
      i++;
    }

    return tokens;
  }
}


// ================================================================
// STANDALONE TEST — run with: dart parsing_table_generator.dart
// Uses the classic E grammar (no left recursion):
//
//   E  → T E'
//   E' → + T E' | ε
//   T  → F T'
//   T' → * F T' | ε
//   F  → ( E ) | id
//
// Expected table (partial):
//   E  : id→"T E'",  (→"T E'"
//   E' : +→"+ T E'", )→"ε",  $→"ε"
//   T  : id→"F T'",  (→"F T'"
//   T' : *→"* F T'", +→"ε",  )→"ε", $→"ε"
//   F  : id→"id",    (→"( E )"
// ================================================================
void main() {
  // ── Simulate what Member 1 returns ──────────────────────────
  final mockResult = _buildMockGrammarResult();

  // ── Run the generator ────────────────────────────────────────
  final generator = ParsingTableGenerator();
  final table = generator.generate(mockResult);

  // ── Print the table ──────────────────────────────────────────
  _printTable(table, mockResult.nonTerminals, mockResult.terminals);
}

void _printTable(
  Map<String, Map<String, String>> table,
  List<String> nonTerminals,
  List<String> terminals,
) {
  // Column width for formatting
  const int colW = 14;

  // Header row
  final header = 'NT'.padRight(6) +
      terminals.map((t) => t.padRight(colW)).join();
  print('\n${'─' * header.length}');
  print('LL(1) PARSING TABLE');
  print('${'─' * header.length}');
  print(header);
  print('${'─' * header.length}');

  for (final nt in nonTerminals) {
    final row = StringBuffer(nt.padRight(6));
    for (final t in terminals) {
      final cell = table[nt]?[t] ?? '';
      row.write(cell.padRight(colW));
    }
    print(row.toString());
  }
  print('${'─' * header.length}\n');
}

// ── Build a mock GrammarResult (mirrors what Member 1 produces) ─
GrammarResult _buildMockGrammarResult() {
  return GrammarResult(
    grammar: {
      "E":  ["T E'"],
      "E'": ["+ T E'", "ε"],
      "T":  ["F T'"],
      "T'": ["* F T'", "ε"],
      "F":  ["( E )", "id"],
    },
    nonTerminals: ["E", "E'", "T", "T'", "F"],
    terminals:    ["(", ")", "*", "+", "id", "\$"],
    startSymbol:  "E",
    leftRecursionMap: {
      "E": false, "E'": false, "T": false, "T'": false, "F": false,
    },
    hasLeftRecursion: false,
    firstSets: {
      "E":  {"id", "("},
      "E'": {"+", "ε"},
      "T":  {"id", "("},
      "T'": {"*", "ε"},
      "F":  {"id", "("},
    },
    followSets: {
      "E":  {"\$", ")"},
      "E'": {"\$", ")"},
      "T":  {"+", "\$", ")"},
      "T'": {"+", "\$", ")"},
      "F":  {"*", "+", "\$", ")"},
    },
  );
}