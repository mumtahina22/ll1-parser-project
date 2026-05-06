
// Shared data contract between all 4 members.

class GrammarResult {
  final Map<String, List<String>> grammar;
  final List<String> nonTerminals;
  final List<String> terminals;
  final String startSymbol;
  final Map<String, bool> leftRecursionMap;
  final bool hasLeftRecursion;
  final Map<String, Set<String>> firstSets;
  final Map<String, Set<String>> followSets;
  final String? errorMessage; // null = no error

  const GrammarResult({
    required this.grammar,
    required this.nonTerminals,
    required this.terminals,
    required this.startSymbol,
    required this.leftRecursionMap,
    required this.hasLeftRecursion,
    required this.firstSets,
    required this.followSets,
    this.errorMessage,
  });

  bool get isValid => errorMessage == null;

  // Convenience: all productions as flat list
  // e.g. [('E', 'TE\''), ('E\'', '+TE\''), ('E\'', 'ε'), ...]
  List<(String, String)> get allProductions {
    final result = <(String, String)>[];
    for (final nt in nonTerminals) {
      for (final prod in grammar[nt]!) {
        result.add((nt, prod));
      }
    }
    return result;
  }

@override
String toString() {
  return '''
Left Recursion: $hasLeftRecursion

FIRST Sets:
$firstSets

FOLLOW Sets:
$followSets
''';
}
}