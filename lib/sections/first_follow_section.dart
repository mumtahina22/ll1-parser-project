import 'dart:ui';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGlassCard(
          context: context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, 'FIRST Sets', Icons.looks_one_rounded, const Color(0xFFE879F9)),
              const SizedBox(height: 16),
              ...result.nonTerminals.map((nt) {
                final firstStr = result.firstSets[nt]?.join(', ') ?? '';
                return _buildSetRow(context, 'FIRST', nt, firstStr, const Color(0xFFE879F9));
              }),
              
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Divider(color: Colors.white12),
              ),
              
              _buildSectionTitle(context, 'FOLLOW Sets', Icons.looks_two_rounded, const Color(0xFF38BDF8)),
              const SizedBox(height: 16),
              ...result.nonTerminals.map((nt) {
                final followStr = result.followSets[nt]?.join(', ') ?? '';
                return _buildSetRow(context, 'FOLLOW', nt, followStr, const Color(0xFF38BDF8));
              }),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: Container(
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
              onPressed: onGenerateTable,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('GENERATE PARSING TABLE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color, letterSpacing: 1.1),
        ),
      ],
    );
  }

  Widget _buildSetRow(BuildContext context, String prefix, String nt, String setStr, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Text(
              '$prefix(',
              style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w600),
            ),
            Text(
              nt,
              style: TextStyle(fontSize: 18, color: accentColor, fontWeight: FontWeight.bold),
            ),
            Text(
              ')',
              style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w600),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text('=', style: TextStyle(fontSize: 18, color: Colors.white54)),
            ),
            Expanded(
              child: Text(
                '{ $setStr }',
                style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required BuildContext context, required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}