class ParseStep {
  final int stepNumber;
  final String stack;
  final String input;
  final String action;

  ParseStep({
    required this.stepNumber,
    required this.stack,
    required this.input,
    required this.action,
  });
}

class ParseResult {
  final List<ParseStep> steps;
  final bool accepted;
  final String finalMessage;

  ParseResult({
    required this.steps,
    required this.accepted,
    required this.finalMessage,
  });
}