import 'dart:ui';
import 'package:flutter/material.dart';
import '../../logic/grammar_processor.dart';
import '../../logic/grammar_result.dart';

class GrammarInputSection extends StatefulWidget {
  final Function(GrammarResult) onCheckComplete;

  const GrammarInputSection({super.key, required this.onCheckComplete});

  @override
  State<GrammarInputSection> createState() => _GrammarInputSectionState();
}

class _GrammarInputSectionState extends State<GrammarInputSection> {
  final TextEditingController _countController = TextEditingController();
  int _ruleCount = 0;
  bool _showRows = false;

  final List<TextEditingController> _lhsControllers = [];
  final List<TextEditingController> _rhsControllers = [];

  void _generateRows() {
    setState(() {
      _ruleCount = int.tryParse(_countController.text) ?? 0;
      _showRows = _ruleCount > 0;
      
      _lhsControllers.clear();
      _rhsControllers.clear();
      for (int i = 0; i < _ruleCount; i++) {
        _lhsControllers.add(TextEditingController());
        _rhsControllers.add(TextEditingController());
      }
    });
  }

  void _processGrammar() {
    StringBuffer rawGrammarBuilder = StringBuffer();
    for (int i = 0; i < _ruleCount; i++) {
      final lhs = _lhsControllers[i].text.trim();
      final rhs = _rhsControllers[i].text.trim();
      if (lhs.isNotEmpty && rhs.isNotEmpty) {
        rawGrammarBuilder.writeln('$lhs=$rhs');
      }
    }

    final rawString = rawGrammarBuilder.toString();
    final processor = GrammarProcessor();
    final result = processor.processAll(rawString);

    if (!result.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${result.errorMessage}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.redAccent.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    widget.onCheckComplete(result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGlassCard(
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _countController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Rules count (e.g., 3)',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _generateRows,
                  child: const Text('Generate', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
        
        AnimatedSize(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutExpo,
          child: _showRows ? Column(
            children: [
              const SizedBox(height: 24),
              _buildGlassCard(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _ruleCount,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: _buildInputField(_lhsControllers[index], '', TextAlign.center),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Icon(Icons.arrow_forward_rounded, color: Theme.of(context).colorScheme.secondary, size: 28),
                          ),
                          Expanded(
                            flex: 3,
                            child: _buildInputField(_rhsControllers[index], '', TextAlign.left),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Container(
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
                    onPressed: _processGrammar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('CHECK GRAMMAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ) : const SizedBox.shrink(),
        )
      ],
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint, TextAlign align) {
    return TextField(
      controller: controller,
      textAlign: align,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: child,
        ),
      ),
    );
  }
}