// lib/test/grammar_test.dart
// Run with: dart lib/test/grammar_test.dart

import '../logic/grammar_processor.dart';

void main() {
  final processor = GrammarProcessor();

  print('─────── TEST 1: Standard LL(1) Grammar ───────');
  final r1 = processor.processAll("""
E=TE'
E'=+TE'|ε
T=FT'
T'=*FT'|ε
F=(E)|id
""");
  _printResult(r1);

  print('\n─────── TEST 2: Left Recursive Grammar ───────');
  final r2 = processor.processAll("""
E=E+T|T
T=T*F|F
F=(E)|id
""");
  _printResult(r2);

  print('\n─────── TEST 3: Bad Input ───────');
  final r3 = processor.processAll("this is garbage");
  print('Error: ${r3.errorMessage}');
}

void _printResult(result) {
  if (!result.isValid) {
    print('ERROR: ${result.errorMessage}');
    return;
  }

  print('Start: ${result.startSymbol}');
  print('Non-terminals: ${result.nonTerminals}');
  print('Terminals: ${result.terminals}');

  print('\nLeft Recursion:');
  result.leftRecursionMap.forEach((nt, hasLR) {
    print('  $nt: ${hasLR ? "⚠️  YES — cannot build LL(1) table!" : "✅ NO"}');
  });

  print('\nFIRST Sets:');
  result.firstSets.forEach((nt, first) {
    print('  FIRST($nt) = { ${first.join(', ')} }');
  });

  print('\nFOLLOW Sets:');
  result.followSets.forEach((nt, follow) {
    print('  FOLLOW($nt) = { ${follow.join(', ')} }');
  });

  print('\nAll Productions (for Member 2):');
  for (final (nt, prod) in result.allProductions) {
    print('  $nt → $prod');
  }
}