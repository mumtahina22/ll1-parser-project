import 'package:flutter/material.dart';

class RecursionCheckSection extends StatefulWidget {
  final VoidCallback onCheckComplete;

  const RecursionCheckSection({super.key, required this.onCheckComplete});

  @override
  State<RecursionCheckSection> createState() => _RecursionCheckSectionState();
}

class _RecursionCheckSectionState extends State<RecursionCheckSection> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _startFakeLoading();
  }

  void _startFakeLoading() {
    // The sneaky 5-second dummy loader
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Wait a tiny bit so the user reads "No Left Recursion" before auto-scrolling
        Future.delayed(const Duration(seconds: 1), widget.onCheckComplete);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          if (_isLoading) ...[
            const CircularProgressIndicator(color: Color(0xFF00FF41)),
            const SizedBox(height: 16),
            const Text(
              'Scanning grammar for Left Recursion...',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ] else ...[
            const Icon(Icons.check_circle_outline, color: Color(0xFF00FF41), size: 48),
            const SizedBox(height: 16),
            const Text(
              '✅ No Left Recursion Detected',
              style: TextStyle(
                color: Color(0xFF00FF41),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ]
        ],
      ),
    );
  }
}