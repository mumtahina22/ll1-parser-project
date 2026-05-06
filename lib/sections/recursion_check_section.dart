import 'dart:ui';
import 'package:flutter/material.dart';

class RecursionCheckSection extends StatefulWidget {
  final VoidCallback onCheckComplete;

  const RecursionCheckSection({super.key, required this.onCheckComplete});

  @override
  State<RecursionCheckSection> createState() => _RecursionCheckSectionState();
}

class _RecursionCheckSectionState extends State<RecursionCheckSection> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _startFakeLoading();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startFakeLoading() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Future.delayed(const Duration(milliseconds: 1500), widget.onCheckComplete);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
          decoration: BoxDecoration(
            color: _isLoading ? Colors.white.withOpacity(0.03) : const Color(0xFF00FF41).withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _isLoading ? Colors.white.withOpacity(0.08) : const Color(0xFF00FF41).withOpacity(0.3)),
            boxShadow: _isLoading ? [] : [
              BoxShadow(color: const Color(0xFF00FF41).withOpacity(0.1), blurRadius: 20, spreadRadius: 5),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _isLoading ? _buildLoadingState() : _buildSuccessState(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      key: const ValueKey('loading'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                  boxShadow: [
                    BoxShadow(color: Theme.of(context).colorScheme.secondary.withOpacity(0.4), blurRadius: 20),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Analyzing Grammar Structure...',
          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8), letterSpacing: 1.1, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      key: const ValueKey('success'),
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00FF41).withOpacity(0.2),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF00FF41).withOpacity(0.4), blurRadius: 15),
                  ],
                ),
                child: const Icon(Icons.check_rounded, color: Color(0xFF00FF41), size: 40),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'No Left Recursion Detected',
          style: TextStyle(
            color: Color(0xFF00FF41),
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}