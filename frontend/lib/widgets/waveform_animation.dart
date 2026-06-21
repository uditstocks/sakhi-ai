/// Animated waveform bars displayed while the assistant is actively listening
/// to voice input. The bars oscillate continuously using a sine-based phase
/// offset to simulate audio activity.
library;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sakhi_ai/theme/sakhi_colors.dart';

/// A stateful widget that renders seven animated vertical bars.
///
/// Each bar's height oscillates independently via a phase-shifted sine wave,
/// creating a smooth waveform visualisation.
class WaveformAnimation extends StatefulWidget {
  const WaveformAnimation({super.key});

  @override
  State<WaveformAnimation> createState() => _WaveformAnimationState();
}

class _WaveformAnimationState extends State<WaveformAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// Sets up the repeating animation controller (900 ms cycle).
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  /// Disposes the animation controller to free resources.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Builds seven animated bars whose heights oscillate via a sine wave.
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(7, (index) {
            final phase = (_controller.value * 2 * math.pi) + (index * 0.7);
            final height = 12 + (math.sin(phase).abs() * 28);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                width: 6,
                height: height,
                decoration: BoxDecoration(
                  color: SakhiColors.gold.withValues(alpha: 0.85 + index * 0.02),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
