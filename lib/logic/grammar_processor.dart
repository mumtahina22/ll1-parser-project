import 'grammar_result.dart';

class GrammarProcessor {
  // Internal state — reset on each processAll() call
  Map<String, List<String>> _grammar = {};
  List<String> _nonTerminals = [];
  List<String> _terminals = [];
  String _startSymbol = '';
  Map<String, Set<String>> _firstSets = {};
  Map<String, Set<String>> _followSets = {};

  GrammarResult processAll(String rawInput) {
    _reset();

    final parseError = _parseGrammar(rawInput);
    if (parseError != null) {
      return _errorResult(parseError);
    }

    final lrMap = _detectLeftRecursion();
    _computeFirstSets();
    _computeFollowSets();
    _extractTerminals();

    return GrammarResult(
      grammar: Map.unmodifiable(_grammar),
      nonTerminals: List.unmodifiable(_nonTerminals),
      terminals: List.unmodifiable(_terminals),
      startSymbol: _startSymbol,
      leftRecursionMap: Map.unmodifiable(lrMap),
      hasLeftRecursion: lrMap.values.any((v) => v),
      firstSets: _firstSets.map((k, v) => MapEntry(k, Set.unmodifiable(v))),
      followSets: _followSets.map((k, v) => MapEntry(k, Set.unmodifiable(v))),
    );
  }

  void _reset() {
    _grammar = {};
    _nonTerminals = [];
    _terminals = [];
    _startSymbol = '';
    _firstSets = {};
    _followSets = {};
  }

  GrammarResult _errorResult(String msg) => GrammarResult(
    grammar: {},
    nonTerminals: [],
    terminals: [],
    startSymbol: '',
    leftRecursionMap: {},
    hasLeftRecursion: false,
    firstSets: {},
    followSets: {},
    errorMessage: msg,
  );

  // ════════════════════════════════════════════════
  // STEP 1 — PARSE GRAMMAR
  // Accepts format:
  //   E=TE'|T
  //   E'=+TE'|ε
  //   F=(E)|id
  // ════════════════════════════════════════════════
  String? _parseGrammar(String input) {
    final lines = input
        .trim()
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) return 'Grammar is empty.';

    for (final line in lines) {
      // Support both = and → as separator
      final separatorIndex = line.indexOf('=');
      if (separatorIndex == -1) {
        return 'Invalid line (missing "="): "$line"';
      }

      final lhs = line.substring(0, separatorIndex).trim();
      final rhs = line.substring(separatorIndex + 1).trim();

      if (lhs.isEmpty) return 'Empty left-hand side in: "$line"';
      if (rhs.isEmpty) return 'Empty right-hand side in: "$line"';

      final productions = rhs.split('|').map((p) => p.trim()).toList();

      _grammar[lhs] = productions;
      _nonTerminals.add(lhs);
    }

    _startSymbol = _nonTerminals.first;
    return null; // no error
  }

  // ════════════════════════════════════════════════
  // STEP 2 — LEFT RECURSION DETECTION
  // Checks direct left recursion only: A → A α
  // ════════════════════════════════════════════════
  Map<String, bool> _detectLeftRecursion() {
    final result = <String, bool>{};
    for (final nt in _nonTerminals) {
      result[nt] = _grammar[nt]!.any((prod) {
        final tokens = tokenize(prod);
        return tokens.isNotEmpty && tokens.first == nt;
      });
    }
    return result;
  }

  // ════════════════════════════════════════════════
  // STEP 3 — FIRST SETS
  // Iterative fixed-point algorithm
  // ════════════════════════════════════════════════
  void _computeFirstSets() {
    for (final nt in _nonTerminals) {
      _firstSets[nt] = {};
    }

    bool changed = true;
    while (changed) {
      changed = false;
      for (final nt in _nonTerminals) {
        for (final production in _grammar[nt]!) {
          final toAdd = _firstOfProduction(tokenize(production));
          final before = _firstSets[nt]!.length;
          _firstSets[nt]!.addAll(toAdd);
          if (_firstSets[nt]!.length > before) changed = true;
        }
      }
    }
  }

  // FIRST of a tokenized production (list of symbols)
  Set<String> _firstOfProduction(List<String> symbols) {
    final result = <String>{};

    if (symbols.isEmpty) {
      result.add('ε');
      return result;
    }

    for (int i = 0; i < symbols.length; i++) {
      final sym = symbols[i];
      final firstSym = _firstOfSymbol(sym);

      result.addAll(firstSym.where((s) => s != 'ε'));

      if (!firstSym.contains('ε')) return result;

      // ε is in FIRST(sym) — continue to next symbol
      if (i == symbols.length - 1) {
        // Last symbol also has ε → whole production can derive ε
        result.add('ε');
      }
    }

    return result;
  }

  Set<String> _firstOfSymbol(String symbol) {
    if (_isEpsilon(symbol)) return {'ε'};
    if (_isTerminal(symbol)) return {symbol};
    return Set.of(_firstSets[symbol] ?? {});
  }

  // ════════════════════════════════════════════════
  // STEP 4 — FOLLOW SETS
  // Iterative fixed-point algorithm
  // ════════════════════════════════════════════════
  void _computeFollowSets() {
    for (final nt in _nonTerminals) {
      _followSets[nt] = {};
    }

    // Rule 1: $ ∈ FOLLOW(start symbol)
    _followSets[_startSymbol]!.add('\$');

    bool changed = true;
    while (changed) {
      changed = false;

      for (final nt in _nonTerminals) {
        for (final production in _grammar[nt]!) {
          final symbols = tokenize(production);

          for (int i = 0; i < symbols.length; i++) {
            final sym = symbols[i];
            if (_isTerminal(sym) || _isEpsilon(sym)) continue;

            final before = _followSets[sym]!.length;
            final rest = symbols.sublist(i + 1);

            if (rest.isEmpty) {
              // Rule 3: sym is last → FOLLOW(nt) ⊆ FOLLOW(sym)
              _followSets[sym]!.addAll(_followSets[nt]!);
            } else {
              // Rule 2: FIRST(rest) - {ε} ⊆ FOLLOW(sym)
              final firstRest = _firstOfProduction(rest);
              _followSets[sym]!.addAll(firstRest.where((s) => s != 'ε'));

              // If ε ∈ FIRST(rest) → FOLLOW(nt) ⊆ FOLLOW(sym)
              if (firstRest.contains('ε')) {
                _followSets[sym]!.addAll(_followSets[nt]!);
              }
            }

            if (_followSets[sym]!.length > before) changed = true;
          }
        }
      }
    }
  }

  // ════════════════════════════════════════════════
  // STEP 5 — EXTRACT TERMINALS
  // (for Member 2 to build table columns)
  // ════════════════════════════════════════════════
  void _extractTerminals() {
    final terminalSet = <String>{};
    for (final nt in _nonTerminals) {
      for (final prod in _grammar[nt]!) {
        for (final token in tokenize(prod)) {
          if (!_isEpsilon(token) && _isTerminal(token)) {
            terminalSet.add(token);
          }
        }
      }
    }
    terminalSet.remove('\$');
    final sortedTerminals = terminalSet.toList()..sort();
    _terminals = [...sortedTerminals, '\$'];
  }

  // ════════════════════════════════════════════════
  // TOKENIZER
  // Splits "TE'" → ['T', "E'"]
  // Splits "(E)|id" → ['(', 'E', ')', 'id'] (per production after | split)
  // Handles: uppercase NTs, primes ('), lowercase terminals (id/num), symbols
  // ════════════════════════════════════════════════
  List<String> tokenize(String production) {
    final tokens = <String>[];
    int i = 0;

    while (i < production.length) {
      final ch = production[i];

      if (ch == ' ') {
        i++;
        continue;
      }

      // Epsilon
      if (ch == 'ε' || (ch == 'e' && _isStandaloneEpsilon(production, i))) {
        tokens.add('ε');
        i++;
        continue;
      }

      // Non-terminal: uppercase letter, possibly followed by '
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

      // Multi-char terminal: starts with lowercase
      if (RegExp(r'[a-z]').hasMatch(ch)) {
        String token = '';
        while (i < production.length &&
            RegExp(r'[a-z]').hasMatch(production[i])) {
          token += production[i];
          i++;
        }
        // 'e' alone at end = epsilon (e.g. someone types 'e' for ε)
        if (token == 'e') {
          tokens.add('ε');
        } else {
          tokens.add(token);
        }
        continue;
      }

      // Single-character terminal: +, *, (, ), $, etc.
      tokens.add(ch);
      i++;
    }

    return tokens;
  }

  // ════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════
  bool _isTerminal(String symbol) =>
      !_nonTerminals.contains(symbol) && !_isEpsilon(symbol);

  bool _isEpsilon(String symbol) => symbol == 'ε' || symbol == 'e';

  // Checks 'e' is standalone (not part of 'else', 'end', etc.)
  bool _isStandaloneEpsilon(String production, int i) {
    final before = i == 0 || !RegExp(r'[a-zA-Z]').hasMatch(production[i - 1]);
    final after =
        i + 1 >= production.length ||
        !RegExp(r'[a-zA-Z]').hasMatch(production[i + 1]);
    return before && after;
  }

  // Public tokenize for Members 2 & 3 to use
  List<String> tokenizePublic(String production) => tokenize(production);
}
