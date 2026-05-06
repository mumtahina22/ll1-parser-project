import 'parse_step.dart';

ParseResult simulate(
  Map<String, Map<String, String>> parsingTable,
  Set<String> nonTerminals,
  String startSymbol,
  List<String> inputTokens,
) {
  List<ParseStep> steps = [];
  List<String> stack = ["\$", startSymbol];
  int inputPointer = 0;
  int stepNum = 1;

  while (true) {
    String top = stack.last;
    String current = inputTokens[inputPointer];

    String stackStr = stack.reversed.join(" ");
    String inputStr = inputTokens.sublist(inputPointer).join(" ");

    // CASE 1: Both $ — Accept
    if (top == "\$" && current == "\$") {
      steps.add(
        ParseStep(
          stepNumber: stepNum,
          stack: stackStr,
          input: inputStr,
          action: "✅ Accepted",
        ),
      );
      return ParseResult(
        steps: steps,
        accepted: true,
        finalMessage: "✅ String Accepted",
      );
    }

    // CASE 2: Terminal match
    if (top == current) {
      steps.add(
        ParseStep(
          stepNumber: stepNum++,
          stack: stackStr,
          input: inputStr,
          action: "Match '${top}', advance input",
        ),
      );
      stack.removeLast();
      inputPointer++;
      continue;
    }

    // CASE 3: Non-terminal — expand using table
    if (nonTerminals.contains(top)) {
      String? production = parsingTable[top]?[current];

      if (production == null) {
        steps.add(
          ParseStep(
            stepNumber: stepNum,
            stack: stackStr,
            input: inputStr,
            action: "❌ Error: No rule for [$top][$current]",
          ),
        );
        return ParseResult(
          steps: steps,
          accepted: false,
          finalMessage: "❌ String Rejected: No rule for [$top][$current]",
        );
      }

      steps.add(
        ParseStep(
          stepNumber: stepNum++,
          stack: stackStr,
          input: inputStr,
          action: "Expand $top → $production",
        ),
      );

      stack.removeLast();

      if (production != "ε") {
        List<String> rhs = production.split(" ");
        for (String symbol in rhs.reversed) {
          stack.add(symbol);
        }
      }

      continue;
    }

    // CASE 4: Terminal mismatch — error
    steps.add(
      ParseStep(
        stepNumber: stepNum,
        stack: stackStr,
        input: inputStr,
        action: "❌ Error: Expected '$top' but got '$current'",
      ),
    );
    return ParseResult(
      steps: steps,
      accepted: false,
      finalMessage: "❌ String Rejected: Expected '$top' but got '$current'",
    );
  }
}